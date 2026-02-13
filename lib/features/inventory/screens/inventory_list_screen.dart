import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../models/inventory_item_model.dart';
import '../providers/inventory_provider.dart';
import '../widgets/inventory_form_dialog.dart';

class InventoryListScreen extends ConsumerWidget {
  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryItemsProvider);

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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inventory Management',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeXxl,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Track items, quantities, and prices',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppConstants.fontSizeSm,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: variable and function for add item
                    _showAddEditItemDialog(context, null);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.actionBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceLg,
                      vertical: AppConstants.spaceMd,
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('New Item'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceLg),
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: inventoryAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inventory_2_outlined,
                                size: 64, color: AppColors.textSecondary),
                            const SizedBox(height: AppConstants.spaceMd),
                            const Text(
                              'No inventory items found',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: AppConstants.spaceSm),
                            ElevatedButton(
                              onPressed: () =>
                                  _showAddEditItemDialog(context, null),
                              child: const Text('Add your first item'),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                              AppColors.surface.withOpacity(0.5)),
                          columns: const [
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('SKU')),
                            DataColumn(label: Text('Quantity')),
                            DataColumn(label: Text('Unit Price')),
                            DataColumn(label: Text('Reorder Level')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: items.map((item) {
                            return DataRow(cells: [
                              DataCell(Text(item.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500))),
                              DataCell(Text(item.sku ?? '-')),
                              DataCell(
                                Text(
                                  item.quantity.toString(),
                                  style: TextStyle(
                                      color: item.quantity <= item.reorderLevel
                                          ? AppColors.error
                                          : AppColors.textPrimary,
                                      fontWeight:
                                          item.quantity <= item.reorderLevel
                                              ? FontWeight.bold
                                              : FontWeight.normal),
                                ),
                              ),
                              DataCell(Text(
                                  '\$${item.unitPrice.toStringAsFixed(2)}')),
                              DataCell(Text(item.reorderLevel.toString())),
                              DataCell(Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () =>
                                        _showAddEditItemDialog(context, item),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        size: 20, color: AppColors.error),
                                    onPressed: () =>
                                        _deleteItem(context, ref, item),
                                    tooltip: 'Delete',
                                  ),
                                ],
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditItemDialog(BuildContext context, InventoryItem? item) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => InventoryFormDialog(item: item),
    );
  }

  Future<void> _deleteItem(
      BuildContext context, WidgetRef ref, InventoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (context.mounted) {
        try {
          await ref.read(inventoryItemsProvider.notifier).deleteItem(item.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item deleted successfully')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error deleting item: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    }
  }
}
