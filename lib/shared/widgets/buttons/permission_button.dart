import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/providers/auth_provider.dart';

/// Button that is automatically disabled if user lacks permission
class PermissionButton extends ConsumerWidget {
  final String permission;
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool hideIfNoPermission;

  const PermissionButton({
    super.key,
    required this.permission,
    required this.onPressed,
    required this.child,
    this.style,
    this.hideIfNoPermission = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final hasPermission = authState.hasPermission(permission);

    if (!hasPermission && hideIfNoPermission) {
      return const SizedBox.shrink();
    }

    return ElevatedButton(
      style: style,
      onPressed: hasPermission ? onPressed : null,
      child: child,
    );
  }
}

/// Icon button with permission check
class PermissionIconButton extends ConsumerWidget {
  final String permission;
  final VoidCallback? onPressed;
  final Icon icon;
  final String? tooltip;
  final bool hideIfNoPermission;

  const PermissionIconButton({
    super.key,
    required this.permission,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.hideIfNoPermission = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final hasPermission = authState.hasPermission(permission);

    if (!hasPermission && hideIfNoPermission) {
      return const SizedBox.shrink();
    }

    return IconButton(
      tooltip: tooltip,
      icon: icon,
      onPressed: hasPermission ? onPressed : null,
    );
  }
}

/// Text button with permission check
class PermissionTextButton extends ConsumerWidget {
  final String permission;
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool hideIfNoPermission;

  const PermissionTextButton({
    super.key,
    required this.permission,
    required this.onPressed,
    required this.child,
    this.style,
    this.hideIfNoPermission = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final hasPermission = authState.hasPermission(permission);

    if (!hasPermission && hideIfNoPermission) {
      return const SizedBox.shrink();
    }

    return TextButton(
      style: style,
      onPressed: hasPermission ? onPressed : null,
      child: child,
    );
  }
}

/// Floating action button with permission check
class PermissionFAB extends ConsumerWidget {
  final String permission;
  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;
  final bool hideIfNoPermission;

  const PermissionFAB({
    super.key,
    required this.permission,
    required this.onPressed,
    required this.child,
    this.tooltip,
    this.hideIfNoPermission = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final hasPermission = authState.hasPermission(permission);

    if (!hasPermission && hideIfNoPermission) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      tooltip: tooltip,
      onPressed: hasPermission ? onPressed : null,
      child: child,
    );
  }
}

/// Menu item with permission check
class PermissionMenuItem extends ConsumerWidget {
  final String permission;
  final VoidCallback? onPressed;
  final Widget child;
  final bool hideIfNoPermission;

  const PermissionMenuItem({
    super.key,
    required this.permission,
    required this.onPressed,
    required this.child,
    this.hideIfNoPermission = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final hasPermission = authState.hasPermission(permission);

    if (!hasPermission) {
      if (hideIfNoPermission) {
        return const SizedBox.shrink();
      }
      // Show disabled menu item
      return MenuItemButton(
        onPressed: null,
        child: child,
      );
    }

    return MenuItemButton(
      onPressed: onPressed,
      child: child,
    );
  }
}
