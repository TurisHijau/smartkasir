import 'package:flutter/material.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/models/auth.dart';
import 'package:smartkasir/models/report.dart';
import 'package:smartkasir/models/transaction.dart';
import 'package:smartkasir/models/user.dart';
import 'package:smartkasir/services/auth_service.dart';
import 'package:smartkasir/services/report_service.dart';
import 'package:smartkasir/services/transaction_service.dart';

class StatCardData {
  final String label;
  final String value;
  final String badge;
  final Color badgeColor;
  final Color badgeBg;

  const StatCardData({
    required this.label,
    required this.value,
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
  });
}

class LowStockItem {
  final String name;
  final String count;
  final Color color;

  const LowStockItem({
    required this.name,
    required this.count,
    required this.color,
  });
}

class TransaksiItem {
  final String items;
  final String cashier;
  final String amount;

  const TransaksiItem({
    required this.items,
    required this.cashier,
    required this.amount,
  });
}

class TopProductItem {
  final String name;
  final int pcs;

  const TopProductItem({required this.name, required this.pcs});
}

class ProductRevenueItem {
  final String name;
  final int pcs;
  final String revenue;
  final String profit;

  const ProductRevenueItem({
    required this.name,
    required this.pcs,
    required this.revenue,
    required this.profit,
  });
}

class CashierPerformanceItem {
  final String name;
  final int transactions;
  final String revenue;
  final String averageTransaction;

  const CashierPerformanceItem({
    required this.name,
    required this.transactions,
    required this.revenue,
    required this.averageTransaction,
  });
}

class SlowMovingItem {
  final String name;
  final int stock;
  final int sold;

  const SlowMovingItem({
    required this.name,
    required this.stock,
    required this.sold,
  });
}

class InsightItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color backgroundColor;

  const InsightItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.backgroundColor,
  });
}

class PaymentMethodData {
  final int cash;
  final int qris;
  final double cashRevenue;
  final double qrisRevenue;

  const PaymentMethodData({
    required this.cash,
    required this.qris,
    required this.cashRevenue,
    required this.qrisRevenue,
  });

  int get total => cash + qris;
  double get cashRatio => total > 0 ? cash / total : 0;
  double get qrisRatio => total > 0 ? qris / total : 0;
}

class AnalitikViewModel extends ChangeNotifier {
  final ReportService _reportService = ReportService();
  final TransactionService _transactionService = TransactionService();
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;
  bool isCashier = false;

  String storeName = 'SMARTKASIR';
  String storeDate = '';
  final List<String> periodLabels = ['Hari ini', 'Bulan ini'];

  int _selectedPeriod = 0;
  int get selectedPeriod => _selectedPeriod;

  DashboardModel? _dashboard;

  List<StatCardData> statCards = [];
  List<StatCardData> statCardsRow2 = [];
  List<String> chartDays = [];
  List<double> chartValues = [];
  PaymentMethodData paymentMethod = const PaymentMethodData(
    cash: 0,
    qris: 0,
    cashRevenue: 0,
    qrisRevenue: 0,
  );
  List<LowStockItem> lowStockItems = [];
  List<TransaksiItem> recentTransactions = [];
  List<TopProductItem> topProducts = [];
  List<ProductRevenueItem> topRevenueProducts = [];
  List<CashierPerformanceItem> cashierPerformance = [];
  List<SlowMovingItem> slowMovingProducts = [];
  List<InsightItem> businessInsights = [];
  String slowMovingPeriodLabel = '30 hari terakhir';

  AnalitikViewModel() {
    _initDate();
    loadData();
  }

  void _initDate() {
    final now = DateTime.now();
    final dayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    final monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    storeDate =
        '${dayNames[now.weekday % 7]}, ${now.day} ${monthNames[now.month]} ${now.year}';
  }

  void selectPeriod(int index) {
    _selectedPeriod = index;
    _applyDashboardData();
    notifyListeners();
  }

  void returnToSettings(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> loadData() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _loadProfile();

      if (!isCashier) {
        _dashboard = await _reportService.getDashboard();
        _applyDashboardData();
      }

      await _loadRecentTransactions();
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadProfile() async {
    AuthResponse? profile;
    try {
      profile = await _authService.getProfile();
    } catch (_) {
      profile = null;
    }

    if (profile != null) {
      storeName = profile.store.businessName.toUpperCase();
      isCashier = profile.user.role == Role.CASHIER;
    }
  }

  Future<void> _loadRecentTransactions() async {
    final transactions = await _transactionService.getAll().catchError(
      (_) => <Transaction>[],
    );

    final sorted = List<Transaction>.from(transactions);
    sorted.sort((a, b) {
      final aDate = a.transactionDate ?? DateTime(2000);
      final bDate = b.transactionDate ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    recentTransactions = sorted.take(5).map((transaction) {
      return TransaksiItem(
        items: transaction.transactionCode ?? '-',
        cashier: transaction.paymentMethod.name,
        amount: formatRupiah(transaction.totalAmount),
      );
    }).toList();
  }

  void _applyDashboardData() {
    final dashboard = _dashboard;
    if (dashboard == null) {
      statCards = [];
      statCardsRow2 = [];
      chartDays = [];
      chartValues = [];
      paymentMethod = const PaymentMethodData(
        cash: 0,
        qris: 0,
        cashRevenue: 0,
        qrisRevenue: 0,
      );
      lowStockItems = [];
      topProducts = [];
      topRevenueProducts = [];
      cashierPerformance = [];
      slowMovingProducts = [];
      businessInsights = [];
      slowMovingPeriodLabel = '30 hari terakhir';
      return;
    }

    final summary = _selectedPeriod == 0
        ? dashboard.today
        : dashboard.thisMonth;
    final periodLabel = _selectedPeriod == 0 ? 'Hari ini' : 'Bulan ini';

    statCards = [
      StatCardData(
        label: 'Total Pemasukan',
        value: formatCompactRupiah(summary.totalRevenue),
        badge: periodLabel,
        badgeColor: AppColors.primary,
        badgeBg: AppColors.lightGray,
      ),
      StatCardData(
        label: 'Transaksi',
        value: '${summary.transactionCount}',
        badge: periodLabel,
        badgeColor: AppColors.primary,
        badgeBg: AppColors.lightGray,
      ),
    ];

    statCardsRow2 = [
      StatCardData(
        label: 'Rata-rata',
        value: formatCompactRupiah(summary.averageTransaction),
        badge: 'per transaksi',
        badgeColor: AppColors.green,
        badgeBg: AppColors.lightGreen,
      ),
      StatCardData(
        label: 'Gross Profit',
        value: formatCompactRupiah(summary.grossProfit),
        badge: '${summary.grossMarginPercent.toStringAsFixed(1)}% margin',
        badgeColor: AppColors.green,
        badgeBg: AppColors.lightGreen,
      ),
    ];

    chartDays = dashboard.salesTrend.asMap().entries.map((entry) {
      final date = entry.value.date;
      if (entry.key % 5 != 0 && entry.key != dashboard.salesTrend.length - 1) {
        return '';
      }
      return date.length >= 10 ? date.substring(5) : date;
    }).toList();
    chartValues = dashboard.salesTrend.map((e) => e.revenue).toList();

    final cash = _paymentByMethod(dashboard, 'CASH');
    final qris = _paymentByMethod(dashboard, 'QRIS');
    paymentMethod = PaymentMethodData(
      cash: cash.transactionCount,
      qris: qris.transactionCount,
      cashRevenue: cash.revenue,
      qrisRevenue: qris.revenue,
    );

    lowStockItems = dashboard.inventory.lowStockProducts.take(5).map((item) {
      return LowStockItem(
        name: item.productName,
        count: '${item.stock} stok',
        color: item.stock < 5
            ? AppColors.red
            : item.stock < 10
            ? const Color(0xFFF97316)
            : const Color(0xFFFACC15),
      );
    }).toList();

    topProducts = dashboard.topProductsByQuantity.take(10).map((product) {
      return TopProductItem(
        name: product.productName,
        pcs: product.totalQuantity,
      );
    }).toList();

    topRevenueProducts = dashboard.topProductsByRevenue.take(5).map((product) {
      return ProductRevenueItem(
        name: product.productName,
        pcs: product.quantitySold,
        revenue: formatRupiah(product.revenue),
        profit: formatRupiah(product.grossProfit),
      );
    }).toList();

    cashierPerformance = dashboard.cashiers.take(5).map((cashier) {
      return CashierPerformanceItem(
        name: cashier.cashierName,
        transactions: cashier.transactionCount,
        revenue: formatRupiah(cashier.revenue),
        averageTransaction: formatRupiah(cashier.averageTransaction),
      );
    }).toList();

    slowMovingProducts = dashboard.inventory.slowMovingProducts.take(5).map((
      item,
    ) {
      return SlowMovingItem(
        name: item.productName,
        stock: item.stock,
        sold: item.quantitySold,
      );
    }).toList();
    slowMovingPeriodLabel =
        '${dashboard.inventory.slowMovingWindowDays} hari terakhir';

    businessInsights = _buildBusinessInsights(
      summary: summary,
      lowStockCount: dashboard.inventory.lowStockProducts.length,
      slowMovingCount: dashboard.inventory.slowMovingProducts.length,
      cashRevenue: cash.revenue,
      qrisRevenue: qris.revenue,
    );
  }

  List<InsightItem> _buildBusinessInsights({
    required SalesSummary summary,
    required int lowStockCount,
    required int slowMovingCount,
    required double cashRevenue,
    required double qrisRevenue,
  }) {
    final insights = <InsightItem>[
      InsightItem(
        icon: Icons.trending_up,
        title: 'Pendapatan ${periodLabels[_selectedPeriod].toLowerCase()}',
        description:
            '${formatRupiah(summary.totalRevenue)} dari ${summary.transactionCount} transaksi',
        color: AppColors.primary,
        backgroundColor: AppColors.lightPrimary,
      ),
    ];

    if (summary.transactionCount > 0) {
      final marginIsHealthy = summary.grossMarginPercent >= 30;
      insights.add(
        InsightItem(
          icon: marginIsHealthy
              ? Icons.check_circle_outline
              : Icons.info_outline,
          title: marginIsHealthy ? 'Margin sehat' : 'Margin perlu dicek',
          description:
              'Gross margin ${summary.grossMarginPercent.toStringAsFixed(1)}%, profit ${formatRupiah(summary.grossProfit)}',
          color: marginIsHealthy ? AppColors.green : const Color(0xFFF97316),
          backgroundColor: marginIsHealthy
              ? AppColors.lightGreen
              : const Color(0xFFFFEDD5),
        ),
      );
    }

    insights.add(
      InsightItem(
        icon: Icons.inventory_2_outlined,
        title: lowStockCount == 0 ? 'Stok aman' : '$lowStockCount stok menipis',
        description: lowStockCount == 0
            ? 'Tidak ada produk yang perlu restock sekarang'
            : 'Cek daftar stok sebelum produk habis',
        color: lowStockCount == 0 ? AppColors.green : AppColors.red,
        backgroundColor: lowStockCount == 0
            ? AppColors.lightGreen
            : AppColors.lightRed,
      ),
    );

    if (slowMovingCount > 0) {
      insights.add(
        InsightItem(
          icon: Icons.hourglass_empty,
          title: '$slowMovingCount produk slow moving',
          description:
              'Berdasarkan penjualan $slowMovingPeriodLabel, pertimbangkan promo atau kurangi stok berikutnya',
          color: const Color(0xFFF97316),
          backgroundColor: const Color(0xFFFFEDD5),
        ),
      );
    }

    if (paymentMethod.total > 0) {
      final qrisIsHigher = qrisRevenue > cashRevenue;
      insights.add(
        InsightItem(
          icon: Icons.payments_outlined,
          title: qrisIsHigher ? 'QRIS lebih dominan' : 'Cash lebih dominan',
          description: qrisIsHigher
              ? 'QRIS menyumbang ${formatRupiah(qrisRevenue)}'
              : 'Cash menyumbang ${formatRupiah(cashRevenue)}',
          color: AppColors.secondary,
          backgroundColor: AppColors.lightPrimary,
        ),
      );
    }

    return insights.take(4).toList();
  }

  PaymentMethodBreakdown _paymentByMethod(
    DashboardModel dashboard,
    String method,
  ) {
    return dashboard.paymentMethods.firstWhere(
      (item) => item.method.toUpperCase() == method,
      orElse: () => PaymentMethodBreakdown(
        method: method,
        transactionCount: 0,
        revenue: 0,
      ),
    );
  }

  String formatCompactRupiah(double value) {
    if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)} jt';
    }
    if (value >= 1000) return 'Rp ${(value / 1000).toStringAsFixed(0)} rb';
    return 'Rp ${value.toInt()}';
  }

  String formatRupiah(double value) {
    final intVal = value.toInt();
    final str = intVal.toString();
    final result = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) result.write('.');
      result.write(str[i]);
    }
    return 'Rp$result';
  }
}
