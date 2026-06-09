import 'package:flutter/material.dart';
import 'package:smartkasir/models/auth.dart';
import 'package:smartkasir/models/product.dart';
import 'package:smartkasir/models/report.dart';
import 'package:smartkasir/models/transaction.dart';
import 'package:smartkasir/services/auth_service.dart';
import 'package:smartkasir/services/product_service.dart';
import 'package:smartkasir/services/report_service.dart';
import 'package:smartkasir/services/transaction_service.dart';

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

  const TopProductItem({
    required this.name, 
    required this.pcs
    });
}

class PaymentMethodData {
  final int cash;
  final int qris;
  final int debit;
  final int credit;

  const PaymentMethodData({
    required this.cash,
    required this.qris,
    this.debit = 0,
    this.credit = 0,
  });

  int get total => cash + qris + debit + credit;
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

  void returnToSettings(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> loadData() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final now = DateTime.now();
      final todayStr = _formatDate(now);

      // Load data in parallel
      final results = await Future.wait([
        _reportService.getDailySales(date: todayStr).catchError((_) => <String, dynamic>{}),
        _transactionService.getAll().catchError((_) => <Transaction>[]),
        _productService.getAll().catchError((_) => <Product>[]),
        _reportService.getTopProducts(
              startDate: _formatDate(now.subtract(const Duration(days: 30))),
              endDate: todayStr,
            ).catchError((_) => <TopProductDTO>[]),
        _reportService.getMonthlySales(month: now.month, year: now.year).catchError((_) => <String, dynamic>{}),
        _authService.getProfile().catchError((_) => null),
      ]);

      final dailySales = results[0] as Map<String, dynamic>;
      final transactions = results[1] as List<Transaction>;
      final products = results[2] as List<Product>;
      final topProductsData = results[3] as List<TopProductDTO>;
      final monthlySales = results[4] as Map<String, dynamic>;
      final profile = results[5] as AuthResponse?;

      if (profile != null) {
        storeName = profile.store.businessName.toUpperCase();
      }

      // ── Stat cards ──
      final revenue = (dailySales['totalRevenue'] ?? 0).toDouble();
      final txCount = (dailySales['transactionCount'] ?? 0);

      String formatRevenue(double val) {
        if (val >= 1000000) {
          return 'Rp ${(val / 1000000).toStringAsFixed(1)} jt';
        }
        if (val >= 1000) return 'Rp ${(val / 1000).toStringAsFixed(0)} rb';
        return 'Rp ${val.toInt()}';
      }

      statCards = [
        StatCardData(
          label: 'Pendapatan',
          value: formatRevenue(revenue),
          badge: 'Hari ini',
          badgeColor: const Color(0xFF22C55E),
          badgeBg: const Color(0xFFDCFCE7),
        ),
        StatCardData(
          label: 'Transaksi',
          value: '$txCount',
          badge: '$txCount transaksi',
          badgeColor: const Color(0xFF22C55E),
          badgeBg: const Color(0xFFDCFCE7),
        ),
      ];

      // Calculate products sold today
      final todayTx = transactions.where((t) {
        if (t.transactionDate == null) return false;
        return t.transactionDate!.year == now.year &&
            t.transactionDate!.month == now.month &&
            t.transactionDate!.day == now.day;
      }).toList();

      final avgTransaction = todayTx.isNotEmpty
          ? todayTx.fold<double>(0, (s, t) => s + t.totalAmount) /
                todayTx.length
          : 0.0;

      statCardsRow2 = [
        StatCardData(
          label: 'Rata - Rata',
          value: formatRevenue(avgTransaction),
          badge: 'Per transaksi',
          badgeColor: const Color(0xFF22C55E),
          badgeBg: const Color(0xFFDCFCE7),
        ),
        StatCardData(
          label: 'Total Produk',
          value: '${products.length}',
          badge: '${products.where((p) => p.stock < 20).length} stok rendah',
          badgeColor: const Color(0xFFEF4444),
          badgeBg: const Color(0xFFFEE2E2),
        ),
      ];

      // ── Revenue chart (last 7 days) ──
      chartDays = [];
      chartValues = [];
      final dayLabels = ['min', 'sen', 'sel', 'rab', 'kam', 'jum', 'sab'];

      // Fetch 7 hari secara parallel
      final dailyFutures = List.generate(7, (i) {
        final day = now.subtract(Duration(days: 6 - i));
        return _reportService
            .getDailySales(date: _formatDate(day))
            .catchError((_) => <String, dynamic>{});
      });

      final dailyResults = await Future.wait(dailyFutures);

      for (int i = 0; i < 7; i++) {
        final day = now.subtract(Duration(days: 6 - i));
        final data = dailyResults[i] as Map<String, dynamic>;
        chartDays.add(dayLabels[day.weekday % 7]);
        chartValues.add((data['totalRevenue'] ?? 0).toDouble());
      }

      // Prevent division by zero
      if (chartValues.every((v) => v == 0)) {
        chartValues = List.filled(7, 1.0);
      }

      // ── Payment method breakdown ──
      int cashCount = 0, qrisCount = 0, debitCount = 0, creditCount = 0;
      for (final t in transactions) {
        switch (t.paymentMethod) {
          case PaymentMethod.CASH:
            cashCount++;
            break;
          case PaymentMethod.QRIS:
            qrisCount++;
            break;
          case PaymentMethod.DEBIT:
            debitCount++;
            break;
          case PaymentMethod.CREDIT:
            creditCount++;
            break;
        }
      }
      paymentMethod = PaymentMethodData(
        cash: cashCount,
        qris: qrisCount,
        debit: debitCount,
        credit: creditCount,
      );

      // ── Low stock ──
      lowStockItems = products
          .where((p) => p.stock < 20)
          .take(5)
          .map(
            (p) => LowStockItem(
              name: p.name,
              count: '${p.stock} items',
              color: p.stock < 5
                  ? const Color(0xFFEF4444)
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
      topProducts = topProductsData.take(10).map((tp) {
        return TopProductItem(name: tp.productName, pcs: tp.quantitySold);
      }).toList();
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
