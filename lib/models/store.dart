class Store {
  final String? id;
  final String businessName;
  final String? address;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Store({
    this.id,
    required this.businessName,
    this.address,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      businessName: json['businessName'] ?? '',
      address: json['address'],
      phone: json['phone'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }
}
