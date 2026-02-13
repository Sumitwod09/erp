import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class SalesListScreen extends StatelessWidget {
  const SalesListScreen({super.key});

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
                  'Sales & Invoicing',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeXxl,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: New sale (Alt+N shortcut)
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Sale'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceMd),
            const Expanded(
              child: Center(
                child: Text(
                  'Sales module coming soon',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeBase,
                    color: AppColors.textSecondary,
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
