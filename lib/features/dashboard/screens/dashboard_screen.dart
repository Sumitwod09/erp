import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralGrey,
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: AppConstants.fontSizeXxl,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),

            // Dashboard Content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.dashboard_rounded,
                      size: 64,
                      color: AppColors.actionBlue.withOpacity(0.5),
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    Text(
                      'Welcome to Lumiere ERP',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeLg,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceSm),
                    Text(
                      'Configure your modules in Settings to get started',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeBase,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
