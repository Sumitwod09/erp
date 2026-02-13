import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/models/permission_models.dart';
import '../../../shared/widgets/buttons/permission_button.dart';
import '../../../shared/widgets/guards/permission_guard.dart';
import '../providers/ledger_provider.dart';

class LedgerScreen extends ConsumerWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgerAsync = ref.watch(ledgerProvider);

    return Scaffold(
      backgroundColor: AppColors.neutralGrey,
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref),
            const SizedBox(height: AppConstants.spaceLg),
            _buildSummary(ledgerAsync),
            const SizedBox(height: AppConstants.spaceLg),
            Expanded(
              child: _buildLedgerTable(ledgerAsync),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Accounting Ledger',
          style: TextStyle(
            fontSize: AppConstants.fontSizeXxl,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Row(
          children: [
            PermissionButton(
              permission: PermissionNames.accountingWrite,
              onPressed: () {
                // TODO: Open Create Ledger Entry Dialog
              },
              child: const Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Create Entry'),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spaceSm),
            PermissionIconButton(
              permission: PermissionNames.accountingManage,
              hideIfNoPermission: true,
              icon: const Icon(Icons.settings),
              tooltip: 'Manage Accounting Settings',
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummary(AsyncValue ledgerAsync) {
    return ledgerAsync.when(
      data: (entries) {
        final income = entries
            .where((e) => e.type == 'credit')
            .fold(0.0, (sum, e) => sum + e.amount);
        final expenses = entries
            .where((e) => e.type == 'debit')
            .fold(0.0, (sum, e) => sum + e.amount);
        final balance = income - expenses;

        return Row(
          children: [
            _buildSummaryItem('Total Income', income, AppColors.success),
            const SizedBox(width: AppConstants.spaceMd),
            _buildSummaryItem('Total Expenses', expenses, AppColors.error),
            const SizedBox(width: AppConstants.spaceMd),
            _buildSummaryItem('Net Balance', balance, AppColors.actionBlue),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLedgerTable(AsyncValue ledgerAsync) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: PermissionGuard(
        permission: PermissionNames.accountingRead,
        showFallback: true,
        child: ledgerAsync.when(
          data: (entries) {
            if (entries.isEmpty) {
              return const Center(child: Text('No entries found'));
            }
            return SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Amount')),
                  ],
                  rows: entries.map((entry) {
                    final isCredit = entry.type == 'credit';
                    return DataRow(cells: [
                      DataCell(
                          Text(DateFormat('MMM dd, yyyy').format(entry.date))),
                      DataCell(Text(entry.description)),
                      DataCell(Text(entry.category)),
                      DataCell(Text(
                        entry.type.toUpperCase(),
                        style: TextStyle(
                            color:
                                isCredit ? AppColors.success : AppColors.error),
                      )),
                      DataCell(Text(
                        '${isCredit ? '+' : '-'}\$${entry.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isCredit ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
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
      ),
    );
  }
}
