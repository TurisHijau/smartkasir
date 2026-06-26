enum StockMovementType { IN, OUT, ADJUSTMENT }
enum ReferenceType { SALE, RESTOCK, MANUAL }

class StockMovement {
  final String? id;
  final String? productId;
  final StockMovementType type;
  final int quantity;
  final ReferenceType? referenceType;
  final String? referenceId;
  final String? notes;
  final String? createdBy;
  final DateTime? createdAt;

  StockMovement({
    this.id,
    this.productId,
    required this.type,
    required this.quantity,
    this.referenceType,
    this.referenceId,
    this.notes,
    this.createdBy,
    this.createdAt,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'],
      productId: json['productId'],
      type: StockMovementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StockMovementType.IN,
      ),
      quantity: json['quantity'] ?? 0,
      referenceType: json['referenceType'] != null
          ? ReferenceType.values.firstWhere(
              (e) => e.name == json['referenceType'],
              orElse: () => ReferenceType.MANUAL,
            )
          : null,
      referenceId: json['referenceId'],
      notes: json['notes'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}

class StockRequest {
  final String productId;
  final int quantity;
  final String? notes;

  StockRequest({
    required this.productId,
    required this.quantity,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      if (notes != null) 'notes': notes,
    };
  }
}
