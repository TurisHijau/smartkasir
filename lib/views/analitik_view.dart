import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/viewmodels/analitik_viewmodel.dart';


class AnalitikView extends StatefulWidget {
  const AnalitikView({super.key});

  @override
  State<AnalitikView> createState() => _AnalitikViewState();
}

class _AnalitikViewState extends State<AnalitikView> {
  final _vm = AnalitikViewModel();

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
        // ── Gradient background sama seperti list_pegawai_view ──
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.tertiary, AppColors.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header di atas gradient ──
                _buildHeader(context),

                // ── Konten putih dengan border radius atas ──
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 18),
                    decoration: const BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(45),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(45),
                      ),
                      child: _vm.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _vm.errorMessage != null
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.error_outline, size: 48, color: AppColors.gray),
                                      const SizedBox(height: 12),
                                      Text(_vm.errorMessage!, style: const TextStyle(color: AppColors.darkGray)),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: () => _vm.loadData(),
                                        child: const Text("Coba Lagi"),
                                      ),
                                    ],
                                  ),
                                )
                              : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStoreInfo(),
                              const SizedBox(height: 16),
                              _buildStatCards(_vm.statCards),
                              const SizedBox(height: 12),
                              _buildStatCards(_vm.statCardsRow2),
                              const SizedBox(height: 16),
                              if (_vm.chartValues.isNotEmpty) _buildRevenueChart(),
                              if (_vm.chartValues.isNotEmpty) const SizedBox(height: 16),
                              _buildPaymentMethod(),
                              const SizedBox(height: 16),
                              _buildLowStock(),
                              const SizedBox(height: 16),
                              _buildRecentTransactions(),
                              const SizedBox(height: 16),
                              _buildTopProducts(),
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

  // ─── Header (di atas area gradient, sama seperti list_pegawai) ────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 16, 0),
      child: SizedBox(
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Analitik',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Store info + period toggle ───────────────────────────────────────────

  Widget _buildStoreInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                TextSpan(
                  text: ' - ${_vm.storeDate}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_vm.periodLabels.length, (i) {
              return Padding(
                padding: EdgeInsets.only(right: i < _vm.periodLabels.length - 1 ? 8 : 0),
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
          borderRadius: BorderRadius.circular(20),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.darkGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: data.badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              data.badge,
              style: TextStyle(
                fontSize: 11,
                color: data.badgeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Revenue chart ────────────────────────────────────────────────────────

  Widget _buildRevenueChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pendapatan 7 hari terakhir',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: DonutChartPainter(
                    values: [pm.cashRatio, pm.qrisRatio],
                    colors: const [Color(0xFF2176D9), Color(0xFF93C5FD)],
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _legendItem(const Color(0xFF2176D9), 'Cash', '${pm.cash} transaksi'),
                  const SizedBox(height: 12),
                  _legendItem(const Color(0xFF93C5FD), 'QRIS', '${pm.qris} transaksi'),
                ],
              ),
            ],
          ),
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
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            Text(
              sub,
              style: const TextStyle(fontSize: 11, color: AppColors.darkGray),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Low stock ────────────────────────────────────────────────────────────

  Widget _buildLowStock() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stok hampir habis',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
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
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    item.count,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: item.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Lihat Selengkapnya →',
              style: const TextStyle(fontSize: 12, color: AppColors.darkGray),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Recent transactions ──────────────────────────────────────────────────

  Widget _buildRecentTransactions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaksi terakhir',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          ..._vm.recentTransactions.map(
            (t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
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
                        Text(
                          t.items,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Pegawai : ${t.cashier}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.darkGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    t.amount,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: const Text(
              'Lihat Selengkapnya →',
              style: TextStyle(fontSize: 12, color: AppColors.darkGray),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Top products ─────────────────────────────────────────────────────────

  Widget _buildTopProducts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Produk Terlaris Hari Ini',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          ..._vm.topProducts.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${e.key + 1}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.value.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    '${e.value.pcs} pcs',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
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

    final yAxisPaint = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..strokeWidth = 0.5;
    const textStyle = TextStyle(fontSize: 10, color: Color(0xFF9CA3AF));

    for (final yVal in [0.0, 35000.0, 70000.0]) {
      final dy = chartH - (yVal / maxVal) * chartH;
      canvas.drawLine(Offset(28, dy), Offset(size.width, dy), yAxisPaint);
      final tp = TextPainter(
        text: TextSpan(
          text: yVal == 0 ? '0' : '${(yVal / 1000).round()}000',
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, dy - 6));
    }

    List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      final x = 28 + i * ((size.width - 28) / (values.length - 1));
      final y = chartH - ((values[i] - minVal) / range) * chartH;
      points.add(Offset(x, y));
    }

    // Gradient fill
    final fillPath = Path()..moveTo(points.first.dx, chartH);
    for (final p in points) fillPath.lineTo(p.dx, p.dy);
    fillPath.lineTo(points.last.dx, chartH);
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.primary.withOpacity(0.01),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, chartH)),
    );

    // Line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) linePath.lineTo(points[i].dx, points[i].dy);
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
      final x = 28 + i * ((size.width - 28) / (labels.length - 1));
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