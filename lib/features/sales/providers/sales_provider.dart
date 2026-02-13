import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../shared/services/nhost_service.dart';
import '../models/sale_model.dart';
import '../../inventory/providers/inventory_provider.dart';

part 'sales_provider.g.dart';

@riverpod
class Sales extends _$Sales {
  @override
  Future<List<Sale>> build() async {
    return _fetchSales();
  }

  Future<List<Sale>> _fetchSales() async {
    try {
      final query = gql(r'''
        query GetSales {
          sales(order_by: {created_at: desc}) {
            id
            business_id
            customer_name
            total_amount
            payment_status
            payment_method
            created_at
            updated_at
            items {
              id
              sale_id
              inventory_item_id
              quantity
              unit_price
              total_price
              created_at
            }
          }
        }
      ''');

      final result = await NhostService.graphqlClient.query(
        QueryOptions(
          document: query,
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      final List data = result.data?['sales'] ?? [];
      return data.map((json) => Sale.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching sales: $e');
      return [];
    }
  }

  Future<void> createSale({
    String? customerName,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    String paymentStatus = 'pending',
    String? paymentMethod,
  }) async {
    final user = NhostService.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final businessId = user.metadata?['business_id'];
    if (businessId == null) throw Exception('Business ID not found');

    try {
      final mutation = gql(r'''
        mutation CreateSale($object: sales_insert_input!) {
          insert_sales_one(object: $object) {
            id
          }
        }
      ''');

      final result = await NhostService.graphqlClient.mutate(
        MutationOptions(
          document: mutation,
          variables: {
            'object': {
              'business_id': businessId,
              'customer_name': customerName,
              'total_amount': totalAmount,
              'payment_status': paymentStatus,
              'payment_method': paymentMethod,
              'items': {
                'data': items,
              },
            },
          },
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      // Refresh inventory and sales list
      ref.invalidateSelf();
      ref.invalidate(inventoryItemsProvider);
    } catch (e) {
      debugPrint('Error creating sale: $e');
      rethrow;
    }
  }
}
