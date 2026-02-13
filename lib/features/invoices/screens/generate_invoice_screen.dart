import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../sales/models/sale_model.dart';
import '../../sales/providers/sales_provider.dart';
import '../providers/invoice_provider.dart';

class GenerateInvoiceScreen extends ConsumerStatefulWidget {
  const GenerateInvoiceScreen({super.key});

  @override
  ConsumerState<GenerateInvoiceScreen> createState() =>
      _GenerateInvoiceScreenState();
}

class _GenerateInvoiceScreenState extends ConsumerState<GenerateInvoiceScreen> {
  Sale? _selectedSale;
  final _invoiceNumberController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _invoiceNumberController.text =
        'INV-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitInvoice() async {
    if (_selectedSale == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a sale')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(invoicesProvider.notifier).createInvoice(
            saleId: _selectedSale!.id,
            invoiceNumber: _invoiceNumberController.text,
            dueDate: _dueDate,
            notes: _notesController.text,
            status: 'sent',
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice generated successfully')),
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
    final salesAsync = ref.watch(salesProvider);

    return Scaffold(
      backgroundColor: AppColors.neutralGrey,
      appBar: AppBar(
        title: const Text('Generate Invoice'),
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
              onPressed: _submitInvoice,
              child: const Text('Generate'),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceLg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Sale',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    salesAsync.when(
                      data: (sales) => DropdownButtonFormField<Sale>(
                        initialValue: _selectedSale,
                        hint: const Text('Choose a recent sale'),
                        isExpanded: true,
                        items: sales.map((sale) {
                          return DropdownMenuItem(
                            value: sale,
                            child: Text(
                              '${sale.customerName ?? "Walk-in"} - \$${sale.totalAmount} (${DateFormat('MMM dd').format(sale.createdAt!)})',
                            ),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedSale = val),
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (e, s) => Text('Error loading sales: $e'),
                    ),
                    const SizedBox(height: AppConstants.spaceLg),
                    TextField(
                      controller: _invoiceNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Invoice Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    ListTile(
                      title: const Text('Due Date'),
                      subtitle:
                          Text(DateFormat('MMM dd, yyyy').format(_dueDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _dueDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => _dueDate = picked);
                      },
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                        hintText: 'Optional notes for the customer',
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceLg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitSale,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.actionBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Generate Invoice'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitSale() {
    _submitInvoice();
  }
}
