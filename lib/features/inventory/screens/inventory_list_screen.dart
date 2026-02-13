import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class InventoryListScreen extends StatelessWidget {
  const InventoryListScreen({super.key});

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
                Text(
                  'Inventory Management',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeXxl,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Add new inventory item
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Item'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Expanded(
              child: Center(
                child: Text(
                  'Inventory module coming soon',
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
