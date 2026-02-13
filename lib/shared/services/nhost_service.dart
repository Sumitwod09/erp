import 'package:flutter/foundation.dart';
import 'package:nhost_flutter_auth/nhost_flutter_auth.dart';
import 'package:nhost_sdk/nhost_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

/// Nhost service for database and authentication operations
class NhostService {
  static NhostClient? _client;
  static GraphQLClient? _graphqlClient;

  /// Initialize Nhost client
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
      debugPrint('✓ Environment file loaded successfully');

      final nhostSubdomain = dotenv.env['NHOST_SUBDOMAIN'];
      final nhostRegion = dotenv.env['NHOST_REGION'];

      debugPrint(
          'Nhost Subdomain: ${nhostSubdomain != null ? "Found" : "NOT FOUND"}');
      debugPrint(
          'Nhost Region: ${nhostRegion != null ? "Found" : "NOT FOUND"}');

      if (nhostSubdomain == null || nhostRegion == null) {
        throw Exception(
          'Nhost credentials not found in .env file. '
          'Please ensure NHOST_SUBDOMAIN and NHOST_REGION are set correctly.',
        );
      }

      _client = NhostClient(
        subdomain: Subdomain(
          subdomain: nhostSubdomain,
          region: nhostRegion,
        ),
      );

      // Initialize GraphQL client
      final graphQLEndpoint = 'https://$nhostSubdomain.nhost.run/v1/graphql';

      _graphqlClient = GraphQLClient(
        link: HttpLink(graphQLEndpoint),
        cache: GraphQLCache(),
      );

      debugPrint('✓ Nhost initialized successfully');
    } catch (e) {
      debugPrint('✗ Nhost initialization failed: $e');
      rethrow;
    }
  }

  /// Get Nhost client instance
  static NhostClient get client {
    if (_client == null) {
      throw Exception('Nhost not initialized. Call initialize() first.');
    }
    return _client!;
  }

  /// Get GraphQL client for database operations
  static GraphQLClient get graphqlClient {
    if (_graphqlClient == null) {
      throw Exception('Nhost not initialized. Call initialize() first.');
    }
    return _graphqlClient!;
  }

  /// Get authenticated user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
}
