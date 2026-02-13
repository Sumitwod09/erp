import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../services/nhost_service.dart';
import '../models/module_model.dart';
import '../../core/constants/app_constants.dart';

part 'active_modules_provider.g.dart';

/// Provider for active modules based on business subscriptions
@riverpod
class ActiveModules extends _$ActiveModules {
  @override
  Future<List<ModuleModel>> build() async {
    // Get current user
    final user = NhostService.currentUser;
    if (user == null) {
      return [];
    }

    try {
      // Get user's business ID and active modules using GraphQL
      final queryDoc = gql('''
        query GetActiveModules(\$userId: uuid!) {
          ${AppConstants.usersTable}(where: {id: {_eq: \$userId}}) {
            business_id
            business {
              business_subscriptions(where: {is_active: {_eq: true}}) {
                module_name
                module {
                  id
                  name
                  display_name
                  description
                  icon
                  route
                }
              }
            }
          }
        }
      ''');

      final result = await NhostService.graphqlClient.query(
        QueryOptions(
          document: queryDoc,
          variables: {'userId': user.id},
        ),
      );

      if (result.hasException) {
        print('GraphQL error: ${result.exception}');
        return [];
      }

      final data = result.data;
      if (data == null) return [];

      final List<dynamic> users =
          data[AppConstants.usersTable] as List<dynamic>;
      if (users.isEmpty) {
        return [];
      }

      final userData = users.first as Map<String, dynamic>;
      final business = userData['business'] as Map<String, dynamic>?;
      if (business == null) {
        return [];
      }

      final List<dynamic> subscriptions =
          business['business_subscriptions'] as List<dynamic>;

      return subscriptions
          .map((sub) {
            final moduleData = sub['module'] as Map<String, dynamic>?;
            if (moduleData == null) return null;
            return ModuleModel.fromJson(moduleData);
          })
          .whereType<ModuleModel>()
          .toList();
    } catch (e) {
      print('Error loading active modules: $e');
      return [];
    }
  }

  /// Toggle module activation
  Future<void> toggleModule(String moduleName, bool activate) async {
    final user = NhostService.currentUser;
    if (user == null) return;

    try {
      // Get user's business ID using GraphQL
      final userQueryDoc = gql('''
        query GetUserBusiness(\$userId: uuid!) {
          ${AppConstants.usersTable}(where: {id: {_eq: \$userId}}) {
            business_id
          }
        }
      ''');

      final userResult = await NhostService.graphqlClient.query(
        QueryOptions(
          document: userQueryDoc,
          variables: {'userId': user.id},
        ),
      );

      if (userResult.hasException) {
        print('GraphQL error getting user: ${userResult.exception}');
        return;
      }

      final userData = userResult.data;
      if (userData == null) return;

      final List<dynamic> users =
          userData[AppConstants.usersTable] as List<dynamic>;
      if (users.isEmpty) return;

      final businessId = users.first['business_id'] as String;

      // Upsert subscription using GraphQL mutation
      final mutationDoc = gql('''
        mutation UpsertSubscription(\$businessId: uuid!, \$moduleName: String!, \$isActive: Boolean!, \$activatedAt: timestamptz) {
          insert_${AppConstants.businessSubscriptionsTable}_one(
            object: {
              business_id: \$businessId,
              module_name: \$moduleName,
              is_active: \$isActive,
              activated_at: \$activatedAt
            },
            on_conflict: {
              constraint: ${AppConstants.businessSubscriptionsTable}_pkey,
              update_columns: [is_active, activated_at]
            }
          ) {
            business_id
            module_name
          }
        }
      ''');

      await NhostService.graphqlClient.mutate(
        MutationOptions(
          document: mutationDoc,
          variables: {
            'businessId': businessId,
            'moduleName': moduleName,
            'isActive': activate,
            'activatedAt': activate ? DateTime.now().toIso8601String() : null,
          },
        ),
      );

      // Manually refresh the state
      ref.invalidateSelf();
    } catch (e) {
      print('Error toggling module: $e');
    }
  }
}
