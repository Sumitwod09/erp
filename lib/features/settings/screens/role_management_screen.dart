import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/role_service.dart';
import '../../../features/auth/models/permission_models.dart';
import '../../../core/constants/app_constants.dart';

/// Screen for managing roles and permissions (admin only)
class RoleManagementScreen extends ConsumerStatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  ConsumerState<RoleManagementScreen> createState() =>
      _RoleManagementScreenState();
}

class _RoleManagementScreenState extends ConsumerState<RoleManagementScreen> {
  List<Role> _roles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    setState(() => _isLoading = true);
    try {
      final roles = await RoleService.getAllRoles();
      setState(() {
        _roles = roles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading roles: $e')),
        );
      }
    }
  }

  void _showRoleDetails(Role role) {
    showDialog(
      context: context,
      builder: (context) => _RoleDetailsDialog(role: role),
    );
  }

  void _createCustomRole() {
    showDialog(
      context: context,
      builder: (context) => _CreateRoleDialog(
        onCreated: () {
          _loadRoles();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              itemCount: _roles.length,
              itemBuilder: (context, index) {
                final role = _roles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppConstants.spaceSm),
                  child: ListTile(
                    leading: Icon(
                      role.isSystemRole
                          ? Icons.admin_panel_settings
                          : Icons.person,
                      color: role.isSystemRole ? Colors.blue : Colors.grey,
                    ),
                    title: Text(role.displayName),
                    subtitle: Text(role.description ?? 'No description'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (role.isSystemRole)
                          const Chip(
                            label: Text('System'),
                            backgroundColor: Colors.blue,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () => _showRoleDetails(role),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createCustomRole,
        icon: const Icon(Icons.add),
        label: const Text('Create Custom Role'),
      ),
    );
  }
}

/// Dialog for viewing role details and permissions
class _RoleDetailsDialog extends StatefulWidget {
  final Role role;

  const _RoleDetailsDialog({required this.role});

  @override
  State<_RoleDetailsDialog> createState() => _RoleDetailsDialogState();
}

class _RoleDetailsDialogState extends State<_RoleDetailsDialog> {
  Role? _roleWithPermissions;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoleDetails();
  }

  Future<void> _loadRoleDetails() async {
    try {
      final role = await RoleService.getRoleWithPermissions(widget.role.id);
      setState(() {
        _roleWithPermissions = role;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.role.displayName),
      content: SizedBox(
        width: 500,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.role.description ?? 'No description',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  Text(
                    'Permissions:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppConstants.spaceSm),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _roleWithPermissions?.permissions?.length ?? 0,
                      itemBuilder: (context, index) {
                        final permission =
                            _roleWithPermissions!.permissions![index];
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            _getPermissionIcon(permission.action),
                            size: 16,
                          ),
                          title: Text(permission.name),
                          subtitle: Text(permission.description ?? ''),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  IconData _getPermissionIcon(String action) {
    switch (action) {
      case 'read':
        return Icons.visibility;
      case 'write':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'manage':
        return Icons.settings;
      default:
        return Icons.check;
    }
  }
}

/// Dialog for creating a custom role
class _CreateRoleDialog extends StatefulWidget {
  final VoidCallback onCreated;

  const _CreateRoleDialog({required this.onCreated});

  @override
  State<_CreateRoleDialog> createState() => _CreateRoleDialogState();
}

class _CreateRoleDialogState extends State<_CreateRoleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isCreating = false;

  Future<void> _createRole() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      await RoleService.createCustomRole(
        name: _nameController.text.trim().toLowerCase().replaceAll(' ', '_'),
        displayName: _displayNameController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Custom role created successfully')),
        );
        widget.onCreated();
      }
    } catch (e) {
      setState(() => _isCreating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating role: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Custom Role'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'e.g., Custom Manager',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Display name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spaceMd),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createRole,
          child: _isCreating
              ? const CircularProgressIndicator()
              : const Text('Create'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _displayNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
