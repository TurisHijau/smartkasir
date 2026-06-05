class Product {
  final String? id;
  final String? storeId;
  final String name;
  final String? barcode;
  final double costPrice;
  final double sellingPrice;
  final int stock;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    this.storeId,
    required this.name,
    this.barcode,
    required this.costPrice,
    required this.sellingPrice,
    required this.stock,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      storeId: json['storeId'],
      name: json['name'] ?? '',
      barcode: json['barcode'],
      costPrice: (json['costPrice'] ?? 0).toDouble(),
      sellingPrice: (json['sellingPrice'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'barcode': barcode,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'stock': stock,
    };
  }
}
