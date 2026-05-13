import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/viewmodels/settings/settings_viewmodel.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    returnImage: false,
  );

  bool _isCameraOn = true;
  bool _isFlashOn = false;

  final Map<String, DateTime> _lastScanTimes = {};
  final List<_CartItemPlaceholder> _cartItems = [];

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final now = DateTime.now();

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue == null) continue;

      final lastScan = _lastScanTimes[rawValue];
      if (lastScan != null && now.difference(lastScan).inSeconds < 2) continue;

      _lastScanTimes[rawValue] = now;

      if (await Vibration.hasVibrator() != false) {
        Vibration.vibrate(duration: 200);
      }

      if (mounted) _showBarcodeSnackBar(rawValue);

      break;
    }
  }

  void _showBarcodeSnackBar(String value) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Barcode Terdeteksi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cameraHeight = screenHeight * 0.42;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // AREA KAMERA
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: cameraHeight,
            child: _buildCameraSection(),
          ),

          Positioned(
            top: cameraHeight - 26,
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomPanel(),
          ),
        ],
      ),

      // TOMBOL BAWAH
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  // KAMERA
  Widget _buildCameraSection() {
    return ClipRRect(
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_isCameraOn)
              MobileScanner(
                key: const ValueKey('camera'),
                controller: _scannerController,
                onDetect: _onDetect,
              )
            else
              _buildCameraOffState(),

            // SCAN AREA
            if (_isCameraOn) _buildScanOverlay(),

            // TOMBOL OVERLAY
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 14,
              child: Column(
                children: [
                  _overlayButton(
                    icon: Icons.settings_outlined,
                    onTap: () {
                    },
                  ),
                  const SizedBox(height: 12),
                  if (_isCameraOn)
                    _overlayButton(
                      icon: _isFlashOn
                          ? Icons.flashlight_off_outlined
                          : Icons.flashlight_on_outlined,
                      onTap: () {
                        setState(() => _isFlashOn = !_isFlashOn);
                        _scannerController.toggleTorch();
                      },
                    ),
                  if (_isCameraOn) const SizedBox(height: 12),
                  _overlayButton(
                    icon: _isCameraOn
                        ? Icons.camera_alt_outlined
                        : Icons.no_photography_outlined,
                    onTap: _toggleCamera,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TOGGLE KAMERA
  Future<void> _toggleCamera() async {
    if (_isCameraOn) {
      await _scannerController.stop();
    } else {
      await _scannerController.start();
    }

    if (mounted) {
      setState(() => _isCameraOn = !_isCameraOn);
    }
  }

  Widget _buildScanOverlay() {
    return Center(
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            _scanCorner(Alignment.topLeft),
            _scanCorner(Alignment.topRight),
            _scanCorner(Alignment.bottomLeft),
            _scanCorner(Alignment.bottomRight),
          ],
        ),
      ),
    );
  }

  Widget _scanCorner(Alignment alignment) {
    const color = AppColors.tertiary;
    final isTop =
        alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final isLeft =
        alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;

    return Align(
      alignment: alignment,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: color, width: 3.5)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: color, width: 3.5)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: color, width: 3.5)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: color, width: 3.5)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCameraOffState() {
    return Container(
      color: const Color(0xFF1A2235),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFF263045),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Kamera Sedang Mati',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 36),
            child: Text(
              'Nyalakan kamera untuk memindai barcode',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              elevation: 0,
            ),
            onPressed: _toggleCamera,
            child: const Text(
              'Nyalakan Kamera',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _overlayButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // PANEL BAWAH

  Widget _buildBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _buildCartHeader(),
          Divider(height: 1, color: Colors.grey[600]),
          Expanded(
            child: _cartItems.isEmpty ? _buildEmptyCart() : _buildCartList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCartHeader() {
    final totalItems = _cartItems.fold<int>(0, (s, i) => s + i.quantity);
    final totalHarga = _cartItems.fold<double>(
      0,
      (s, i) => s + (i.harga * i.quantity),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Barang yang dibeli',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
              Text(
                'Total $totalItems items',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total Harga',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Rp${_formatRupiah(totalHarga)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_basket_outlined,
              size: 42,
              color: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Keranjang Belanja Kosong',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Scan barcode pada produk dan item akan muncul secara otomatis disini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: _cartItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) => _buildCartItemCard(_cartItems[index], index),
    );
  }

  Widget _buildCartItemCard(_CartItemPlaceholder item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp${_formatRupiah(item.harga)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          _quantityControl(item, index),
        ],
      ),
    );
  }

  Widget _quantityControl(_CartItemPlaceholder item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyButton(
            icon: Icons.remove,
            onTap: () => setState(() {
              if (item.quantity > 1) {
                _cartItems[index] = item.copyWith(quantity: item.quantity - 1);
              } else {
                _cartItems.removeAt(index);
              }
            }),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          _qtyButton(
            icon: Icons.add,
            onTap: () => setState(() {
              _cartItems[index] = item.copyWith(quantity: item.quantity + 1);
            }),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: Colors.grey[600]),
      ),
    );
  }

  // TOMBOL BAWAH

  Widget _buildBottomButtons() {
    final isEmpty = _cartItems.isEmpty;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tombol Input Manual
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _showInputManualSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Input Manual',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Tombol Review Belanja
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isEmpty ? null : _showReviewSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF2A2D3A),
                    disabledForegroundColor: Colors.white38,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Review Belanja',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // POPUP INPUT MANUAL
  void _showInputManualSheet() {
    final kodeController = TextEditingController();
    final namaController = TextEditingController();
    final jumlahController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dialogFieldLabel('Kode Produk'),
                  const SizedBox(height: 8),
                  _dialogTextField(
                    controller: kodeController,
                    hint: 'Masukkan Kode Produk',
                  ),
                  const SizedBox(height: 16),
                  _dialogFieldLabel('Nama Produk'),
                  const SizedBox(height: 8),
                  _dialogTextField(
                    controller: namaController,
                    hint: 'Masukkan Nama Produk',
                  ),
                  const SizedBox(height: 16),
                  _dialogFieldLabel('Jumlah'),
                  const SizedBox(height: 8),
                  _dialogTextField(
                    controller: jumlahController,
                    hint: 'Masukkan Jumlah',
                    isNumber: true,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        final kode = kodeController.text.trim();
                        final nama = namaController.text.trim();
                        final jumlah = int.tryParse(jumlahController.text) ?? 1;

                        if (kode.isNotEmpty && nama.isNotEmpty) {
                          setState(() {
                            _cartItems.insert(
                              0,
                              _CartItemPlaceholder(
                                barcode: kode,
                                nama: nama,
                                harga:
                                    15000, // Harga default karena di UI tidak ada field harga
                                quantity: jumlah,
                              ),
                            );
                          });
                          Navigator.pop(context);
                          _showBarcodeSnackBar('Produk "$nama" ditambahkan');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Tambah Produk',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // TOMBOL CLOSE (XMARK)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.grey, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _dialogTextField({
    required TextEditingController controller,
    required String hint,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black87, fontSize: 14),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  void _showReviewSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Review Belanja',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: _cartItems.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.grey[500]),
                  itemBuilder: (_, i) {
                    final item = _cartItems[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        item.nama,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Rp${_formatRupiah(item.harga)} × ${item.quantity}',
                      ),
                      trailing: Text(
                        'Rp${_formatRupiah(item.harga * item.quantity)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Divider(color: Colors.grey[600]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rp${_formatRupiah(_cartItems.fold(0.0, (s, i) => s + i.harga * i.quantity))}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────── HELPERS ───────────────────────────

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

/// Model placeholder item keranjang sebelum koneksi ke database
class _CartItemPlaceholder {
  final String barcode;
  final String nama;
  final double harga;
  final int quantity;

  const _CartItemPlaceholder({
    required this.barcode,
    required this.nama,
    required this.harga,
    required this.quantity,
  });

  _CartItemPlaceholder copyWith({int? quantity}) {
    return _CartItemPlaceholder(
      barcode: barcode,
      nama: nama,
      harga: harga,
      quantity: quantity ?? this.quantity,
    );
  }
}