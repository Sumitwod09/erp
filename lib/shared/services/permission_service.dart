import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../shared/services/nhost_service.dart';
import '../../features/auth/models/permission_models.dart';

/// Service for checking and managing permissions using Nhost GraphQL
class PermissionService {
  /// Check if the current user has a specific permission
  static Future<bool> hasPermission(String permissionName) async {
    final userId = NhostService.currentUser?.id;
    if (userId == null) return false;

    try {
      // Call PostgreSQL function via GraphQL
      const query = '''
        query HasPermission(\$userId: uuid!, \$permissionName: String!) {
          has_permission(args: {p_user_id: \$userId, p_permission_name: \$permissionName})
        }
      ''';

      final result = await NhostService.graphqlClient.query(
        QueryOptions(
          document: gql(query),
          variables: {
            'userId': userId,
            'permissionName': permissionName,
          },
        ),
      );

      if (result.hasException) throw result.exception!;
      return result.data?['has_permission'] as bool? ?? false;
    } catch (e) {
      debugPrint('Error checking permission: $e');
      return false;
    }
  }

  /// Check if the current user can access a resource with a specific action
  static Future<bool> canAccess(String resource, String action) async {
    final permissionName = '$resource.$action';
    return hasPermission(permissionName);
  }

  /// Check if the current user can access a resource with a specific action (typed)
  static Future<bool> canAccessTyped(
    Resource resource,
    PermissionAction action,
  ) async {
    return hasPermission(PermissionNames.build(resource, action));
  }

  /// Get all permissions for the current user
  static Future<List<Permission>> getUserPermissions() async {
    final userId = NhostService.currentUser?.id;
    if (userId == null) return [];

    try {
      // Call PostgreSQL function via GraphQL
      const query = '''
        query GetUserPermissions(\$userId: uuid!) {
          get_user_permissions(args: {p_user_id: \$userId}) {
            permission_name
            resource
            action
          }
        }
      ''';

      final result = await NhostService.graphqlClient.query(
        QueryOptions(
          document: gql(query),
          variables: {'userId': userId},
        ),
      );

      if (result.hasException) throw result.exception!;

      final List<dynamic> data =
          result.data?['get_user_permissions'] as List<dynamic>? ?? [];
      return data
          .map((item) => Permission(
                id: '',
                name: item['permission_name'] as String,
                resource: item['resource'] as String,
                action: item['action'] as String,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error getting user permissions: $e');
      return [];
    }
  }

  /// Get the current user's role
  static Future<UserRole?> getUserRole() async {
    final userId = NhostService.currentUser?.id;
    if (userId == null) return null;

    try {
      // Call PostgreSQL function via GraphQL
      const query = '''
        query GetUserRole(\$userId: uuid!) {
          get_user_role(args: {p_user_id: \$userId}) {
            role_name
            display_name
            description
          }
        }
      ''';

      final result = await NhostService.graphqlClient.query(
        QueryOptions(
          document: gql(query),
          variables: {'userId': userId},
        ),
      );

      if (result.hasException) throw result.exception!;

      final data = result.data?['get_user_role'];
      if (data != null && data is List && data.isNotEmpty) {
        final roleData = data.first as Map<String, dynamic>;
        final permissions = await getUserPermissions();

        return UserRole(
          roleName: roleData['role_name'] as String,
          displayName: roleData['display_name'] as String,
          description: roleData['description'] as String?,
          permissions: permissions,
        );
      }

      return null;
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return null;
    }
  }

  /// Get all available permissions (for admin use)
  static Future<List<Permission>> getAllPermissions() async {
    try {
      const query = '''
        query GetAllPermissions {
          permissions(order_by: {resource: asc, action: asc}) {
            id
            name
            resource
            action
            description
          }
        }
      ''';

      final result = await NhostService.graphqlClient.query(
        QueryOptions(
          document: gql(query),
        ),
      );

      if (result.hasException) throw result.exception!;
      final List<dynamic> data =
          result.data?['permissions'] as List<dynamic>? ?? [];

      return data
          .map((item) => Permission.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting all permissions: $e');
      return [];
    }
  }

  /// Check multiple permissions at once
  static Future<Map<String, bool>> checkMultiplePermissions(
    List<String> permissionNames,
  ) async {
    final results = <String, bool>{};

    for (final permissionName in permissionNames) {
      results[permissionName] = await hasPermission(permissionName);
    }

    return results;
  }

  /// Grant custom permission to a user (admin only)
  static Future<void> grantPermission(
    String userId,
    String permissionId,
  ) async {
    try {
      const mutation = '''
        mutation GrantPermission(\$userId: uuid!, \$permissionId: uuid!) {
          insert_user_custom_permissions_one(
            object: {
              user_id: \$userId,
              permission_id: \$permissionId,
              granted: true
            },
            on_conflict: {
              constraint: user_custom_permissions_pkey,
              update_columns: [granted]
            }
          ) {
            user_id
          }
        }
      ''';

      final result = await NhostService.graphqlClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'userId': userId,
            'permissionId': permissionId,
          },
        ),
      );

      if (result.hasException) throw result.exception!;
    } catch (e) {
      debugPrint('Error granting permission: $e');
      rethrow;
    }
  }

  /// Revoke custom permission from a user (admin only)
  static Future<void> revokePermission(
    String userId,
    String permissionId,
  ) async {
    try {
      const mutation = '''
        mutation RevokePermission(\$userId: uuid!, \$permissionId: uuid!) {
          insert_user_custom_permissions_one(
            object: {
              user_id: \$userId,
              permission_id: \$permissionId,
              granted: false
            },
            on_conflict: {
              constraint: user_custom_permissions_pkey,
              update_columns: [granted]
            }
          ) {
            user_id
          }
        }
      ''';

      final result = await NhostService.graphqlClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'userId': userId,
            'permissionId': permissionId,
          },
        ),
      );

      if (result.hasException) throw result.exception!;
    } catch (e) {
      debugPrint('Error revoking permission: $e');
      rethrow;
    }
  }

  /// Remove custom permission override (revert to role default)
  static Future<void> removeCustomPermission(
    String userId,
    String permissionId,
  ) async {
    try {
      const mutation = '''
        mutation RemoveCustomPermission(\$userId: uuid!, \$permissionId: uuid!) {
          delete_user_custom_permissions(
            where: {
              user_id: {_eq: \$userId},
              permission_id: {_eq: \$permissionId}
            }
          ) {
            affected_rows
          }
        }
      ''';

      final result = await NhostService.graphqlClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'userId': userId,
            'permissionId': permissionId,
          },
        ),
      );

      if (result.hasException) throw result.exception!;
    } catch (e) {
      debugPrint('Error removing custom permission: $e');
      rethrow;
    }
  }

  /// Get custom permissions for a user
  static Future<List<Map<String, dynamic>>> getCustomPermissions(
    String userId,
  ) async {
    try {
      const query = '''
        query GetCustomPermissions(\$userId: uuid!) {
          user_custom_permissions(where: {user_id: {_eq: \$userId}}) {
            user_id
            permission_id
            granted
            permissions {
              id
              name
              resource
              action
              description
            }
          }
        }
      ''';

      final result = await NhostService.graphqlClient.query(
        QueryOptions(
          document: gql(query),
          variables: {'userId': userId},
        ),
      );

      if (result.hasException) throw result.exception!;

      return (result.data?['user_custom_permissions'] as List<dynamic>? ?? [])
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('Error getting custom permissions: $e');
      return [];
    }
  }
}
