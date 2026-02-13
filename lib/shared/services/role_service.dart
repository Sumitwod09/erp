import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../shared/services/nhost_service.dart';
import '../../features/auth/models/permission_models.dart';

/// Service for managing roles and role assignments using Nhost GraphQL
class RoleService {
  /// Get all available roles
  static Future<List<Role>> getAllRoles() async {
    try {
      const query = '''
        query GetAllRoles {
          roles(order_by: [{is_system_role: desc}, {display_name: asc}]) {
            id
            name
            display_name
            description
            is_system_role
            business_id
          }
        }
      ''';

      final result = await NhostService.graphqlClient.query(
        QueryOptions(
          document: gql(query),
        ),
      );

      if (result.hasException) throw result.exception!;
      final List<dynamic> data = result.data?['roles'] as List<dynamic>? ?? [];

      return data
          .map((item) => Role.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting all roles: $e');
      return [];
    }
  }

  /// Get system roles
  static Future<List<Role>> getSystemRoles() async {
    try {
      const query = '''
        query GetSystemRoles {
          roles(
            where: {is_system_role: {_eq: true}},
            order_by: {display_name: asc}
          ) {
            id
            name
            display_name
            description
            is_system_role
            business_id
          }
        }
      ''';

      final result = await NhostService.graphqlClient.query(
        QueryOptions(
          document: gql(query),
        ),
      );

      if (result.hasException) throw result.exception!;
      final List<dynamic> data = result.data?['roles'] as List<dynamic>? ?? [];

      return data
          .map((item) => Role.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting system roles: $e');
      return [];
    }
  }

  /// Get custom roles for the current business
  static Future<List<Role>> getCustomRoles() async {
    try {
      final userId = NhostService.currentUser?.id;
      if (userId == null) return [];

      // First get the business_id for the current user
      const userQuery = '''
        query GetUserBusiness(\$userId: uuid!) {
          users_by_pk(id: \$userId) {
            business_id
          }
        }
      ''';

      final userResult = await NhostService.graphqlClient.query(
        QueryOptions(
          document: gql(userQuery),
          variables: {'userId': userId},
        ),
      );

      if (userResult.hasException) throw userResult.exception!;
      final businessId =
          userResult.data?['users_by_pk']?['business_id'] as String?;
      if (businessId == null) return [];

      const query = '''
        query GetCustomRoles(\$businessId: uuid!) {
          roles(
            where: {
              is_system_role: {_eq: false},
              business_id: {_eq: \$businessId}
            },
            order_by: {display_name: asc}
          ) {
            id
            name
            display_name
            description
            is_system_role
            business_id
          }
        }
      ''';

      final result = await NhostService.graphqlClient.query(
        QueryOptions(
          document: gql(query),
          variables: {'businessId': businessId},
        ),
      );

      if (result.hasException) throw result.exception!;
      final List<dynamic> data = result.data?['roles'] as List<dynamic>? ?? [];
      return data
          .map((item) => Role.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting custom roles: $e');
      return [];
    }
  }

  /// Get role with its permissions
  static Future<Role?> getRoleWithPermissions(String roleId) async {
    try {
      const query = '''
        query GetRoleWithPermissions(\$roleId: uuid!) {
          roles_by_pk(id: \$roleId) {
            id
            name
            display_name
            description
            is_system_role
            business_id
            role_permissions {
              permissions {
                id
                name
                resource
                action
                description
              }
            }
          }
        }
      ''';

      final result = await NhostService.graphqlClient.query(
        QueryOptions(
          document: gql(query),
          variables: {'roleId': roleId},
        ),
      );

      if (result.hasException) throw result.exception!;
      final roleData = result.data?['roles_by_pk'] as Map<String, dynamic>?;
      if (roleData == null) return null;

      final permissions = (roleData['role_permissions'] as List<dynamic>)
          .map((item) =>
              Permission.fromJson(item['permissions'] as Map<String, dynamic>))
          .toList();

      return Role(
        id: roleData['id'] as String,
        name: roleData['name'] as String,
        displayName: roleData['display_name'] as String,
        description: roleData['description'] as String?,
        isSystemRole: roleData['is_system_role'] as bool,
        businessId: roleData['business_id'] as String?,
        permissions: permissions,
      );
    } catch (e) {
      debugPrint('Error getting role with permissions: $e');
      return null;
    }
  }

  /// Assign role to a user
  static Future<void> assignRole(String userId, String roleName) async {
    try {
      const mutation = '''
        mutation AssignRole(\$userId: uuid!, \$roleName: String!) {
          update_users_by_pk(
            pk_columns: {id: \$userId},
            _set: {role: \$roleName}
          ) {
            id
          }
        }
      ''';

      final result = await NhostService.graphqlClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'userId': userId,
            'roleName': roleName,
          },
        ),
      );

      if (result.hasException) throw result.exception!;
    } catch (e) {
      debugPrint('Error assigning role: $e');
      rethrow;
    }
  }

  /// Create a custom role (admin only)
  static Future<String?> createCustomRole({
    required String name,
    required String displayName,
    String? description,
  }) async {
    try {
      final userId = NhostService.currentUser?.id;
      if (userId == null) return null;

      // Get the business_id for the current user
      const userQuery = '''
        query GetUserBusiness(\$userId: uuid!) {
          users_by_pk(id: \$userId) {
            business_id
          }
        }
      ''';

      final userResult = await NhostService.graphqlClient.query(
        QueryOptions(
          document: gql(userQuery),
          variables: {'userId': userId},
        ),
      );

      if (userResult.hasException) throw userResult.exception!;
      final businessId =
          userResult.data?['users_by_pk']?['business_id'] as String?;
      if (businessId == null) return null;

      const mutation = '''
        mutation CreateCustomRole(
          \$name: String!,
          \$displayName: String!,
          \$description: String,
          \$businessId: uuid!
        ) {
          insert_roles_one(object: {
            name: \$name,
            display_name: \$displayName,
            description: \$description,
            is_system_role: false,
            business_id: \$businessId
          }) {
            id
          }
        }
      ''';

      final result = await NhostService.graphqlClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'name': name,
            'displayName': displayName,
            'description': description,
            'businessId': businessId,
          },
        ),
      );

      if (result.hasException) throw result.exception!;
      return result.data?['insert_roles_one']?['id'] as String?;
    } catch (e) {
      debugPrint('Error creating custom role: $e');
      rethrow;
    }
  }

  /// Update role details
  static Future<void> updateRole({
    required String roleId,
    String? displayName,
    String? description,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (description != null) updates['description'] = description;

      if (updates.isNotEmpty) {
        const mutation = '''
          mutation UpdateRole(\$roleId: uuid!, \$updates: roles_set_input!) {
            update_roles_by_pk(
              pk_columns: {id: \$roleId},
              _set: \$updates
            ) {
              id
            }
          }
        ''';

        final result = await NhostService.graphqlClient.mutate(
          MutationOptions(
            document: gql(mutation),
            variables: {
              'roleId': roleId,
              'updates': updates,
            },
          ),
        );

        if (result.hasException) throw result.exception!;
      }
    } catch (e) {
      debugPrint('Error updating role: $e');
      rethrow;
    }
  }

  /// Delete a custom role
  static Future<void> deleteRole(String roleId) async {
    try {
      const mutation = '''
        mutation DeleteRole(\$roleId: uuid!) {
          delete_roles_by_pk(id: \$roleId) {
            id
          }
        }
      ''';

      final result = await NhostService.graphqlClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {'roleId': roleId},
        ),
      );

      if (result.hasException) throw result.exception!;
    } catch (e) {
      debugPrint('Error deleting role: $e');
      rethrow;
    }
  }

  /// Update role permissions
  static Future<void> updateRolePermissions(
    String roleId,
    List<String> permissionIds,
  ) async {
    try {
      // Delete existing permissions
      const deleteMutation = '''
        mutation DeleteRolePermissions(\$roleId: uuid!) {
          delete_role_permissions(where: {role_id: {_eq: \$roleId}}) {
            affected_rows
          }
        }
      ''';

      final deleteResult = await NhostService.graphqlClient.mutate(
        MutationOptions(
          document: gql(deleteMutation),
          variables: {'roleId': roleId},
        ),
      );

      if (deleteResult.hasException) throw deleteResult.exception!;

      // Insert new permissions
      if (permissionIds.isNotEmpty) {
        final inserts = permissionIds
            .map((permId) => {
                  'role_id': roleId,
                  'permission_id': permId,
                })
            .toList();

        const insertMutation = '''
          mutation InsertRolePermissions(\$objects: [role_permissions_insert_input!]!) {
            insert_role_permissions(objects: \$objects) {
              affected_rows
            }
          }
        ''';

        final result = await NhostService.graphqlClient.mutate(
          MutationOptions(
            document: gql(insertMutation),
            variables: {'objects': inserts},
          ),
        );

        if (result.hasException) throw result.exception!;
      }
    } catch (e) {
      debugPrint('Error updating role permissions: $e');
      rethrow;
    }
  }

  /// Get all users in the current business with their roles
  static Future<List<Map<String, dynamic>>> getBusinessUsers() async {
    try {
      final userId = NhostService.currentUser?.id;
      if (userId == null) return [];

      // Get the business_id for the current user
      const userQuery = '''
        query GetUserBusiness(\$userId: uuid!) {
          users_by_pk(id: \$userId) {
            business_id
          }
        }
      ''';

      final userResult = await NhostService.graphqlClient.query(
        QueryOptions(
          document: gql(userQuery),
          variables: {'userId': userId},
        ),
      );

      if (userResult.hasException) throw userResult.exception!;
      final businessId =
          userResult.data?['users_by_pk']?['business_id'] as String?;
      if (businessId == null) return [];

      const query = '''
        query GetBusinessUsers(\$businessId: uuid!) {
          users(
            where: {business_id: {_eq: \$businessId}},
            order_by: {created_at: desc}
          ) {
            id
            email
            role
            created_at
          }
        }
      ''';

      final result = await NhostService.graphqlClient.query(
        QueryOptions(
          document: gql(query),
          variables: {'businessId': businessId},
        ),
      );

      if (result.hasException) throw result.exception!;

      return (result.data?['users'] as List<dynamic>? ?? [])
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('Error getting business users: $e');
      return [];
    }
  }
}
