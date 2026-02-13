/// Module model representing available ERP modules
class ModuleModel {
  final String id;
  final String name;
  final String category;
  final String icon;
  final String route;
  final String? description;
  final List<String> requiresModules;

  const ModuleModel({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.route,
    this.description,
    this.requiresModules = const [],
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String,
      route: json['route'] as String,
      description: json['description'] as String?,
      requiresModules: (json['requires_modules'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'icon': icon,
      'route': route,
      'description': description,
      'requires_modules': requiresModules,
    };
  }
}

/// Business subscription model for module activation
class BusinessSubscription {
  final String id;
  final String businessId;
  final String moduleName;
  final bool isActive;
  final DateTime? activatedAt;
  final Map<String, dynamic> settings;

  const BusinessSubscription({
    required this.id,
    required this.businessId,
    required this.moduleName,
    required this.isActive,
    this.activatedAt,
    this.settings = const {},
  });

  factory BusinessSubscription.fromJson(Map<String, dynamic> json) {
    return BusinessSubscription(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      moduleName: json['module_name'] as String,
      isActive: json['is_active'] as bool,
      activatedAt: json['activated_at'] != null
          ? DateTime.parse(json['activated_at'] as String)
          : null,
      settings: json['settings'] != null
          ? Map<String, dynamic>.from(json['settings'] as Map)
          : const {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'module_name': moduleName,
      'is_active': isActive,
      'activated_at': activatedAt?.toIso8601String(),
      'settings': settings,
    };
  }
}
