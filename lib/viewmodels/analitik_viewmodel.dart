import 'package:flutter/material.dart';

// ─── Model Classes ───────────────────────────────────────────────────────────

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
  double get cashRatio => cash / total;
  double get qrisRatio => qris / total;
}

// ─── ViewModel ───────────────────────────────────────────────────────────────

class AnalitikViewModel extends ChangeNotifier {
  // ── Store info ──
  final String storeName = 'TOKO PAK KUMIS';
  final String storeDate = 'Sen, 4 Mei 2026';
  final List<String> periodLabels = ['Hari ini', 'Minggu ini', 'Bulan ini'];

  int _selectedPeriod = 0;
  int get selectedPeriod => _selectedPeriod;

  void selectPeriod(int index) {
    _selectedPeriod = index;
    notifyListeners();
  }

  // ── Stat cards row 1 ──
  final List<StatCardData> statCards = const [
    StatCardData(
      label: 'Pendapatan',
      value: 'Rp 1,5 jt',
      badge: '+12% kemarin',
      badgeColor: Color(0xFF22C55E),
      badgeBg: Color(0xFFDCFCE7),
    ),
    StatCardData(
      label: 'Transaksi',
      value: '67',
      badge: '+5 transaksi',
      badgeColor: Color(0xFF22C55E),
      badgeBg: Color(0xFFDCFCE7),
    ),
  ];

  // ── Stat cards row 2 ──
  final List<StatCardData> statCardsRow2 = const [
    StatCardData(
      label: 'Rata - Rata',
      value: 'Rp 67rb',
      badge: '+12% kemarin',
      badgeColor: Color(0xFF22C55E),
      badgeBg: Color(0xFFDCFCE7),
    ),
    StatCardData(
      label: 'Produk terjual',
      value: '6767',
      badge: '-67 pcs',
      badgeColor: Color(0xFFEF4444),
      badgeBg: Color(0xFFFEE2E2),
    ),
  ];

  // ── Revenue chart ──
  final List<String> chartDays = const [
    'senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu', 'minggu',
  ];

  final List<double> chartValues = const [
    55000, 48000, 62000, 41000, 58000, 65000, 42000,
  ];

  // ── Payment method ──
  final PaymentMethodData paymentMethod = const PaymentMethodData(
    cash: 145,
    qris: 55,
  );

  // ── Low stock ──
  final List<LowStockItem> lowStockItems = const [
    LowStockItem(name: 'Aqua 600ml',  count: '3 items',  color: Color(0xFFEF4444)),
    LowStockItem(name: 'Milo Sachet', count: '4 items',  color: Color(0xFFEF4444)),
    LowStockItem(name: 'Indomie',     count: '15 items', color: Color(0xFFF97316)),
    LowStockItem(name: 'Sarimi',      count: '20 items', color: Color(0xFFFACC15)),
  ];

  // ── Recent transactions ──
  final List<TransaksiItem> recentTransactions = const [
    TransaksiItem(items: '10 Items', cashier: 'Satria Cahya Ramadhani', amount: 'Rp167.000,00'),
    TransaksiItem(items: '25 Items', cashier: 'I Putu Dandy Pradnyana',  amount: 'Rp267.000,00'),
    TransaksiItem(items: '2 Items',  cashier: 'I Putu Dandy Pradnyana',  amount: 'Rp7.000,00'),
    TransaksiItem(items: '6 Items',  cashier: 'Eki Mukhlis',             amount: 'Rp37.000,00'),
  ];

  // ── Top products ──
  final List<TopProductItem> topProducts = const [
    TopProductItem(name: 'Aqua 600ml',    pcs: 76),
    TopProductItem(name: 'Indomie',       pcs: 67),
    TopProductItem(name: 'Beras 3KG',     pcs: 51),
    TopProductItem(name: 'Teh Botol Sosro', pcs: 27),
    TopProductItem(name: 'Minyak Goreng', pcs: 27),
    TopProductItem(name: 'Gas LPG 3KG',  pcs: 20),
    TopProductItem(name: 'Kopi Good Day', pcs: 18),
    TopProductItem(name: 'Saos Sambal',  pcs: 16),
    TopProductItem(name: 'Kecap Bango',  pcs: 10),
    TopProductItem(name: 'Paracetamol',  pcs: 5),
  ];
}