class Product {
  final String? id;
  final String? storeId;
  final String name;
  final String? barcode;
  final double costPrice;
  final double sellingPrice;
  final int stock;
  final int initialStock;
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
    required this.initialStock,
    this.createdAt,
    this.updatedAt,
  });

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final stock = _parseInt(json['stock']);
    return Product(
      id: json['id'],
      storeId: json['storeId'],
      name: json['name'] ?? '',
      barcode: json['barcode'],
      costPrice: (json['costPrice'] ?? 0).toDouble(),
      sellingPrice: (json['sellingPrice'] ?? 0).toDouble(),
      stock: stock,
      initialStock: _parseInt(json['initialStock']) != 0
          ? _parseInt(json['initialStock'])
          : stock,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'barcode': barcode,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'stock': stock,
      'initialStock': initialStock,
    };
  }
}
