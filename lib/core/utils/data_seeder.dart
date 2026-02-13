import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../shared/services/nhost_service.dart';
import '../constants/app_constants.dart';

class DataSeeder {
  static const String _password = 'password123';
  static const String _adminEmail = 'admin@test.com';
  static const String _businessName = 'Test Company';

  static const List<String> _roles = [
    'manager',
    'accountant',
    'sales',
    'inventory',
    'warehouse',
    'manufacturing',
    'admin' // Ensure admin is also in the loop if needed, but handled separately
  ];

  /// Seed test users
  static Future<void> seedUsers(
      {String? adminEmail, String? adminPassword}) async {
    try {
      debugPrint('🌱 Starting data seeding...');

      // 1. Ensure Admin exists and get Business ID
      String businessId = await _setupAdminAndBusiness(
        email: adminEmail,
        password: adminPassword,
      );
      debugPrint('🏢 Using Business ID: $businessId');

      // 2. Create other roles
      for (final role in _roles) {
        if (role == 'admin') continue; // Already handled

        final email = '$role@test.com';
        debugPrint('👤 Processing $role ($email)...');

        await _createRoleUser(email, role, businessId);
      }

      // 3. Sign out to leave clean state
      await NhostService.client.auth.signOut();
      debugPrint('✅ Seeding complete!');
    } catch (e) {
      debugPrint('❌ Seeding failed: $e');
      rethrow;
    }
  }

  static Future<String> _setupAdminAndBusiness(
      {String? email, String? password}) async {
    final targetEmail = email ?? _adminEmail;
    final targetPassword = password ?? _password;

    // Try to login as admin
    try {
      await NhostService.client.auth.signOut(); // Ensure clean start

      try {
        await NhostService.client.auth.signInEmailPassword(
          email: targetEmail,
          password: targetPassword,
        );
      } catch (e) {
        // If login fails, try to sign up ONLY if using default credentials or purely to create new
        debugPrint('Admin login failed ($e), attempting signup...');

        try {
          final response = await NhostService.client.auth.signUp(
            email: targetEmail,
            password: targetPassword,
            metadata: {'full_name': 'Test Admin'},
          );

          if (response.session == null) {
            // Try sign in again just in case
            await NhostService.client.auth.signInEmailPassword(
              email: targetEmail,
              password: targetPassword,
            );
          }
        } catch (signupError) {
          // If signup fails (e.g. email in use), and login failed, we have a problem.
          // Likely wrong password for existing user.
          throw Exception(
              'Could not login or signup as $targetEmail. If the user exists, please ensure you are using the correct password. Error: $signupError');
        }
      }

      // Now we are logged in as admin. Check if we have a business_id in 'users' table.
      final userId = NhostService.client.auth.currentUser!.id;

      // Query user profile
      final userQuery = gql('''
        query GetUser(\$id: uuid!) {
          ${AppConstants.usersTable}_by_pk(id: \$id) {
            business_id
          }
        }
      ''');

      final userResult = await NhostService.graphqlClient.query(
        QueryOptions(
          document: userQuery,
          variables: {'id': userId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (userResult.hasException) {
        throw Exception(
            'Failed to fetch admin profile: ${userResult.exception}');
      }

      final userData = userResult.data?['${AppConstants.usersTable}_by_pk'];

      if (userData != null && userData['business_id'] != null) {
        return userData['business_id'];
      }

      // If no profile or business_id, create Business and User Profile
      debugPrint('Creating new Business and Admin Profile...');

      // Create Business
      final businessMutation = gql('''
        mutation InsertBusiness(\$name: String!) {
          insert_${AppConstants.businessesTable}_one(object: {
            name: \$name,
            onboarding_completed: true
          }) {
            id
          }
        }
      ''');

      final businessResult = await NhostService.graphqlClient.mutate(
        MutationOptions(
          document: businessMutation,
          variables: const {'name': _businessName},
        ),
      );

      if (businessResult.hasException) {
        throw Exception(
            'Failed to create business: ${businessResult.exception}');
      }

      final businessId = businessResult
          .data?['insert_${AppConstants.businessesTable}_one']['id'];

      // Create Admin Profile
      final userMutation = gql('''
        mutation InsertUser(\$id: uuid!, \$email: String!, \$business_id: uuid!) {
          insert_${AppConstants.usersTable}_one(object: {
            id: \$id,
            email: \$email,
            business_id: \$business_id,
            role: "admin"
          }) {
            id
          }
        }
      ''');

      final insertUserResult = await NhostService.graphqlClient.mutate(
        MutationOptions(
          document: userMutation,
          variables: {
            'id': userId,
            'email': _adminEmail,
            'business_id': businessId,
          },
        ),
      );

      if (insertUserResult.hasException) {
        throw Exception(
            'Failed to create admin profile: ${insertUserResult.exception}');
      }

      // Seed Modules
      debugPrint('Seeding modules for business: $businessId');
      final modules = [
        'Inventory',
        'Sales',
        'Accounting',
        'Customers',
        'Reports'
      ];

      for (final module in modules) {
        final subscriptionMutation = gql('''
          mutation InsertSubscription(\$business_id: uuid!, \$module_name: String!) {
            insert_${AppConstants.businessSubscriptionsTable}_one(
              object: {
                business_id: \$business_id,
                module_name: \$module_name,
                is_active: true,
                activated_at: "now()"
              },
              on_conflict: {
                constraint: ${AppConstants.businessSubscriptionsTable}_pkey,
                update_columns: [is_active]
              }
            ) {
              id
            }
          }
        ''');

        await NhostService.graphqlClient.mutate(
          MutationOptions(
            document: subscriptionMutation,
            variables: {
              'business_id': businessId,
              'module_name': module,
            },
          ),
        );
      }

      return businessId;
    } catch (e) {
      throw Exception('Admin setup failed: $e');
    }
  }

  static Future<void> _createRoleUser(
      String email, String role, String businessId) async {
    // 1. Sign out (to sign up new user)
    await NhostService.client.auth.signOut();

    // 2. Sign Up / Login
    try {
      await NhostService.client.auth.signInEmailPassword(
        email: email,
        password: _password,
      );
      debugPrint('Logged in as $email');
    } catch (e) {
      // Login failed, try signup
      debugPrint('Signing up $email...');
      try {
        await NhostService.client.auth.signUp(
          email: email,
          password: _password,
          metadata: {'full_name': 'Test $role'},
        );
        // Ensure signed in
        await NhostService.client.auth.signInEmailPassword(
          email: email,
          password: _password,
        );
      } catch (signupError) {
        // If user exists but login failed (e.g. wrong password), we can't do much.
        // Assuming "User already exists" error from signup means we should have been able to login.
        debugPrint('Signup/Login failed for $email: $signupError');
        return; // Skip this user
      }
    }

    // 3. User is now logged in. Check/Create Profile.
    final userId = NhostService.client.auth.currentUser!.id;

    // Check if profile exists
    final userQuery = gql('''
        query GetUser(\$id: uuid!) {
          ${AppConstants.usersTable}_by_pk(id: \$id) {
            id
          }
        }
      ''');

    final userResult = await NhostService.graphqlClient.query(
      QueryOptions(
        document: userQuery,
        variables: {'id': userId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (userResult.data?['${AppConstants.usersTable}_by_pk'] != null) {
      debugPrint('Profile exists for $email');
      return;
    }

    // Create Profile with specific role
    debugPrint('Creating profile for $email with role $role');
    final userMutation = gql('''
        mutation InsertUser(\$id: uuid!, \$email: String!, \$business_id: uuid!, \$role: String!) {
          insert_${AppConstants.usersTable}_one(object: {
            id: \$id,
            email: \$email,
            business_id: \$business_id,
            role: \$role
          }) {
            id
          }
        }
      ''');

    final insertResult = await NhostService.graphqlClient.mutate(
      MutationOptions(
        document: userMutation,
        variables: {
          'id': userId,
          'email': email,
          'business_id': businessId,
          'role': role,
        },
      ),
    );

    if (insertResult.hasException) {
      debugPrint(
          'Failed to create profile for $email: ${insertResult.exception}');
    }
  }
}
