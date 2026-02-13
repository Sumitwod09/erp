import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/services/nhost_service.dart';
import '../models/inventory_item_model.dart';

part 'inventory_provider.g.dart';

@riverpod
class InventoryItems extends _$InventoryItems {
  @override
  Future<List<InventoryItem>> build() async {
    return _fetchItems();
  }

  Future<List<InventoryItem>> _fetchItems() async {
    final user = NhostService.currentUser;
    if (user == null) return [];

    try {
      final query = gql('''
        query GetInventoryItems(\$userId: uuid!) {
          inventory_items(where: {
            business: {
              users: {
                id: {_eq: \$userId}
              }
            }
          }, order_by: {created_at: desc}) {
            id
            business_id
            name
            sku
            description
            quantity
            unit_price
            reorder_level
            created_at
            updated_at
          }
        }
      ''');

      final result = await NhostService.graphqlClient.query(
        QueryOptions(
          document: query,
          variables: {'userId': user.id},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      final data = result.data?['inventory_items'] as List?;
      if (data == null) return [];

      return data
          .map((json) => InventoryItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching inventory items: $e');
      return [];
    }
  }

  Future<void> addItem(Map<String, dynamic> itemData) async {
    final user = NhostService.currentUser;
    if (user == null) return;

    try {
      // Get business ID first (could be cached or passed)
      final userQuery = gql('''
        query GetBusinessId(\$userId: uuid!) {
          users(where: {id: {_eq: \$userId}}) {
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

      final businessId = userResult.data?['users'][0]['business_id'];
      if (businessId == null) throw Exception('Business not found');

      final mutation = gql('''
        mutation InsertInventoryItem(\$object: inventory_items_insert_input!) {
          insert_inventory_items_one(object: \$object) {
            id
          }
        }
      ''');

      final result = await NhostService.graphqlClient.mutate(
        MutationOptions(
          document: mutation,
          variables: {
            'object': {
              ...itemData,
              'business_id': businessId,
            }
          },
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      // Refresh list
      ref.invalidateSelf();
    } catch (e) {
      print('Error adding inventory item: $e');
      rethrow;
    }
  }

  Future<void> updateItem(String id, Map<String, dynamic> updates) async {
    try {
      final mutation = gql('''
        mutation UpdateInventoryItem(\$id: uuid!, \$updates: inventory_items_set_input!) {
          update_inventory_items_by_pk(pk_columns: {id: \$id}, _set: \$updates) {
            id
          }
        }
      ''');

      final result = await NhostService.graphqlClient.mutate(
        MutationOptions(
          document: mutation,
          variables: {
            'id': id,
            'updates': updates,
          },
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      ref.invalidateSelf();
    } catch (e) {
      print('Error updating inventory item: $e');
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      final mutation = gql('''
        mutation DeleteInventoryItem(\$id: uuid!) {
          delete_inventory_items_by_pk(id: \$id) {
            id
          }
        }
      ''');

      final result = await NhostService.graphqlClient.mutate(
        MutationOptions(
          document: mutation,
          variables: {'id': id},
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      ref.invalidateSelf();
    } catch (e) {
      print('Error deleting inventory item: $e');
      rethrow;
    }
  }
}
