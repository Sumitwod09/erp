import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nhost_flutter_auth/nhost_flutter_auth.dart';
import 'package:nhost_sdk/nhost_sdk.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../shared/services/nhost_service.dart';
import '../../../shared/services/permission_service.dart';
import '../../../core/constants/app_constants.dart';
import '../models/permission_models.dart';

part 'auth_provider.g.dart';

/// Auth state model
class AuthState {
  final User? user;
  final UserRole? userRole;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.userRole,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    UserRole? userRole,
    bool? isLoading,
    String? error,
    bool clearUserRole = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      userRole: clearUserRole ? null : (userRole ?? this.userRole),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Check if user has a specific permission
  bool hasPermission(String permissionName) {
    return userRole?.hasPermission(permissionName) ?? false;
  }

  /// Check if user can access a resource with specific action
  bool canAccess(String resource, String action) {
    return userRole?.canAccess(resource, action) ?? false;
  }

  /// Check if user is admin
  bool get isAdmin => userRole?.roleName == 'admin';
}

/// Auth provider for managing authentication state
@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    // Listen to auth state changes via Nhost
    final authSubscription =
        NhostService.client.auth.addAuthStateChangedCallback((authState) async {
      if (authState == AuthenticationState.signedIn) {
        // Load user role and permissions
        final userRole = await PermissionService.getUserRole();
        state = AuthState(user: NhostService.currentUser, userRole: userRole);
      } else {
        state = const AuthState();
      }
    });

    ref.onDispose(() {
      authSubscription();
    });

    // Return initial state (load role asynchronously)
    final currentUser = NhostService.currentUser;
    if (currentUser != null) {
      _loadUserRole();
    }
    return AuthState(user: currentUser);
  }

  /// Load user role and permissions asynchronously
  Future<void> _loadUserRole() async {
    final userRole = await PermissionService.getUserRole();
    state = state.copyWith(userRole: userRole);
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await NhostService.client.auth.signInEmailPassword(
        email: email,
        password: password,
      );
      // State will be updated by auth listener
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String businessName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Create auth user with metadata
      final response = await NhostService.client.auth.signUp(
        email: email,
        password: password,
        metadata: {
          'full_name': fullName,
        },
      );

      if (response.session != null) {
        // Create business using GraphQL mutation
        final businessMutationDoc = gql('''
          mutation InsertBusiness(\$name: String!) {
            insert_${AppConstants.businessesTable}_one(object: {
              name: \$name,
              onboarding_completed: false
            }) {
              id
            }
          }
        ''');

        final businessResult = await NhostService.graphqlClient.mutate(
          MutationOptions(
            document: businessMutationDoc,
            variables: {'name': businessName},
          ),
        );

        if (businessResult.hasException) {
          throw Exception(
              'Failed to create business: ${businessResult.exception}');
        }

        final businessId = businessResult
            .data?['insert_${AppConstants.businessesTable}_one']['id'];

        // Create user profile using GraphQL mutation
        final userMutationDoc = gql('''
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

        final userResult = await NhostService.graphqlClient.mutate(
          MutationOptions(
            document: userMutationDoc,
            variables: {
              'id': response.session!.user!.id,
              'email': email,
              'business_id': businessId,
            },
          ),
        );

        if (userResult.hasException) {
          throw Exception('Failed to create user: ${userResult.exception}');
        }

        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await NhostService.client.auth.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await NhostService.client.auth.resetPassword(email: email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
