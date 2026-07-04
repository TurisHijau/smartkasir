class DashboardModel {
  final SummaryModel summary;
  final List<ChartDataModel> salesChart;
  final List<TopProductModel> topProducts;

  DashboardModel({
    required this.summary,
    required this.salesChart,
    required this.topProducts,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      summary: SummaryModel.fromJson(json['summary']),
      salesChart: (json['salesChart'] as List)
          .map((e) => ChartDataModel.fromJson(e))
          .toList(),
      topProducts: (json['topProducts'] as List)
          .map((e) => TopProductModel.fromJson(e))
          .toList(),
    );
  }
}

class SummaryModel {
  final double revenue;
  final double revenueChange;
  final int transactionCount;
  final double transactionCountChange;
  final double avgTransaction;
  final double avgTransactionChange;
  final double netProfit;
  final double netProfitChange;

  SummaryModel({
    required this.revenue,
    required this.revenueChange,
    required this.transactionCount,
    required this.transactionCountChange,
    required this.avgTransaction,
    required this.avgTransactionChange,
    required this.netProfit,
    required this.netProfitChange,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(    
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      revenueChange: (json['revenueChange'] as num?)?.toDouble() ?? 0,
      transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
      transactionCountChange:
          (json['transactionCountChange'] as num?)?.toDouble() ?? 0,
      avgTransaction: (json['avgTransaction'] as num?)?.toDouble() ?? 0,
      avgTransactionChange:
          (json['avgTransactionChange'] as num?)?.toDouble() ?? 0,
      netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0,
      netProfitChange: (json['netProfitChange'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ChartDataModel {
  final String label;
  final double value;

  ChartDataModel({required this.label, required this.value});

  factory ChartDataModel.fromJson(Map<String, dynamic> json) {
    return ChartDataModel(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
    );
  }
}

class TopProductModel {
  final String productName;
  final int totalQuantity;

  TopProductModel({required this.productName, required this.totalQuantity});

  factory TopProductModel.fromJson(Map<String, dynamic> json) {
    return TopProductModel(
      productName: json['productName'] as String,
      totalQuantity: ((json['quantitySold'] ?? json['totalQuantity'] ?? 0) as num).toInt(),
    );
  }
}

class TopProductDTO {
  final String productName;
  final int quantitySold;

  TopProductDTO({required this.productName, required this.quantitySold});

  factory TopProductDTO.fromJson(Map<String, dynamic> json) {
    return TopProductDTO(
      productName: json['productName'] ?? '',
      quantitySold: (json['quantitySold'] ?? 0).toInt(),
    );
  }
}
