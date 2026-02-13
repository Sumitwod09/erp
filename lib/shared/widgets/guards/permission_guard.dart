import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/providers/auth_provider.dart';

/// Widget that conditionally renders children based on user permissions
class PermissionGuard extends ConsumerWidget {
  final String permission;
  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  const PermissionGuard({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
    this.showFallback = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final hasPermission = authState.hasPermission(permission);

    if (hasPermission) {
      return child;
    }

    if (showFallback && fallback != null) {
      return fallback!;
    }

    // Don't render anything if user lacks permission and no fallback
    return const SizedBox.shrink();
  }
}

/// Widget that conditionally renders children based on multiple permissions (OR logic)
class PermissionGuardAny extends ConsumerWidget {
  final List<String> permissions;
  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  const PermissionGuardAny({
    super.key,
    required this.permissions,
    required this.child,
    this.fallback,
    this.showFallback = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Check if user has any of the specified permissions
    final hasAnyPermission = permissions.any(
      (permission) => authState.hasPermission(permission),
    );

    if (hasAnyPermission) {
      return child;
    }

    if (showFallback && fallback != null) {
      return fallback!;
    }

    return const SizedBox.shrink();
  }
}

/// Widget that conditionally renders children based on multiple permissions (AND logic)
class PermissionGuardAll extends ConsumerWidget {
  final List<String> permissions;
  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  const PermissionGuardAll({
    super.key,
    required this.permissions,
    required this.child,
    this.fallback,
    this.showFallback = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Check if user has all of the specified permissions
    final hasAllPermissions = permissions.every(
      (permission) => authState.hasPermission(permission),
    );

    if (hasAllPermissions) {
      return child;
    }

    if (showFallback && fallback != null) {
      return fallback!;
    }

    return const SizedBox.shrink();
  }
}

/// Widget that renders different content based on role
class RoleGuard extends ConsumerWidget {
  final String roleName;
  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  const RoleGuard({
    super.key,
    required this.roleName,
    required this.child,
    this.fallback,
    this.showFallback = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isRole = authState.userRole?.roleName == roleName;

    if (isRole) {
      return child;
    }

    if (showFallback && fallback != null) {
      return fallback!;
    }

    return const SizedBox.shrink();
  }
}

/// Widget that renders content only for admin users
class AdminGuard extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  const AdminGuard({
    super.key,
    required this.child,
    this.fallback,
    this.showFallback = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isAdmin) {
      return child;
    }

    if (showFallback && fallback != null) {
      return fallback!;
    }

    return const SizedBox.shrink();
  }
}
