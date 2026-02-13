import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/models/permission_models.dart';
import '../../../shared/widgets/buttons/permission_button.dart';
import '../../../shared/widgets/guards/permission_guard.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralGrey,
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Accounting Ledger',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeXxl,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                // Action buttons with permission guards
                Row(
                  children: [
                    PermissionButton(
                      permission: PermissionNames.accountingWrite,
                      onPressed: () {
                        // Create new entry
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Create ledger entry (requires accounting.write)'),
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text('Create Entry'),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceSm),
                    PermissionIconButton(
                      permission: PermissionNames.accountingManage,
                      hideIfNoPermission: true,
                      icon: const Icon(Icons.settings),
                      tooltip: 'Manage Accounting Settings',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Manage accounting settings (requires accounting.manage)'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceMd),

            // Permission guard example
            const PermissionGuard(
              permission: PermissionNames.accountingRead,
              showFallback: true,
              fallback: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: AppConstants.spaceMd),
                    Text(
                      'Access Denied',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeLg,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppConstants.spaceSm),
                    Text(
                      'You do not have permission to view accounting records.',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeBase,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              child: Expanded(
                child: Center(
                  child: Text(
                    'Accounting module coming soon',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeBase,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
