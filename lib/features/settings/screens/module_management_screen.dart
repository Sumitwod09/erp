import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/module_model.dart';
import '../../../shared/providers/active_modules_provider.dart';
import '../../../shared/services/module_service.dart';

class ModuleManagementScreen extends ConsumerStatefulWidget {
  const ModuleManagementScreen({super.key});

  @override
  ConsumerState<ModuleManagementScreen> createState() =>
      _ModuleManagementScreenState();
}

class _ModuleManagementScreenState
    extends ConsumerState<ModuleManagementScreen> {
  final List<ModuleModel> _allModules = ModuleService.getSystemModules();
  // We'll track local toggles to optimize UI, but the source of truth is the provider
  final Map<String, bool> _pendingToggles = {};
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final activeModulesAsync = ref.watch(activeModulesProvider);

    return Scaffold(
      backgroundColor: AppColors.neutralGrey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
        title: const Text('Module Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: activeModulesAsync.when(
        data: (activeModules) {
          final activeModuleNames = activeModules.map((e) => e.name).toSet();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customize Your Modules',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeXl,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceSm),
                    const Text(
                      'Enable modules to access features. Disabled modules are hidden from your workspace.',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeBase,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isProcessing)
                const LinearProgressIndicator(color: AppColors.actionBlue),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(AppConstants.spaceLg),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    mainAxisSpacing: AppConstants.spaceMd,
                    crossAxisSpacing: AppConstants.spaceMd,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: _allModules.length,
                  itemBuilder: (context, index) {
                    final module = _allModules[index];
                    final isActive = activeModuleNames.contains(module.name);

                    return _buildModuleCard(module, isActive);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildModuleCard(ModuleModel module, bool isActive) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.actionBlue.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconData(module.icon),
                    color: isActive ? AppColors.actionBlue : Colors.grey,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.name,
                        style: const TextStyle(
                          fontSize: AppConstants.fontSizeLg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        module.category,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSm,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isActive,
                  activeColor: AppColors.actionBlue,
                  onChanged: _isProcessing
                      ? null
                      : (val) => _toggleModule(module.name, val),
                ),
                if (isActive)
                  IconButton(
                    icon: const Icon(Icons.settings_suggest_rounded),
                    color: AppColors.textSecondary,
                    tooltip: 'Configure Module',
                    onPressed: () {
                      context.go('/settings/modules/${module.id}');
                    },
                  ),
              ],
            ),
            const Spacer(),
            Text(
              module.description ?? 'No description available.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppConstants.fontSizeSm,
                color: AppColors.textPrimary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleModule(String moduleName, bool isActive) async {
    setState(() => _isProcessing = true);

    try {
      await ModuleService.toggleModule(
          moduleName: moduleName, isActive: isActive);

      // Refresh the provider to update UI and Sidebar
      ref.invalidate(activeModulesProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update module: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'inventory':
        return Icons.inventory_2_rounded;
      case 'sales':
        return Icons.point_of_sale_rounded;
      case 'accounting':
        return Icons.account_balance_rounded;
      case 'crm':
        return Icons.groups_rounded;
      case 'hrm':
        return Icons.badge_rounded;
      case 'manufacturing':
        return Icons.factory_rounded;
      default:
        return Icons.apps_rounded;
    }
  }
}
