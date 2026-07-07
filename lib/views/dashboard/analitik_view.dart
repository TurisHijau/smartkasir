import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/viewmodels/dashboard/analitik_viewmodel.dart';
import 'package:smartkasir/viewmodels/settings/settings_viewmodel.dart';
import 'package:smartkasir/widgets/app_ui.dart';

class AnalitikView extends StatefulWidget {
  const AnalitikView({super.key});

  @override
  State<AnalitikView> createState() => _AnalitikViewState();
}

class _AnalitikViewState extends State<AnalitikView> {
  final _vm = AnalitikViewModel();
  final vm = SettingsViewModel();

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) => Container(
        // gradient background
        decoration: AppUi.gradientBackground,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                //  Header
                AppScreenHeader(
                  title: 'Analitik',
                  onBack: () => _vm.returnToSettings(context),
                ),

                //  border radius atas
                Expanded(
                  child: AppPanel(
                    padding: EdgeInsets.zero,
                    clip: true,
                    child: ClipRRect(
                      borderRadius: AppUi.panelBorderRadius,
                      child: _vm.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _vm.errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: AppColors.gray,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _vm.errorMessage!,
                                    style: const TextStyle(
                                      color: AppColors.darkGray,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () => _vm.loadData(),
                                    child: const Text("Coba Lagi"),
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                30,
                                20,
                                30,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildStoreInfo(),
                                  const SizedBox(height: 16),
                                  if (!_vm.isCashier) ...[
                                    _sectionTitle(
                                      'Ringkasan Bisnis',
                                      'Angka utama dan prioritas yang perlu dicek',
                                    ),
                                    const SizedBox(height: 10),
                                    _buildStatCards(_vm.statCards),
                                    const SizedBox(height: 12),
                                    _buildStatCards(_vm.statCardsRow2),
                                    const SizedBox(height: 16),
                                    _buildBusinessInsights(),
                                    const SizedBox(height: 18),
                                    _sectionTitle(
                                      'Penjualan',
                                      'Tren pendapatan dan metode pembayaran',
                                    ),
                                    const SizedBox(height: 10),
                                    if (_vm.chartValues.isNotEmpty) ...[
                                      _buildRevenueChart(),
                                      const SizedBox(height: 16),
                                    ],
                                    _buildPaymentMethod(),
                                    const SizedBox(height: 18),
                                    _sectionTitle(
                                      'Produk',
                                      'Produk paling laku dan paling menghasilkan',
                                    ),
                                    const SizedBox(height: 10),
                                    _buildTopProducts(),
                                    const SizedBox(height: 16),
                                    _buildTopRevenueProducts(),
                                    const SizedBox(height: 18),
                                    _sectionTitle(
                                      'Stok',
                                      'Produk yang perlu restock atau dipantau',
                                    ),
                                    const SizedBox(height: 10),
                                    _buildLowStock(),
                                    const SizedBox(height: 16),
                                    _buildSlowMovingProducts(),
                                    const SizedBox(height: 18),
                                    _sectionTitle(
                                      'Operasional',
                                      'Performa kasir dan riwayat transaksi',
                                    ),
                                    const SizedBox(height: 10),
                                    _buildCashierPerformance(),
                                    const SizedBox(height: 16),
                                  ],
                                  _buildRecentTransactions(),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreInfo() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: AppUi.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(color: AppColors.primary),
              children: [
                TextSpan(
                  text: _vm.storeName,
                  style: AppTextStyles.analyticsCardTitle,
                ),
                TextSpan(
                  text: ' - ${_vm.storeDate}',
                  style: AppTextStyles.listBody,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_vm.periodLabels.length, (i) {
              return Padding(
                padding: EdgeInsets.only(
                  right: i < _vm.periodLabels.length - 1 ? 8 : 0,
                ),
                child: _periodButton(_vm.periodLabels[i], i),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _periodButton(String label, int index) {
    final isSelected = _vm.selectedPeriod == index;
    return GestureDetector(
      onTap: () => _vm.selectPeriod(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.darkGray,
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.analyticsSectionTitle),
        const SizedBox(height: 2),
        Text(subtitle, style: AppTextStyles.analyticsCaption),
      ],
    );
  }

  // ─── Stat cards ───────────────────────────────────────────────────────────

  Widget _buildStatCards(List<StatCardData> cards) {
    return Row(
      children: cards.asMap().entries.map((e) {
        final isLast = e.key == cards.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 12),
            child: _statCard(e.value),
          ),
        );
      }).toList(),
    );
  }

  Widget _statCard(StatCardData data) {
    return Container(
      padding: AppUi.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label,
            style: AppTextStyles.analyticsCaption.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(data.value, style: AppTextStyles.analyticsValue),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: data.badgeBg,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Text(
              data.badge,
              style: AppTextStyles.listBadge.copyWith(color: data.badgeColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInsights() {
    return _analyticsCard(
      title: 'Insight Cepat',
      emptyIcon: Icons.insights_outlined,
      emptyTitle: 'Belum Ada Insight',
      emptySubtitle: 'Insight muncul setelah ada transaksi',
      isEmpty: _vm.businessInsights.isEmpty,
      child: Column(children: _vm.businessInsights.map(_insightRow).toList()),
    );
  }

  Widget _insightRow(InsightItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTextStyles.analyticsRowTitle),
                const SizedBox(height: 2),
                Text(item.description, style: AppTextStyles.analyticsCaption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Revenue chart ────────────────────────────────────────────────────────

  Widget _buildRevenueChart() {
    return Container(
      padding: AppUi.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tren Pendapatan',
            style: AppTextStyles.analyticsCardTitle,
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 164,
            child: CustomPaint(
              painter: LineChartPainter(
                values: _vm.chartValues,
                labels: _vm.chartDays,
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Payment method ───────────────────────────────────────────────────────

  Widget _buildPaymentMethod() {
    final pm = _vm.paymentMethod;
    return Container(
      padding: AppUi.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metode Pembayaran',
            style: AppTextStyles.analyticsCardTitle,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CustomPaint(
                  painter: DonutChartPainter(
                    values: [pm.cashRatio, pm.qrisRatio],
                    colors: const [AppColors.secondary, AppColors.tertiary],
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _legendItem(
                    AppColors.secondary,
                    'Cash',
                    '${pm.cash} transaksi • ${_vm.formatCompactRupiah(pm.cashRevenue)}',
                  ),
                  const SizedBox(height: 12),
                  _legendItem(
                    AppColors.tertiary,
                    'QRIS',
                    '${pm.qris} transaksi • ${_vm.formatCompactRupiah(pm.qrisRevenue)}',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, String sub) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.listBodyStrong.copyWith(color: color),
            ),
            Text(
              sub,
              style: AppTextStyles.listBadge.copyWith(
                color: AppColors.darkGray,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Low stock ────────────────────────────────────────────────────────────

  Widget _buildLowStock() {
    return Container(
      padding: AppUi.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stok Perlu Restock',
            style: AppTextStyles.analyticsCardTitle,
          ),
          const SizedBox(height: 12),
          if (_vm.lowStockItems.isEmpty)
            Center(
              child: Column(
                children: const [
                  SizedBox(height: 32),
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: AppColors.gray,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Semua stok aman',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.analyticsEmptyTitle,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tidak ada produk yang hampir habis saat ini',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.analyticsCaption,
                  ),
                  SizedBox(height: 48),
                ],
              ),
            )
          else
            ..._vm.lowStockItems.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTextStyles.analyticsRowTitle,
                      ),
                    ),
                    Text(
                      item.count,
                      style: AppTextStyles.analyticsRowTitle.copyWith(
                        color: item.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => vm.navigateToProducts(context),
            child: const Center(
              child: Text(
                'Lihat Selengkapnya →',
                style: AppTextStyles.analyticsLink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Recent transactions ──────────────────────────────────────────────────

  Widget _buildRecentTransactions() {
    return Container(
      padding: AppUi.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Riwayat Transaksi',
            style: AppTextStyles.analyticsCardTitle,
          ),
          const SizedBox(height: 14),
          if (_vm.recentTransactions.isEmpty)
            Center(
              child: Column(
                children: const [
                  SizedBox(height: 28),
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 46,
                    color: AppColors.gray,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Belum Ada Transaksi',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.analyticsEmptyTitle,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Riwayat muncul setelah transaksi dibuat',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.analyticsCaption,
                  ),
                ],
              ),
            )
          else
            ..._vm.recentTransactions.map(
              (t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: AppColors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.items, style: AppTextStyles.analyticsRowTitle),
                          Text(
                            'Metode: ${t.cashier}',
                            style: AppTextStyles.analyticsCaption,
                          ),
                        ],
                      ),
                    ),
                    Text(t.amount, style: AppTextStyles.analyticsRowTitle),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => vm.TransactionHistory(context),
            child: const Center(
              child: Text(
                'Lihat Riwayat Lengkap →',
                style: AppTextStyles.analyticsLink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Top products ─────────────────────────────────────────────────────────

  Widget _buildTopProducts() {
    return Container(
      width: double.infinity,
      padding: AppUi.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Produk Terlaris (Qty)',
            style: AppTextStyles.analyticsCardTitle,
          ),
          const SizedBox(height: 12),
          if (_vm.topProducts.isEmpty)
            Center(
              child: Column(
                children: const [
                  SizedBox(height: 32),
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 48,
                    color: AppColors.gray,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Produk Kosong',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.analyticsEmptyTitle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Belum ada produk terlaris saat ini',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.analyticsCaption,
                  ),
                  SizedBox(height: 24),
                ],
              ),
            )
          else
            ..._vm.topProducts.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        '${e.key + 1}',
                        style: AppTextStyles.listBodyStrong,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        e.value.name,
                        style: AppTextStyles.listBodyStrong,
                      ),
                    ),
                    Text('${e.value.pcs} pcs', style: AppTextStyles.listBody),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopRevenueProducts() {
    return _analyticsCard(
      title: 'Produk Paling Menghasilkan',
      emptyIcon: Icons.leaderboard_outlined,
      emptyTitle: 'Belum Ada Data Revenue',
      emptySubtitle: 'Data muncul setelah ada transaksi',
      isEmpty: _vm.topRevenueProducts.isEmpty,
      child: Column(
        children: _vm.topRevenueProducts.asMap().entries.map((e) {
          final item = e.value;
          return _rankedMetricRow(
            rank: e.key + 1,
            title: item.name,
            subtitle: '${item.pcs} pcs • Profit ${item.profit}',
            trailing: item.revenue,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCashierPerformance() {
    return _analyticsCard(
      title: 'Performa Kasir Bulan Ini',
      emptyIcon: Icons.badge_outlined,
      emptyTitle: 'Belum Ada Data Kasir',
      emptySubtitle: 'Data muncul setelah kasir membuat transaksi',
      isEmpty: _vm.cashierPerformance.isEmpty,
      child: Column(
        children: _vm.cashierPerformance.map((item) {
          return _metricRow(
            icon: Icons.person_outline,
            title: item.name,
            subtitle:
                '${item.transactions} transaksi • Rata-rata ${item.averageTransaction}',
            trailing: item.revenue,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSlowMovingProducts() {
    return _analyticsCard(
      title: 'Produk Slow Moving ${_vm.slowMovingPeriodLabel}',
      emptyIcon: Icons.hourglass_empty,
      emptyTitle: 'Belum Ada Data Produk',
      emptySubtitle: 'Data muncul setelah produk dan transaksi tersedia',
      isEmpty: _vm.slowMovingProducts.isEmpty,
      child: Column(
        children: _vm.slowMovingProducts.map((item) {
          return _metricRow(
            icon: Icons.inventory_2_outlined,
            title: item.name,
            subtitle: 'Terjual ${item.sold} pcs ${_vm.slowMovingPeriodLabel}',
            trailing: '${item.stock} stok',
          );
        }).toList(),
      ),
    );
  }

  Widget _analyticsCard({
    required String title,
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptySubtitle,
    required bool isEmpty,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: AppUi.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.analyticsCardTitle),
          const SizedBox(height: 12),
          if (isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 28),
                  Icon(emptyIcon, size: 46, color: AppColors.gray),
                  const SizedBox(height: 14),
                  Text(
                    emptyTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.analyticsEmptyTitle,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    emptySubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.analyticsCaption,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            )
          else
            child,
        ],
      ),
    );
  }

  Widget _rankedMetricRow({
    required int rank,
    required String title,
    required String subtitle,
    required String trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('$rank', style: AppTextStyles.listBodyStrong),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.analyticsRowTitle),
                Text(subtitle, style: AppTextStyles.analyticsCaption),
              ],
            ),
          ),
          Text(trailing, style: AppTextStyles.analyticsRowTitle),
        ],
      ),
    );
  }

  Widget _metricRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.lightGray,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.analyticsRowTitle),
                Text(subtitle, style: AppTextStyles.analyticsCaption),
              ],
            ),
          ),
          Text(trailing, style: AppTextStyles.analyticsRowTitle),
        ],
      ),
    );
  }
}

// ─── Custom Painters ──────────────────────────────────────────────────────────

class LineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;

  LineChartPainter({required this.values, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final double maxVal = values.reduce(math.max);
    final double minVal = 0;
    final double range = maxVal - minVal;
    final double chartH = size.height - 24;
    final double effectiveMax = maxVal == 0 ? 1.0 : maxVal;
    final double effectiveRange = range == 0 ? 1.0 : range;

    final yAxisPaint = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..strokeWidth = 0.5;
    const textStyle = TextStyle(fontSize: 10, color: Color(0xFF9CA3AF));

    for (final yVal in [0.0, effectiveMax / 2, effectiveMax]) {
      final dy = chartH - (yVal / effectiveMax) * chartH;
      canvas.drawLine(Offset(28, dy), Offset(size.width, dy), yAxisPaint);

      String labelText = '0';
      if (yVal > 0) {
        if (yVal >= 1000000) {
          labelText = '${(yVal / 1000000).toStringAsFixed(1)}jt';
        } else if (yVal >= 1000) {
          labelText = '${(yVal / 1000).toStringAsFixed(0)}rb';
        } else {
          labelText = yVal.toInt().toString();
        }
      }
      final tp = TextPainter(
        text: TextSpan(text: labelText, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, dy - 6));
    }

    List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      final double x = values.length > 1
          ? 28 + i * ((size.width - 28) / (values.length - 1))
          : size.width / 2;
      final double y =
          chartH - ((values[i] - minVal) / effectiveRange) * chartH;
      points.add(Offset(x, y));
    }

    // Gradient fill
    final fillPath = Path()..moveTo(points.first.dx, chartH);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, chartH);
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.01),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, chartH)),
    );

    // Line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots
    for (final p in points) {
      canvas.drawCircle(p, 4, Paint()..color = Colors.white);
      canvas.drawCircle(
        p,
        4,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // X labels
    for (int i = 0; i < labels.length; i++) {
      final double x = labels.length > 1
          ? 28 + i * ((size.width - 28) / (labels.length - 1))
          : size.width / 2;
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, chartH + 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  DonutChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.38;

    double startAngle = -math.pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweepAngle = 2 * math.pi * values[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
