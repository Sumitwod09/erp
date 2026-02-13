import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/sales_provider.dart';
import 'new_sale_screen.dart';

class SalesListScreen extends ConsumerWidget {
  const SalesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(salesProvider);

    return Scaffold(
      backgroundColor: AppColors.neutralGrey,
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppConstants.spaceLg),
            _buildSummaryCards(salesAsync),
            const SizedBox(height: AppConstants.spaceLg),
            Expanded(
              child: _buildSalesTable(salesAsync),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales & Invoicing',
              style: TextStyle(
                fontSize: AppConstants.fontSizeXxl,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Manage your transactions and orders',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppConstants.fontSizeSm,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewSaleScreen()),
            );
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
          label: const Text('New Sale'),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(AsyncValue salesAsync) {
    return salesAsync.when(
      data: (sales) {
        final totalSales =
            sales.fold(0.0, (sum, item) => sum + item.totalAmount);
        final paidSales = sales.where((s) => s.paymentStatus == 'paid').length;
        final pendingSales =
            sales.where((s) => s.paymentStatus == 'pending').length;

        return Row(
          children: [
            _buildStatCard(
              'Total Revenue',
              '\$${totalSales.toStringAsFixed(2)}',
              Icons.attach_money,
              AppColors.actionBlue,
            ),
            const SizedBox(width: AppConstants.spaceMd),
            _buildStatCard(
              'Paid Orders',
              paidSales.toString(),
              Icons.check_circle_outline,
              AppColors.success,
            ),
            const SizedBox(width: AppConstants.spaceMd),
            _buildStatCard(
              'Pending',
              pendingSales.toString(),
              Icons.hourglass_empty,
              AppColors.warning,
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceSm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppConstants.fontSizeSm,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeXl,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesTable(AsyncValue salesAsync) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        side: const BorderSide(color: AppColors.border),
      ),
      child: salesAsync.when(
        data: (sales) {
          if (sales.isEmpty) {
            return const Center(child: Text('No sales found'));
          }
          return SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Method')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: sales.map((sale) {
                  return DataRow(cells: [
                    DataCell(Text(DateFormat('MMM dd, yyyy')
                        .format(sale.createdAt ?? DateTime.now()))),
                    DataCell(Text(sale.customerName ?? 'Walk-in')),
                    DataCell(Text('\$${sale.totalAmount.toStringAsFixed(2)}')),
                    DataCell(_buildStatusChip(sale.paymentStatus)),
                    DataCell(Text(sale.paymentMethod ?? '-')),
                    DataCell(IconButton(
                      icon: const Icon(Icons.visibility_outlined, size: 20),
                      onPressed: () {
                        // TODO: View details
                      },
                    )),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'paid':
        color = AppColors.success;
        break;
      case 'pending':
        color = AppColors.warning;
        break;
      case 'cancelled':
        color = AppColors.error;
        break;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
