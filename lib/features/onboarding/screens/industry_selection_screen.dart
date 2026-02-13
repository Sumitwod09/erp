import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class IndustrySelectionScreen extends ConsumerWidget {
  const IndustrySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.neutralGrey,
      body: Center(
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(AppConstants.spaceXl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Your Industry',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeXxl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Text(
                'Choose your industry to activate preset modules',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeBase,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceXl),

              // Industry Cards
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppConstants.spaceMd,
                  mainAxisSpacing: AppConstants.spaceMd,
                  children: [
                    _IndustryCard(
                      title: 'Retail',
                      description: 'Point of sale and retail operations',
                      icon: Icons.store_rounded,
                      modules: [
                        'Inventory',
                        'Sales',
                        'Accounting',
                        'Customers'
                      ],
                      onSelect: () => _selectIndustry(context, ref, 'retail'),
                    ),
                    _IndustryCard(
                      title: 'Pharmaceutical',
                      description: 'Pharmacy with batch tracking',
                      icon: Icons.local_pharmacy_rounded,
                      modules: ['Inventory', 'Sales', 'Accounting'],
                      onSelect: () => _selectIndustry(context, ref, 'pharma'),
                    ),
                    _IndustryCard(
                      title: 'Warehouse & Logistics',
                      description: 'Warehouse management and dispatch',
                      icon: Icons.warehouse_rounded,
                      modules: ['Inventory'],
                      onSelect: () =>
                          _selectIndustry(context, ref, 'warehouse'),
                    ),
                    _IndustryCard(
                      title: 'Manufacturing',
                      description: 'Production and materials management',
                      icon: Icons.factory_rounded,
                      modules: ['Inventory', 'Accounting'],
                      onSelect: () =>
                          _selectIndustry(context, ref, 'manufacturing'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectIndustry(
      BuildContext context, WidgetRef ref, String industry) async {
    // TODO: Implement industry selection logic
    // 1. Get industry preset from database
    // 2. Activate default modules
    // 3. Update business record
    // 4. Navigate to dashboard

    if (context.mounted) {
      context.go('/dashboard');
    }
  }
}

class _IndustryCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<String> modules;
  final VoidCallback onSelect;

  const _IndustryCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.modules,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 40,
                color: AppColors.actionBlue,
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Text(
                title,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeLg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceXs),
              Text(
                description,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSm,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                'Includes:',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSm,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceXs),
              ...modules.map((module) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '• $module',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSm,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
