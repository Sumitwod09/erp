import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../shared/services/nhost_service.dart';
import '../models/invoice_model.dart';

part 'invoice_provider.g.dart';

@riverpod
class Invoices extends _$Invoices {
  @override
  Future<List<Invoice>> build() async {
    return _fetchInvoices();
  }

  Future<List<Invoice>> _fetchInvoices() async {
    try {
      const query = r'''
        query GetInvoices {
          invoices(order_by: {created_at: desc}) {
            id
            business_id
            sale_id
            invoice_number
            due_date
            status
            notes
            created_at
            updated_at
          }
        }
      ''';

      final result = await NhostService.graphqlClient.query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      final List data = result.data?['invoices'] ?? [];
      return data.map((json) => Invoice.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching invoices: $e');
      return [];
    }
  }

  Future<void> createInvoice({
    String? saleId,
    required String invoiceNumber,
    DateTime? dueDate,
    String status = 'draft',
    String? notes,
  }) async {
    final user = NhostService.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final businessId = user.metadata?['business_id'];
    if (businessId == null) throw Exception('Business ID not found');

    try {
      const mutation = r'''
        mutation CreateInvoice($object: invoices_insert_input!) {
          insert_invoices_one(object: $object) {
            id
          }
        }
      ''';

      final result = await NhostService.graphqlClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'object': {
              'business_id': businessId,
              'sale_id': saleId,
              'invoice_number': invoiceNumber,
              'due_date': dueDate?.toIso8601String(),
              'status': status,
              'notes': notes,
            },
          },
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Error creating invoice: $e');
      rethrow;
    }
  }

  Future<void> updateInvoiceStatus(String id, String status) async {
    try {
      const mutation = r'''
        mutation UpdateInvoiceStatus($id: uuid!, $status: String!) {
          update_invoices_by_pk(pk_columns: {id: $id}, _set: {status: $status}) {
            id
          }
        }
      ''';

      final result = await NhostService.graphqlClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {'id': id, 'status': status},
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Error updating invoice status: $e');
      rethrow;
    }
  }
}
