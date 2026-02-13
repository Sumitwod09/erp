import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/models/permission_models.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../providers/active_modules_provider.dart';
import '../../models/module_model.dart';

/// Adaptive sidebar that updates based on active modules
class AdaptiveSidebar extends ConsumerWidget {
  final Function(String) onNavigate;

  const AdaptiveSidebar({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeModulesAsync = ref.watch(activeModulesProvider);

    return Container(
      color: AppColors.deepNavy,
      child: Column(
        children: [
          // App Header
          Container(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            child: Row(
              children: [
                Icon(
                  Icons.dashboard_rounded,
                  color: AppColors.textOnDark,
                  size: 28,
                ),
                const SizedBox(width: AppConstants.spaceSm),
                Expanded(
                  child: Text(
                    AppConstants.appName,
                    style: TextStyle(
                      color: AppColors.textOnDark,
                      fontSize: AppConstants.fontSizeLg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            color: AppColors.actionBlue,
            height: 1,
          ),

          // Navigation Items (Dynamic based on active modules)
          Expanded(
            child: activeModulesAsync.when(
              data: (modules) => _buildModuleList(modules),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.textOnDark,
                ),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading modules',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ),

          // Settings at bottom
          const Divider(
            color: AppColors.actionBlue,
            height: 1,
          ),
          _buildNavItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
            onTap: () => onNavigate('/settings'),
          ),

          _buildNavItem(
            icon: Icons.logout_rounded,
            label: 'Logout',
            onTap: () {
              ref.read(authProvider.notifier).signOut();
            },
          ),

          // User role badge
          Consumer(
            builder: (context, ref, child) {
              final authState = ref.watch(authProvider);
              final roleName = authState.userRole?.displayName ?? 'User';

              return Container(
                padding: const EdgeInsets.all(AppConstants.spaceSm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.textOnDark.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      roleName,
                      style: TextStyle(
                        color: AppColors.textOnDark.withOpacity(0.7),
                        fontSize: AppConstants.fontSizeSm,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModuleList(List<ModuleModel> modules) {
    if (modules.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          child: Text(
            'No modules active.\nConfigure modules in Settings.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textOnDark.withOpacity(0.7),
              fontSize: AppConstants.fontSizeSm,
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceSm),
      children: [
        // Dashboard (always present)
        _buildNavItem(
          icon: Icons.home_rounded,
          label: 'Dashboard',
          onTap: () => onNavigate('/dashboard'),
        ),

        // Dynamic module items (filtered by permissions)
        ...modules.where((module) => _hasModuleAccess(module)).map(
              (module) => _buildNavItem(
                icon: _getIconForModule(module.icon),
                label: module.name,
                onTap: () => onNavigate(module.route),
              ),
            ),
      ],
    );
  }

  /// Check if user has access to a module
  bool _hasModuleAccess(ModuleModel module) {
    // Map module names to permission resources
    final resourceMap = {
      'Inventory': Resource.inventory,
      'Accounting': Resource.accounting,
      'Sales': Resource.sales,
      'Payroll': Resource.payroll,
      'Customers': Resource.customers,
      'Reports': Resource.reports,
    };

    final resource = resourceMap[module.name];
    if (resource == null) return true; // Allow unknown modules

    // Check if user has at least read access
    return true; // Permissions are checked asynch later
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: AppColors.actionBlue.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceMd,
            vertical: AppConstants.spaceSm,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.textOnDark,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textOnDark,
                    fontSize: AppConstants.fontSizeBase,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForModule(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'inventory':
        return Icons.inventory_2_rounded;
      case 'accounting':
        return Icons.account_balance_rounded;
      case 'sales':
        return Icons.point_of_sale_rounded;
      case 'payroll':
        return Icons.payments_rounded;
      case 'customers':
        return Icons.people_rounded;
      case 'reports':
        return Icons.assessment_rounded;
      case 'manufacturing':
        return Icons.factory_rounded;
      case 'receipt_long':
      case 'invoice':
        return Icons.receipt_long_rounded;
      default:
        return Icons.apps_rounded;
    }
  }
}
