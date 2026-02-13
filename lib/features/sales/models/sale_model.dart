class Sale {
  final String id;
  final String businessId;
  final String? customerName;
  final double totalAmount;
  final String paymentStatus;
  final String? paymentMethod;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<SaleItem> items;

  const Sale({
    required this.id,
    required this.businessId,
    this.customerName,
    required this.totalAmount,
    this.paymentStatus = 'pending',
    this.paymentMethod,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      customerName: json['customer_name'] as String?,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => SaleItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'customer_name': customerName,
      'total_amount': totalAmount,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class SaleItem {
  final String id;
  final String saleId;
  final String? inventoryItemId;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime? createdAt;
  final String? itemName;

  const SaleItem({
    required this.id,
    required this.saleId,
    this.inventoryItemId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.createdAt,
    this.itemName,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      id: json['id'] as String,
      saleId: json['sale_id'] as String,
      inventoryItemId: json['inventory_item_id'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      itemName: json['item_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sale_id': saleId,
      'inventory_item_id': inventoryItemId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'created_at': createdAt?.toIso8601String(),
      'item_name': itemName,
    };
  }
}
