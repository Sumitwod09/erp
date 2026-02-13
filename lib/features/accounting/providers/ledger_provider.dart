import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../shared/services/nhost_service.dart';
import '../models/ledger_model.dart';

part 'ledger_provider.g.dart';

@riverpod
class Ledger extends _$Ledger {
  @override
  Future<List<LedgerEntry>> build() async {
    return _fetchEntries();
  }

  Future<List<LedgerEntry>> _fetchEntries() async {
    try {
      const query = r'''
        query GetLedger {
          accounting_ledger(order_by: {date: desc}) {
            id
            business_id
            date
            description
            amount
            type
            category
            reference_id
            created_at
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

      final List data = result.data?['accounting_ledger'] ?? [];
      return data.map((json) => LedgerEntry.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching ledger: $e');
      return [];
    }
  }

  Future<void> addEntry({
    required DateTime date,
    required String description,
    required double amount,
    required String type,
    required String category,
    String? referenceId,
  }) async {
    final user = NhostService.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final businessId = user.metadata?['business_id'];
    if (businessId == null) throw Exception('Business ID not found');

    try {
      const mutation = r'''
        mutation InsertLedgerEntry($object: accounting_ledger_insert_input!) {
          insert_accounting_ledger_one(object: $object) {
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
              'date': date.toIso8601String(),
              'description': description,
              'amount': amount,
              'type': type,
              'category': category,
              'reference_id': referenceId,
            },
          },
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Error adding ledger entry: $e');
      rethrow;
    }
  }
}
