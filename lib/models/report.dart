class DashboardModel {
  final SalesSummary today;
  final SalesSummary thisMonth;
  final List<SalesTrendPoint> salesTrend;
  final List<PaymentMethodBreakdown> paymentMethods;
  final List<TopProductModel> topProductsByQuantity;
  final List<ProductRevenueModel> topProductsByRevenue;
  final List<CashierPerformanceModel> cashiers;
  final InventoryAnalytics inventory;

  DashboardModel({
    required this.today,
    required this.thisMonth,
    required this.salesTrend,
    required this.paymentMethods,
    required this.topProductsByQuantity,
    required this.topProductsByRevenue,
    required this.cashiers,
    required this.inventory,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      today: SalesSummary.fromJson(_map(json['today'])),
      thisMonth: SalesSummary.fromJson(_map(json['thisMonth'])),
      salesTrend: _list(
        json['salesTrend'],
      ).map((e) => SalesTrendPoint.fromJson(_map(e))).toList(),
      paymentMethods: _list(
        json['paymentMethods'],
      ).map((e) => PaymentMethodBreakdown.fromJson(_map(e))).toList(),
      topProductsByQuantity: _list(
        json['topProductsByQuantity'],
      ).map((e) => TopProductModel.fromJson(_map(e))).toList(),
      topProductsByRevenue: _list(
        json['topProductsByRevenue'],
      ).map((e) => ProductRevenueModel.fromJson(_map(e))).toList(),
      cashiers: _list(
        json['cashiers'],
      ).map((e) => CashierPerformanceModel.fromJson(_map(e))).toList(),
      inventory: InventoryAnalytics.fromJson(_map(json['inventory'])),
    );
  }
}

class SalesSummary {
  final String startDate;
  final String endDate;
  final int transactionCount;
  final double totalRevenue;
  final double averageTransaction;
  final double grossProfit;
  final double grossMarginPercent;

  SalesSummary({
    required this.startDate,
    required this.endDate,
    required this.transactionCount,
    required this.totalRevenue,
    required this.averageTransaction,
    required this.grossProfit,
    required this.grossMarginPercent,
  });

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    return SalesSummary(
      startDate: '${json['startDate'] ?? ''}',
      endDate: '${json['endDate'] ?? ''}',
      transactionCount: _toInt(json['transactionCount']),
      totalRevenue: _toDouble(json['totalRevenue']),
      averageTransaction: _toDouble(json['averageTransaction']),
      grossProfit: _toDouble(json['grossProfit']),
      grossMarginPercent: _toDouble(json['grossMarginPercent']),
    );
  }
}

class SalesTrendPoint {
  final String date;
  final int transactionCount;
  final double revenue;

  SalesTrendPoint({
    required this.date,
    required this.transactionCount,
    required this.revenue,
  });

  factory SalesTrendPoint.fromJson(Map<String, dynamic> json) {
    return SalesTrendPoint(
      date: '${json['date'] ?? ''}',
      transactionCount: _toInt(json['transactionCount']),
      revenue: _toDouble(json['revenue']),
    );
  }
}

class PaymentMethodBreakdown {
  final String method;
  final int transactionCount;
  final double revenue;

  PaymentMethodBreakdown({
    required this.method,
    required this.transactionCount,
    required this.revenue,
  });

  factory PaymentMethodBreakdown.fromJson(Map<String, dynamic> json) {
    return PaymentMethodBreakdown(
      method: '${json['method'] ?? ''}',
      transactionCount: _toInt(json['transactionCount']),
      revenue: _toDouble(json['revenue']),
    );
  }
}

class TopProductModel {
  final String productName;
  final int totalQuantity;

  TopProductModel({required this.productName, required this.totalQuantity});

  factory TopProductModel.fromJson(Map<String, dynamic> json) {
    return TopProductModel(
      productName: '${json['productName'] ?? ''}',
      totalQuantity: _toInt(json['quantitySold'] ?? json['totalQuantity']),
    );
  }
}

class ProductRevenueModel {
  final String productName;
  final int quantitySold;
  final double revenue;
  final double grossProfit;

  ProductRevenueModel({
    required this.productName,
    required this.quantitySold,
    required this.revenue,
    required this.grossProfit,
  });

  factory ProductRevenueModel.fromJson(Map<String, dynamic> json) {
    return ProductRevenueModel(
      productName: '${json['productName'] ?? ''}',
      quantitySold: _toInt(json['quantitySold']),
      revenue: _toDouble(json['revenue']),
      grossProfit: _toDouble(json['grossProfit']),
    );
  }
}

class CashierPerformanceModel {
  final String cashierName;
  final int transactionCount;
  final double revenue;
  final double averageTransaction;

  CashierPerformanceModel({
    required this.cashierName,
    required this.transactionCount,
    required this.revenue,
    required this.averageTransaction,
  });

  factory CashierPerformanceModel.fromJson(Map<String, dynamic> json) {
    return CashierPerformanceModel(
      cashierName: '${json['cashierName'] ?? ''}',
      transactionCount: _toInt(json['transactionCount']),
      revenue: _toDouble(json['revenue']),
      averageTransaction: _toDouble(json['averageTransaction']),
    );
  }
}

class InventoryAnalytics {
  final int lowStockThreshold;
  final int slowMovingWindowDays;
  final String slowMovingStart;
  final String slowMovingEnd;
  final List<LowStockProductModel> lowStockProducts;
  final List<SlowMovingProductModel> slowMovingProducts;

  InventoryAnalytics({
    required this.lowStockThreshold,
    required this.slowMovingWindowDays,
    required this.slowMovingStart,
    required this.slowMovingEnd,
    required this.lowStockProducts,
    required this.slowMovingProducts,
  });

  factory InventoryAnalytics.fromJson(Map<String, dynamic> json) {
    return InventoryAnalytics(
      lowStockThreshold: _toInt(json['lowStockThreshold']),
      slowMovingWindowDays: _toInt(json['slowMovingWindowDays']) == 0
          ? 30
          : _toInt(json['slowMovingWindowDays']),
      slowMovingStart: '${json['slowMovingStart'] ?? ''}',
      slowMovingEnd: '${json['slowMovingEnd'] ?? ''}',
      lowStockProducts: _list(
        json['lowStockProducts'],
      ).map((e) => LowStockProductModel.fromJson(_map(e))).toList(),
      slowMovingProducts: _list(
        json['slowMovingProducts'],
      ).map((e) => SlowMovingProductModel.fromJson(_map(e))).toList(),
    );
  }
}

class LowStockProductModel {
  final String productName;
  final int stock;
  final double sellingPrice;

  LowStockProductModel({
    required this.productName,
    required this.stock,
    required this.sellingPrice,
  });

  factory LowStockProductModel.fromJson(Map<String, dynamic> json) {
    return LowStockProductModel(
      productName: '${json['productName'] ?? ''}',
      stock: _toInt(json['stock']),
      sellingPrice: _toDouble(json['sellingPrice']),
    );
  }
}

class SlowMovingProductModel {
  final String productName;
  final int stock;
  final int quantitySold;

  SlowMovingProductModel({
    required this.productName,
    required this.stock,
    required this.quantitySold,
  });

  factory SlowMovingProductModel.fromJson(Map<String, dynamic> json) {
    return SlowMovingProductModel(
      productName: '${json['productName'] ?? ''}',
      stock: _toInt(json['stock']),
      quantitySold: _toInt(json['quantitySold']),
    );
  }
}

class TopProductDTO {
  final String productName;
  final int quantitySold;

  TopProductDTO({required this.productName, required this.quantitySold});

  factory TopProductDTO.fromJson(Map<String, dynamic> json) {
    return TopProductDTO(
      productName: '${json['productName'] ?? ''}',
      quantitySold: _toInt(json['quantitySold']),
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<dynamic> _list(dynamic value) {
  return value is List ? value : const [];
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
  }
  return 0;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
