enum PaymentMethod { CASH, QRIS }

class Transaction {
  final String? id;
  final String? storeId;
  final String? cashierId;
  final String? transactionCode;
  final double totalAmount;
  final double amountPaid;
  final double changeAmount;
  final PaymentMethod paymentMethod;
  final DateTime? transactionDate;

  Transaction({
    this.id,
    this.storeId,
    this.cashierId,
    this.transactionCode,
    required this.totalAmount,
    required this.amountPaid,
    required this.changeAmount,
    required this.paymentMethod,
    this.transactionDate,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      storeId: json['storeId'],
      cashierId: json['cashierId'],
      transactionCode: json['transactionCode'],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      changeAmount: (json['changeAmount'] ?? 0).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethod.CASH,
      ),
      transactionDate: json['transactionDate'] != null
          ? DateTime.tryParse(json['transactionDate'].toString())
          : null,
    );
  }
}

class TransactionItemRequest {
  final String productId;
  final int quantity;

  TransactionItemRequest({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {'productId': productId, 'quantity': quantity};
  }
}

class TransactionRequest {
  final double amountPaid;
  final PaymentMethod paymentMethod;
  final List<TransactionItemRequest> items;
  final DateTime? transactionDate;

  TransactionRequest({
    required this.amountPaid,
    required this.paymentMethod,
    required this.items,
    this.transactionDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'amountPaid': amountPaid,
      'paymentMethod': paymentMethod.name,
      'items': items.map((i) => i.toJson()).toList(),
      if (transactionDate != null)
        'transactionDate': transactionDate!.toIso8601String(),
    };
  }
}
