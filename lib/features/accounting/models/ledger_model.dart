class LedgerEntry {
  final String id;
  final String businessId;
  final DateTime date;
  final String description;
  final double amount;
  final String type; // 'debit' or 'credit'
  final String category;
  final String? referenceId;
  final DateTime? createdAt;

  const LedgerEntry({
    required this.id,
    required this.businessId,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    this.referenceId,
    this.createdAt,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String,
      category: json['category'] as String,
      referenceId: json['reference_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'date': date.toIso8601String(),
      'description': description,
      'amount': amount,
      'type': type,
      'category': category,
      'reference_id': referenceId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
