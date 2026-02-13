import 'package:flutter/material.dart';

/// Core application constants
class AppConstants {
  // App Information
  static const String appName = 'Lumiere ERP';
  static const String appVersion = '1.0.0';

  // Layout Constants
  static const double sidebarWidth = 0.18; // 18% of screen width
  static const double workspaceWidth = 0.82; // 82% of screen width
  static const double minSidebarPixelWidth = 250.0;
  static const double maxSidebarPixelWidth = 350.0;

  // Grid System
  static const int gridColumns = 12;
  static const double gridGutter = 16.0;

  // Spacing (4px base unit)
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double spaceXxl = 48.0;

  // Border Radius
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 16.0;

  // Shadows
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  // Typography
  static const double fontSizeBase = 14.0;
  static const double fontSizeSm = 12.0;
  static const double fontSizeLg = 16.0;
  static const double fontSizeXl = 20.0;
  static const double fontSizeXxl = 24.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Database
  static const String businessSubscriptionsTable = 'business_subscriptions';
  static const String businessesTable = 'businesses';
  static const String usersTable = 'users';
  static const String modulesTable = 'modules';
  static const String industryPresetsTable = 'industry_presets';
}
