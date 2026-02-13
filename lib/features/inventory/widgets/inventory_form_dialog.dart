import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../models/inventory_item_model.dart';
import '../providers/inventory_provider.dart';

class InventoryFormDialog extends ConsumerStatefulWidget {
  final InventoryItem? item;

  const InventoryFormDialog({super.key, this.item});

  @override
  ConsumerState<InventoryFormDialog> createState() =>
      _InventoryFormDialogState();
}

class _InventoryFormDialogState extends ConsumerState<InventoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _reorderController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _skuController = TextEditingController(text: widget.item?.sku ?? '');
    _descriptionController =
        TextEditingController(text: widget.item?.description ?? '');
    _quantityController =
        TextEditingController(text: widget.item?.quantity.toString() ?? '0');
    _priceController = TextEditingController(
        text: widget.item?.unitPrice.toString() ?? '0.00');
    _reorderController = TextEditingController(
        text: widget.item?.reorderLevel.toString() ?? '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _reorderController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final sku = _skuController.text.trim();
      final description = _descriptionController.text.trim();
      final quantity = double.tryParse(_quantityController.text) ?? 0;
      final unitPrice = double.tryParse(_priceController.text) ?? 0;
      final reorderLevel = double.tryParse(_reorderController.text) ?? 0;

      final itemData = {
        'name': name,
        'sku': sku.isEmpty ? null : sku,
        'description': description.isEmpty ? null : description,
        'quantity': quantity,
        'unit_price': unitPrice,
        'reorder_level': reorderLevel,
      };

      if (widget.item == null) {
        await ref.read(inventoryItemsProvider.notifier).addItem(itemData);
      } else {
        await ref
            .read(inventoryItemsProvider.notifier)
            .updateItem(widget.item!.id, itemData);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Item ${widget.item == null ? 'added' : 'updated'} successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Add Inventory Item' : 'Edit Item'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500, // Fixed width for dialog
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spaceMd),
                TextFormField(
                  controller: _skuController,
                  decoration: const InputDecoration(
                    labelText: 'SKU (Stock Keeping Unit)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceMd),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d*')),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceMd),
                    Expanded(
                      child: TextFormField(
                        controller: _reorderController,
                        decoration: const InputDecoration(
                          labelText: 'Reorder Level',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d*')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceMd),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Unit Price',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceMd),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.actionBlue,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(widget.item == null ? 'Add Item' : 'Save Changes'),
        ),
      ],
    );
  }
}
