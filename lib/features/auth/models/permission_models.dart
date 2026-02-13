/// Permission and Role models for RBAC
class Permission {
  final String id;
  final String name;
  final String resource;
  final String action;
  final String? description;

  const Permission({
    required this.id,
    required this.name,
    required this.resource,
    required this.action,
    this.description,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'] as String,
      name: json['name'] as String,
      resource: json['resource'] as String,
      action: json['action'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'resource': resource,
      'action': action,
      'description': description,
    };
  }
}

/// Role model
class Role {
  final String id;
  final String name;
  final String displayName;
  final String? description;
  final bool isSystemRole;
  final String? businessId;
  final List<Permission>? permissions;

  const Role({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
    required this.isSystemRole,
    this.businessId,
    this.permissions,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['display_name'] as String,
      description: json['description'] as String?,
      isSystemRole: json['is_system_role'] as bool,
      businessId: json['business_id'] as String?,
      permissions: json['permissions'] != null
          ? (json['permissions'] as List)
              .map((p) => Permission.fromJson(p as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'description': description,
      'is_system_role': isSystemRole,
      'business_id': businessId,
    };
  }
}

/// User's role with permissions
class UserRole {
  final String roleName;
  final String displayName;
  final String? description;
  final List<Permission> permissions;

  const UserRole({
    required this.roleName,
    required this.displayName,
    this.description,
    required this.permissions,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      roleName: json['role_name'] as String,
      displayName: json['display_name'] as String,
      description: json['description'] as String?,
      permissions: [],
    );
  }

  /// Check if this role has a specific permission
  bool hasPermission(String permissionName) {
    return permissions.any((p) => p.name == permissionName);
  }

  /// Check if this role can access a resource with specific action
  bool canAccess(String resource, String action) {
    return permissions.any((p) => p.resource == resource && p.action == action);
  }
}

/// Resource enum for type safety
enum Resource {
  accounting,
  inventory,
  sales,
  payroll,
  customers,
  reports,
  settings,
  users;

  String get value => name;
}

/// Action enum for type safety
enum PermissionAction {
  read,
  write,
  delete,
  manage;

  String get value => name;
}

/// Helper class to build permission names
class PermissionNames {
  // Accounting
  static const String accountingRead = 'accounting.read';
  static const String accountingWrite = 'accounting.write';
  static const String accountingDelete = 'accounting.delete';
  static const String accountingManage = 'accounting.manage';

  // Inventory
  static const String inventoryRead = 'inventory.read';
  static const String inventoryWrite = 'inventory.write';
  static const String inventoryDelete = 'inventory.delete';
  static const String inventoryManage = 'inventory.manage';

  // Sales
  static const String salesRead = 'sales.read';
  static const String salesWrite = 'sales.write';
  static const String salesDelete = 'sales.delete';
  static const String salesManage = 'sales.manage';

  // Payroll
  static const String payrollRead = 'payroll.read';
  static const String payrollWrite = 'payroll.write';
  static const String payrollDelete = 'payroll.delete';
  static const String payrollManage = 'payroll.manage';

  // Customers
  static const String customersRead = 'customers.read';
  static const String customersWrite = 'customers.write';
  static const String customersDelete = 'customers.delete';
  static const String customersManage = 'customers.manage';

  // Reports
  static const String reportsRead = 'reports.read';
  static const String reportsWrite = 'reports.write';
  static const String reportsDelete = 'reports.delete';
  static const String reportsManage = 'reports.manage';

  // Settings
  static const String settingsRead = 'settings.read';
  static const String settingsManage = 'settings.manage';

  // Users
  static const String usersRead = 'users.read';
  static const String usersWrite = 'users.write';
  static const String usersDelete = 'users.delete';
  static const String usersManage = 'users.manage';

  /// Build permission name from resource and action
  static String build(Resource resource, PermissionAction action) {
    return '${resource.value}.${action.value}';
  }
}
