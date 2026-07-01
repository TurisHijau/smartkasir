import 'package:flutter/material.dart';
import 'package:smartkasir/models/auth.dart';
import 'package:smartkasir/models/product.dart';
import 'package:smartkasir/models/report.dart';
import 'package:smartkasir/models/transaction.dart';
import 'package:smartkasir/services/auth_service.dart';
import 'package:smartkasir/services/product_service.dart';
import 'package:smartkasir/services/report_service.dart';
import 'package:smartkasir/services/transaction_service.dart';
import 'package:smartkasir/constants/app_colors.dart';

//  Model Classes

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

class PaymentMethodData {
  final int cash;
  final int qris;

  const PaymentMethodData({required this.cash, required this.qris});

  int get total => cash + qris;
  double get cashRatio => total > 0 ? cash / total : 0;
  double get qrisRatio => total > 0 ? qris / total : 0;
}

// ViewModel

class AnalitikViewModel extends ChangeNotifier {
  final ReportService _reportService = ReportService();
  final TransactionService _transactionService = TransactionService();
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;

  // ── Store info ──
  String storeName = 'SMARTKASIR';
  String storeDate = '';
  final List<String> periodLabels = ['Hari ini', 'Minggu ini', 'Bulan ini'];

  int _selectedPeriod = 0;
  int get selectedPeriod => _selectedPeriod;

  // ── Stat cards ──
  List<StatCardData> statCards = [];
  List<StatCardData> statCardsRow2 = [];

  // ── Revenue chart ──
  List<String> chartDays = [];
  List<double> chartValues = [];

  // ── Payment method ──
  PaymentMethodData paymentMethod = const PaymentMethodData(cash: 0, qris: 0);

  // ── Low stock ──
  List<LowStockItem> lowStockItems = [];

  // ── Recent transactions ──
  List<TransaksiItem> recentTransactions = [];

  // ── Top products ──
  List<TopProductItem> topProducts = [];

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
    notifyListeners();
    loadData();
  }

  String get _periodString {
    switch (_selectedPeriod) {
      case 0:
        return 'daily';
      case 1:
        return 'weekly';
      case 2:
        return 'monthly';
      default:
        return 'daily';
    }
  }

  void returnToSettings(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> loadData() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final period = _periodString;

      // Load data in parallel
      final results = await Future.wait([
        _reportService.getDashboard(period),
        _transactionService.getAll().catchError((_) => <Transaction>[]),
        _productService.getAll().catchError((_) => <Product>[]),
        _authService.getProfile().then<AuthResponse?>(
          (val) => val,
          onError: (_) => null,
        ),
      ]);

      final dashboardData = results[0] as DashboardModel;
      final transactions = results[1] as List<Transaction>;
      final products = results[2] as List<Product>;
      final profile = results[3] as AuthResponse?;

      if (profile != null) {
        storeName = profile.store.businessName.toUpperCase();
      }

      // ── Stat cards ──
      //
      Color getBadgeColor(int growth) {
        return growth >= 0 ? AppColors.green : AppColors.red;
      }

      Color getBadgeBgColor(int growth) {
        return growth >= 0 ? AppColors.lightGreen : AppColors.lightRed;
      }

      final revenue = dashboardData.summary.revenue;
      final revenueChange = dashboardData.summary.revenueChange;
      final txCount = dashboardData.summary.transactionCount;
      final txCountChange = dashboardData.summary.transactionCountChange;

      String formatRevenue(double val) {
        if (val >= 1000000) {
          return 'Rp ${(val / 1000000).toStringAsFixed(1)} jt';
        }
        if (val >= 1000) return 'Rp ${(val / 1000).toStringAsFixed(0)} rb';
        return 'Rp ${val.toInt()}';
      }

      statCards = [
        StatCardData(
          label: 'Total Pemasukan',
          value: formatRevenue(revenue),
          badge: '$revenueChange %',
          badgeColor: getBadgeColor(revenueChange),
          badgeBg: getBadgeBgColor(revenueChange),
        ),
        StatCardData(
          label: 'Transaksi',
          value: '$txCount',
          badge: '$txCountChange %',
          badgeColor: getBadgeColor(txCountChange),
          badgeBg: getBadgeBgColor(txCountChange),
        ),
      ];

      final avgTransaction = dashboardData.summary.avgTransaction;
      final avgTransactionChange = dashboardData.summary.avgTransactionChange;
      final netProfit = dashboardData.summary.netProfit;
      final netProfitChange = dashboardData.summary.netProfitChange;

      statCardsRow2 = [
        StatCardData(
          label: 'Rata - Rata',
          value: formatRevenue(avgTransaction),
          badge: '$avgTransactionChange %',
          badgeColor: getBadgeColor(avgTransactionChange),
          badgeBg: getBadgeBgColor(avgTransactionChange),
        ),
        StatCardData(
          label: 'Keuntungan',
          value: formatRevenue(netProfit),
          badge: '$netProfitChange %',
          badgeColor: getBadgeColor(netProfitChange),
          badgeBg: getBadgeBgColor(netProfitChange),
        ),
      ];

      // ── Revenue chart ──
      chartDays = dashboardData.salesChart.map((e) => e.label).toList();
      chartValues = dashboardData.salesChart.map((e) => e.value).toList();

      if (chartValues.isEmpty) {
        chartDays = ['Data'];
        chartValues = [1.0];
      } else if (chartValues.every((v) => v == 0)) {
        chartValues = List.filled(chartValues.length, 1.0);
      }

      // ── Payment method breakdown ──
      int cashCount = 0, qrisCount = 0;
      for (final t in transactions) {
        if (t.paymentMethod == PaymentMethod.CASH) {
          cashCount++;
        } else if (t.paymentMethod == PaymentMethod.QRIS) {
          qrisCount++;
        }
      }
      paymentMethod = PaymentMethodData(cash: cashCount, qris: qrisCount);

      // ── Low stock ──
      lowStockItems = products
          .where((p) => p.stock < 20)
          .take(5)
          .map(
            (p) => LowStockItem(
              name: p.name,
              count: '${p.stock} items',
              color: p.stock < 5
                  ? AppColors.red
                  : p.stock < 10
                  ? const Color(0xFFF97316)
                  : const Color(0xFFFACC15),
            ),
          )
          .toList();

      // ── Recent transactions ──
      final sortedTx = List<Transaction>.from(transactions);
      sortedTx.sort((a, b) {
        final aDate = a.transactionDate ?? DateTime(2000);
        final bDate = b.transactionDate ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });
      recentTransactions = sortedTx.take(5).map((t) {
        return TransaksiItem(
          items: t.transactionCode ?? '-',
          cashier: t.paymentMethod.name,
          amount: 'Rp${_formatRupiah(t.totalAmount)}',
        );
      }).toList();

      // ── Top products ──
      topProducts = dashboardData.topProducts.take(10).map((tp) {
        return TopProductItem(name: tp.productName, pcs: tp.totalQuantity);
      }).toList();
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _formatRupiah(double value) {
    final intVal = value.toInt();
    final str = intVal.toString();
    final result = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) result.write('.');
      result.write(str[i]);
    }
    return result.toString();
  }
}
