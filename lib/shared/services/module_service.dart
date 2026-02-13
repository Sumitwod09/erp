import 'package:graphql_flutter/graphql_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../models/module_model.dart';
import 'nhost_service.dart';

class ModuleService {
  /// Get list of system available modules
  /// In a real app, this might come from a 'modules' table
  static List<ModuleModel> getSystemModules() {
    return [
      const ModuleModel(
        id: 'inventory',
        name: 'Inventory',
        category: 'Operations',
        icon: 'inventory',
        route: '/inventory',
        description: 'Manage products, stock levels, and warehouses.',
      ),
      const ModuleModel(
        id: 'sales',
        name: 'Sales',
        category: 'Revenue',
        icon: 'sales',
        route: '/sales',
        description: 'Create quotes, invoices, and manage customers.',
      ),
      const ModuleModel(
        id: 'accounting',
        name: 'Accounting',
        category: 'Finance',
        icon: 'accounting',
        route: '/accounting',
        description: 'General ledger, expense tracking, and financial reports.',
      ),
      const ModuleModel(
        id: 'crm',
        name: 'CRM',
        category: 'Sales',
        icon: 'crm',
        route: '/crm',
        description: 'Track leads, opportunities, and customer interactions.',
      ),
      const ModuleModel(
        id: 'hrm',
        name: 'HRM',
        category: 'Human Resources',
        icon: 'hrm',
        route: '/hrm',
        description: 'Employee management, payroll, and attendance.',
      ),
      const ModuleModel(
        id: 'manufacturing',
        name: 'Manufacturing',
        category: 'Operations',
        icon: 'manufacturing',
        route: '/manufacturing',
        description: 'Production planning, BOMs, and work orders.',
      ),
      const ModuleModel(
        id: 'invoice',
        name: 'Invoice',
        category: 'Finance',
        icon: 'receipt_long',
        route: '/invoices',
        description: 'Create and manage customer invoices and receipts.',
      ),
    ];
  }

  /// Toggle module active status for the current business
  static Future<void> toggleModule({
    required String moduleName,
    required bool isActive,
  }) async {
    final user = NhostService.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get Business ID
    final userQuery = gql('''
      query GetBusinessId(\$id: uuid!) {
        ${AppConstants.usersTable}_by_pk(id: \$id) {
          business_id
        }
      }
    ''');

    final userResult = await NhostService.graphqlClient.query(
      QueryOptions(document: userQuery, variables: {'id': user.id}),
    );

    final businessId =
        userResult.data?['${AppConstants.usersTable}_by_pk']['business_id'];

    if (businessId == null) throw Exception('No business found for user');

    // Upsert subscription
    // If it exists, update is_active. If not, insert it.
    final mutation = gql('''
      mutation UpsertSubscription(\$business_id: uuid!, \$module_name: String!, \$is_active: Boolean!) {
        insert_${AppConstants.businessSubscriptionsTable}_one(
          object: {
            business_id: \$business_id,
            module_name: \$module_name,
            is_active: \$is_active,
            activated_at: "now()"
          },
          on_conflict: {
            constraint: ${AppConstants.businessSubscriptionsTable}_pkey,
            update_columns: [is_active]
          }
        ) {
          id
          is_active
        }
      }
    ''');

    final result = await NhostService.graphqlClient.mutate(
      MutationOptions(
        document: mutation,
        variables: {
          'business_id': businessId,
          'module_name': moduleName,
          'is_active': isActive,
        },
      ),
    );

    if (result.hasException) {
      throw Exception('Failed to toggle module: ${result.exception}');
    }
  }
}
