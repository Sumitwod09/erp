import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/app_constants.dart';
import '../services/nhost_service.dart';

part 'module_settings_provider.g.dart';

@riverpod
class ModuleSettings extends _$ModuleSettings {
  @override
  Future<Map<String, dynamic>> build(String moduleId) async {
    final user = NhostService.currentUser;
    if (user == null) return {};

    try {
      final query = gql('''
        query GetModuleSettings(\$userId: uuid!, \$moduleName: String!) {
          ${AppConstants.usersTable}(where: {id: {_eq: \$userId}}) {
            business {
              business_subscriptions(where: {module_name: {_eq: \$moduleName}}) {
                settings
              }
            }
          }
        }
      ''');

      final result = await NhostService.graphqlClient.query(
        QueryOptions(
          document: query,
          variables: {
            'userId': user.id,
            'moduleName': _getModuleNameFromId(moduleId),
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      final data = result.data;
      if (data == null) return {};

      final users = data[AppConstants.usersTable] as List;
      if (users.isEmpty) return {};

      final business = users.first['business'];
      if (business == null) return {};

      final subscriptions = business['business_subscriptions'] as List;
      if (subscriptions.isEmpty) return {};

      final settings = subscriptions.first['settings'];
      return settings != null ? Map<String, dynamic>.from(settings) : {};
    } catch (e) {
      print('Error fetching module settings: $e');
      return {};
    }
  }

  Future<void> updateSettings(
      String moduleId, Map<String, dynamic> newSettings) async {
    final user = NhostService.currentUser;
    if (user == null) return;

    // Optimistic update
    state = AsyncData(newSettings);

    try {
      // 1. Get business ID
      final userQuery = gql('''
        query GetBusinessId(\$userId: uuid!) {
          ${AppConstants.usersTable}(where: {id: {_eq: \$userId}}) {
            business_id
          }
        }
      ''');

      final userResult = await NhostService.graphqlClient.query(
        QueryOptions(
          document: userQuery,
          variables: {'userId': user.id},
        ),
      );

      final businessId =
          userResult.data?[AppConstants.usersTable][0]['business_id'];
      if (businessId == null) throw Exception('Business not found');

      // 2. Update settings
      final mutation = gql('''
        mutation UpdateModuleSettings(\$businessId: uuid!, \$moduleName: String!, \$settings: jsonb!) {
          update_${AppConstants.businessSubscriptionsTable}(
            where: {
              business_id: {_eq: \$businessId},
              module_name: {_eq: \$moduleName}
            },
            _set: {
              settings: \$settings
            }
          ) {
            affected_rows
          }
        }
      ''');

      final result = await NhostService.graphqlClient.mutate(
        MutationOptions(
          document: mutation,
          variables: {
            'businessId': businessId,
            'moduleName': _getModuleNameFromId(moduleId),
            'settings': newSettings,
          },
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }
    } catch (e) {
      print('Error updating settings: $e');
      // Revert optimization on error (reload)
      ref.invalidateSelf();
      rethrow;
    }
  }

  // Helper to map route IDs to module names (if they differ)
  // Currently they are mostly same but valid to check
  String _getModuleNameFromId(String id) {
    // This mapping should match what's in the DB
    switch (id) {
      case 'inventory':
        return 'Inventory';
      case 'sales':
        return 'Sales';
      case 'accounting':
        return 'Accounting';
      case 'crm':
        return 'CRM';
      case 'hrm':
        return 'HRM';
      case 'manufacturing':
        return 'Manufacturing';
      case 'invoice':
        return 'Invoice';
      default:
        return id; // Fallback
    }
  }
}
