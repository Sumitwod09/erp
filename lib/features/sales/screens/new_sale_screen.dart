import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../inventory/models/inventory_item_model.dart';
import '../../inventory/providers/inventory_provider.dart';
import '../providers/sales_provider.dart';

class NewSaleScreen extends ConsumerStatefulWidget {
  const NewSaleScreen({super.key});

  @override
  ConsumerState<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends ConsumerState<NewSaleScreen> {
  final _customerController = TextEditingController();
  final List<SaleItemEntry> _selectedItems = [];
  String _paymentMethod = 'cash';
  bool _isLoading = false;

  double get _totalAmount =>
      _selectedItems.fold(0.0, (sum, item) => sum + item.total);

  @override
  void dispose() {
    _customerController.dispose();
    super.dispose();
  }

  void _addItem(InventoryItem item) {
    setState(() {
      final existingIndex =
          _selectedItems.indexWhere((e) => e.inventoryItem.id == item.id);
      if (existingIndex != -1) {
        _selectedItems[existingIndex].quantity++;
      } else {
        _selectedItems.add(SaleItemEntry(inventoryItem: item, quantity: 1));
      }
    });
  }

  Future<void> _submitSale() async {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final itemsData = _selectedItems
          .map((e) => {
                'inventory_item_id': e.inventoryItem.id,
                'quantity': e.quantity,
                'unit_price': e.inventoryItem.unitPrice,
                'total_price': e.total,
              })
          .toList();

      await ref.read(salesProvider.notifier).createSale(
            customerName: _customerController.text.isEmpty
                ? null
                : _customerController.text,
            items: itemsData,
            totalAmount: _totalAmount,
            paymentMethod: _paymentMethod,
            paymentStatus: 'paid', // Assuming immediate payment for simplicity
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sale completed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryItems = ref.watch(inventoryItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.neutralGrey,
      appBar: AppBar(
        title: const Text('New Sale'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _submitSale,
              child: const Text('Complete Sale'),
            ),
        ],
      ),
      body: Row(
        children: [
          // Left: Item Selection
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  Expanded(
                    child: inventoryItems.when(
                      data: (items) => GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _buildItemCard(item);
                        },
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Center(child: Text('Error: $e')),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right: Cart Summary
          Container(
            width: 400,
            color: Colors.white,
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cart Summary',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeXl,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceLg),
                TextField(
                  controller: _customerController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceMd),
                DropdownButtonFormField<String>(
                  initialValue: _paymentMethod,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'card', child: Text('Card')),
                    DropdownMenuItem(
                        value: 'bank_transfer', child: Text('Bank Transfer')),
                  ],
                  onChanged: (val) => setState(() => _paymentMethod = val!),
                ),
                const SizedBox(height: AppConstants.spaceLg),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: _selectedItems.length,
                    itemBuilder: (context, index) {
                      final entry = _selectedItems[index];
                      return ListTile(
                        title: Text(entry.inventoryItem.name),
                        subtitle: Text(
                            '${entry.quantity} x \$${entry.inventoryItem.unitPrice}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('\$${entry.total.toStringAsFixed(2)}'),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                setState(() {
                                  if (entry.quantity > 1) {
                                    entry.quantity--;
                                  } else {
                                    _selectedItems.removeAt(index);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeLg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${_totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeXl,
                        fontWeight: FontWeight.bold,
                        color: AppColors.actionBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceLg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitSale,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.actionBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Text('Complete Sale'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(InventoryItem item) {
    return Card(
      child: InkWell(
        onTap: () => _addItem(item),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inventory_2,
                  size: 40, color: AppColors.actionBlue),
              const SizedBox(height: 8),
              Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text('\$${item.unitPrice}',
                  style: const TextStyle(color: AppColors.textSecondary)),
              Text('Stock: ${item.quantity}',
                  style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

class SaleItemEntry {
  final InventoryItem inventoryItem;
  double quantity;

  SaleItemEntry({required this.inventoryItem, required this.quantity});

  double get total => quantity * inventoryItem.unitPrice;
}
