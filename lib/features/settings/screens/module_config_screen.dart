import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/module_model.dart';
import '../../../shared/services/module_service.dart';
import '../../../shared/providers/module_settings_provider.dart';

class ModuleConfigScreen extends ConsumerStatefulWidget {
  final String moduleId;

  const ModuleConfigScreen({
    super.key,
    required this.moduleId,
  });

  @override
  ConsumerState<ModuleConfigScreen> createState() => _ModuleConfigScreenState();
}

class _ModuleConfigScreenState extends ConsumerState<ModuleConfigScreen> {
  // Mock configuration features for demonstration
  // In a real app, this would be fetched from DB per module
  late ModuleModel? _module;

  @override
  void initState() {
    super.initState();
    _loadModule();
  }

  void _loadModule() {
    // Find module info
    final modules = ModuleService.getSystemModules();
    try {
      _module = modules.firstWhere((m) => m.id == widget.moduleId);
    } catch (_) {
      _module = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_module == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Module not found')),
      );
    }

    final settingsAsync = ref.watch(moduleSettingsProvider(widget.moduleId));

    return Scaffold(
      backgroundColor: AppColors.neutralGrey,
      appBar: AppBar(
        title: Text('Configure ${_module!.name}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceMd),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.actionBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_getIconData(_module!.icon),
                          color: AppColors.actionBlue, size: 32),
                    ),
                    const SizedBox(width: AppConstants.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _module!.name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _module!.description ?? '',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceLg),
            const Text(
              'Feature Configuration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            settingsAsync.when(
              data: (currentSettings) {
                // Merge with defaults
                final settings = {
                  ..._getDefaultSettings(widget.moduleId),
                  ...currentSettings
                };

                return Column(children: [
                  ...settings.entries.map((entry) {
                    if (entry.value is! bool)
                      return const SizedBox
                          .shrink(); // Only bool toggles for now

                    return Card(
                      margin:
                          const EdgeInsets.only(bottom: AppConstants.spaceSm),
                      child: SwitchListTile(
                        title: Text(entry.key),
                        value: entry.value,
                        activeColor: AppColors.actionBlue,
                        onChanged: (val) {
                          final newSettings = {...settings, entry.key: val};
                          ref
                              .read(moduleSettingsProvider(widget.moduleId)
                                  .notifier)
                              .updateSettings(widget.moduleId, newSettings);
                        },
                      ),
                    );
                  }),
                ]);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getDefaultSettings(String moduleId) {
    if (moduleId == 'invoice') {
      return {
        'Show Tax Field': true,
        'Enable Discounts': true,
        'Show Shipping Address': false,
        'Auto-generate Invoice Numbers': true,
      };
    } else if (moduleId == 'inventory') {
      return {
        'Track Low Stock': true,
        'Allow Negative Stock': false,
        'Multi-warehouse': true,
      };
    } else {
      return {
        'Enable Advanced Features': false,
        'Show in Dashboard': true,
      };
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
      case 'receipt_long':
        return Icons.receipt_long_rounded;
      case 'invoice':
        return Icons.receipt_long_rounded;
      default:
        return Icons.apps_rounded;
    }
  }
}
