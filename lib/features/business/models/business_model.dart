/// Business model
class Business {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;

  const Business({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.email,
    this.website,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
    };
  }
}
