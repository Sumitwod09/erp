import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/role_service.dart';
import '../../../features/auth/models/permission_models.dart';
import '../../../core/constants/app_constants.dart';

/// Screen for managing user role assignments (admin only)
class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  List<Map<String, dynamic>> _users = [];
  List<Role> _roles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final users = await RoleService.getBusinessUsers();
      final roles = await RoleService.getAllRoles();

      setState(() {
        _users = users;
        _roles = roles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _changeUserRole(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => _ChangeRoleDialog(
        user: user,
        roles: _roles,
        onChanged: () {
          _loadData();
        },
      ),
    );
  }

  String _getRoleDisplayName(String roleName) {
    final role = _roles.firstWhere(
      (r) => r.name == roleName,
      orElse: () => Role(
        id: '',
        name: roleName,
        displayName: roleName,
        isSystemRole: false,
      ),
    );
    return role.displayName;
  }

  Color _getRoleColor(String roleName) {
    switch (roleName) {
      case 'admin':
        return Colors.purple;
      case 'manager':
        return Colors.blue;
      case 'accountant':
        return Colors.green;
      case 'sales':
        return Colors.orange;
      case 'inventory_manager':
        return Colors.teal;
      case 'viewer':
        return Colors.grey;
      default:
        return Colors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text('No users found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.spaceMd),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    final roleName = user['role'] as String? ?? 'viewer';

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: AppConstants.spaceSm,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getRoleColor(roleName),
                          child: Text(
                            (user['email'] as String)
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(user['email'] as String),
                        subtitle: Text(
                          'Joined: ${_formatDate(user['created_at'] as String)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(_getRoleDisplayName(roleName)),
                              backgroundColor: _getRoleColor(roleName)
                                  .withValues(alpha: 0.2),
                            ),
                            const SizedBox(width: AppConstants.spaceSm),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _changeUserRole(user),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

/// Dialog for changing a user's role
class _ChangeRoleDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  final List<Role> roles;
  final VoidCallback onChanged;

  const _ChangeRoleDialog({
    required this.user,
    required this.roles,
    required this.onChanged,
  });

  @override
  State<_ChangeRoleDialog> createState() => _ChangeRoleDialogState();
}

class _ChangeRoleDialogState extends State<_ChangeRoleDialog> {
  String? _selectedRole;
  bool _isChanging = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user['role'] as String?;
  }

  Future<void> _changeRole() async {
    if (_selectedRole == null) return;

    setState(() => _isChanging = true);

    try {
      await RoleService.assignRole(
        widget.user['id'] as String,
        _selectedRole!,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role updated successfully')),
        );
        widget.onChanged();
      }
    } catch (e) {
      setState(() => _isChanging = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating role: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change User Role'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User: ${widget.user['email']}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            'Select Role:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppConstants.spaceSm),
          ...widget.roles.map((role) {
            return RadioListTile<String>(
              title: Text(role.displayName),
              subtitle: Text(role.description ?? ''),
              value: role.name,
              groupValue: _selectedRole,
              onChanged: (value) {
                setState(() => _selectedRole = value);
              },
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isChanging ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isChanging ? null : _changeRole,
          child: _isChanging
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update Role'),
        ),
      ],
    );
  }
}
