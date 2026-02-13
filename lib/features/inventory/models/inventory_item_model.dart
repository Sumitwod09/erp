class InventoryItem {
  final String id;
  final String businessId;
  final String name;
  final String? sku;
  final String? description;
  final double quantity;
  final double unitPrice;
  final double reorderLevel;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InventoryItem({
    required this.id,
    required this.businessId,
    required this.name,
    this.sku,
    this.description,
    this.quantity = 0.0,
    this.unitPrice = 0.0,
    this.reorderLevel = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String?,
      description: json['description'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      reorderLevel: (json['reorder_level'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'sku': sku,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'reorder_level': reorderLevel,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  InventoryItem copyWith({
    String? id,
    String? businessId,
    String? name,
    String? sku,
    String? description,
    double? quantity,
    double? unitPrice,
    double? reorderLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
