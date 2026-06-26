import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smartkasir/models/product.dart';
import 'package:smartkasir/models/transaction.dart';
import 'package:smartkasir/services/product_service.dart';
import 'package:smartkasir/services/transaction_service.dart';
import 'package:smartkasir/utils/currency_input_formatter.dart';
import 'package:smartkasir/utils/printer_helper.dart';
import 'package:smartkasir/services/auth_service.dart';
import 'package:smartkasir/views/settings_view.dart';
import 'package:vibration/vibration.dart';
import 'package:smartkasir/constants/app_colors.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    returnImage: false,
  );
  final ProductService _productService = ProductService();
  final TransactionService _transactionService = TransactionService();
  final PrinterHelper _printerHelper = PrinterHelper();
  final AuthService _authService = AuthService();

  bool _isCameraOn = false;
  bool _isFlashOn = false;
  bool _isProcessingScan = false;

  final Map<String, DateTime> _lastScanTimes = {};
  final List<_CartItem> _cartItems = [];

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessingScan) return;
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

      // Look up product by barcode
      _isProcessingScan = true;
      try {
        final product = await _productService.findByBarcode(rawValue);
        if (product != null && mounted) {
          _addProductToCart(product);
          _showBarcodeSnackBar('Produk "${product.name}" ditambahkan');
        } else if (mounted) {
          _showBarcodeSnackBar(
            'Produk dengan barcode "$rawValue" tidak ditemukan',
            backgroundColor: Colors.red,
          );
        }
      } catch (e) {
        if (mounted) {
          _showBarcodeSnackBar(
            'Gagal mencari produk: $e',
            backgroundColor: Colors.red,
          );
        }
      } finally {
        _isProcessingScan = false;
      }

      break;
    }
  }

  void _addProductToCart(Product product) {
    setState(() {
      final existingIdx = _cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );
      if (existingIdx >= 0) {
        _cartItems[existingIdx] = _cartItems[existingIdx].copyWith(
          quantity: _cartItems[existingIdx].quantity + 1,
        );
      } else {
        _cartItems.insert(0, _CartItem(product: product, quantity: 1));
      }
    });
  }

  void _showBarcodeSnackBar(
    String value, {
    Color backgroundColor = AppColors.primary,
    bool anchorToBottom = false,
  }) {
    // If caller wants to anchor to the bottom buttons area (e.g. after
    // manual input), ignore the keyboard inset and use a fixed offset
    // above the bottom area. Otherwise position above the keyboard.
    final bottomInset = anchorToBottom
        ? (MediaQuery.of(context).padding.bottom + 100)
        : MediaQuery.of(context).viewInsets.bottom + 16;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
            const SizedBox(width: 12, height: 14),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 13, color: Colors.white),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.fromLTRB(16, 0, 16, bottomInset),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cameraHeight = screenHeight * 0.42;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    onTap: () async {
                      await _scannerController.stop();
                      setState(() => _isCameraOn = false);

                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsView(),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _overlayButton(
                    icon: _isCameraOn
                        ? Icons.camera_alt_outlined
                        : Icons.no_photography_outlined,
                    onTap: _toggleCamera,
                  ),
                  if (_isCameraOn) const SizedBox(height: 12),
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
      setState(() => _isCameraOn = false);
    } else {
      // Dispose controller lama dan buat baru
      await _scannerController.dispose();
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        returnImage: false,
      );
      setState(() {
        _isCameraOn = true;
        _isFlashOn = false;
      });
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
      (s, i) => s + (i.product.sellingPrice * i.quantity),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Barang yang dibeli',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
              Text(
                'Total $totalItems items',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total Harga',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Rp${_formatRupiah(totalHarga)}',
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

  Widget _buildCartItemCard(_CartItem item, int index) {
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
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp${_formatRupiah(item.product.sellingPrice)}',
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

  Widget _quantityControl(_CartItem item, int index) {
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
                height: 52,
                child: ElevatedButton(
                  onPressed: _showInputManualSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
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
                height: 52,
                child: ElevatedButton(
                  onPressed: isEmpty ? null : _showReviewSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF2A2D3A),
                    disabledForegroundColor: Colors.white38,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
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

  // POPUP INPUT MANUAL — now looks up barcode from API
  void _showInputManualSheet() {
    final kodeController = TextEditingController();
    bool isSearching = false;
    String? lookupError;
    String? lookupSuccess;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
          return AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: keyboardHeight + 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _dialogFieldLabel('Kode Produk'),
                              const SizedBox(height: 12),
                              TextField(
                                controller: kodeController,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.search,
                                onChanged: (_) {
                                  if (lookupError != null ||
                                      lookupSuccess != null) {
                                    setDialogState(() {
                                      lookupError = null;
                                      lookupSuccess = null;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'Masukkan Kode Produk',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              if (lookupSuccess != null) ...[
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 52,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            lookupSuccess!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ] else if (lookupError != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  lookupError!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: isSearching
                                      ? null
                                      : () async {
                                          final barcode = kodeController.text
                                              .trim();
                                          if (barcode.isEmpty) return;

                                          setDialogState(() {
                                            isSearching = true;
                                            lookupError = null;
                                          });
                                          try {
                                            final product =
                                                await _productService
                                                    .findByBarcode(barcode);
                                            if (product != null &&
                                                context.mounted) {
                                              // Add immediately, show inline success attached
                                              _addProductToCart(product);
                                              setDialogState(() {
                                                lookupSuccess =
                                                    'Produk "${product.name}" ditambahkan';
                                                isSearching = false;
                                              });
                                              await Future.delayed(
                                                const Duration(
                                                  milliseconds: 700,
                                                ),
                                              );
                                              if (context.mounted)
                                                Navigator.pop(context);
                                            } else if (context.mounted) {
                                              setDialogState(
                                                () => lookupError =
                                                    'Produk tidak ditemukan',
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              _showBarcodeSnackBar(
                                                'Error: $e',
                                                backgroundColor: Colors.red,
                                              );
                                            }
                                          } finally {
                                            if (context.mounted) {
                                              setDialogState(
                                                () => isSearching = false,
                                              );
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: AppColors.primary
                                        .withValues(alpha: 0.6),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: isSearching
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'Cari & Tambah Produk',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.grey,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _dialogFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: 18,
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
      style: const TextStyle(color: Colors.black87, fontSize: 18),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 18),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  void _showReviewSheet() {
    if (_isCameraOn) {
      _scannerController.stop();
    }

    final totalAmount = _cartItems.fold<double>(
      0,
      (s, i) => s + (i.product.sellingPrice * i.quantity),
    );
    final amountPaidController = TextEditingController();
    PaymentMethod selectedMethod = PaymentMethod.CASH;
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => AnimatedPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, scrollController) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    const Text(
                      'Review Belanja',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Cart items list
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _cartItems.length,
                      separatorBuilder: (_, __) => const Divider(
                        color: Color(0xFFEEEEEE),
                        height: 1,
                        thickness: 1,
                      ),
                      itemBuilder: (_, i) {
                        final item = _cartItems[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            item.product.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Rp${_formatRupiah(item.product.sellingPrice)} × ${item.quantity}',
                          ),
                          trailing: Text(
                            'Rp${_formatRupiah(item.product.sellingPrice * item.quantity)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    ),

                    const Divider(
                      color: Color(0xFFB0B0B0),
                      height: 1,
                      thickness: 1,
                    ),

                    const SizedBox(height: 8),

                    // Total row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rp${_formatRupiah(totalAmount)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Amount paid field
                    TextField(
                      controller: amountPaidController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      decoration: InputDecoration(
                        labelText: 'Jumlah Bayar',
                        hintText: 'Masukkan jumlah uang',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Payment method label
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Metode Pembayaran',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Payment method buttons (simple buttons + text)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: PaymentMethod.values.map((method) {
                          final isSelected = selectedMethod == method;
                          return SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () =>
                                  setSheetState(() => selectedMethod = method),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected
                                    ? AppColors.primary
                                    : Colors.grey[200],
                                foregroundColor: isSelected
                                    ? Colors.white
                                    : AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                              ),
                              child: Text(
                                method.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Process button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isProcessing
                            ? null
                            : () async {
                                final rawText = amountPaidController.text
                                    .replaceAll('.', '')
                                    .replaceAll(',', '');
                                final paid = double.tryParse(rawText) ?? 0;

                                if (paid < totalAmount &&
                                    selectedMethod == PaymentMethod.CASH) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Jumlah bayar kurang!'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                final effectivePaid =
                                    selectedMethod != PaymentMethod.CASH
                                    ? totalAmount
                                    : paid;

                                setSheetState(() => isProcessing = true);
                                try {
                                  final request = TransactionRequest(
                                    amountPaid: effectivePaid,
                                    paymentMethod: selectedMethod,
                                    items: _cartItems
                                        .map(
                                          (item) => TransactionItemRequest(
                                            productId: item.product.id!,
                                            quantity: item.quantity,
                                          ),
                                        )
                                        .toList(),
                                  );

                                  final transaction = await _transactionService
                                      .create(request);

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    final cartItemsCopy = List<_CartItem>.from(
                                      _cartItems,
                                    );
                                    setState(() => _cartItems.clear());
                                    _showTransactionSuccess(
                                      transaction,
                                      effectivePaid,
                                      cartItemsCopy,
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Gagal membuat transaksi: $e',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (context.mounted) {
                                    setSheetState(() => isProcessing = false);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primaryDark
                              .withOpacity(0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isProcessing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Proses Transaksi',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      if (_isCameraOn && mounted) {
        _scannerController.start();
      }
    });
  }

  void _showTransactionSuccess(
    Transaction transaction,
    double actualPaid,
    List<_CartItem> cartItems,
  ) {
    double kembalian = actualPaid - transaction.totalAmount;
    if (kembalian < 0) kembalian = 0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Transaksi Berhasil!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Kode: ${transaction.transactionCode ?? "-"}'),
            Text('Total: Rp${_formatRupiah(transaction.totalAmount)}'),
            Text('Bayar: Rp${_formatRupiah(actualPaid)}'),
            Text('Kembalian: Rp${_formatRupiah(kembalian)}'),
            Text('Metode: ${transaction.paymentMethod.name}'),
          ],
        ),
        actions: [
          if (_printerHelper.isConnected)
            TextButton(
              onPressed: () async {
                try {
                  final profile = await _authService.getProfile();
                  await _printerHelper.printStrukBelanja(
                    namaToko: profile.store.businessName,
                    alamatToko:
                        profile.store.address ?? 'Alamat tidak tersedia',
                    noTelpToko: profile.user.phone ?? '',
                    items: cartItems
                        .map(
                          (item) => {
                            'name': item.product.name,
                            'qty': item.quantity,
                            'price': item.product.sellingPrice,
                            'total': item.product.sellingPrice * item.quantity,
                          },
                        )
                        .toList(),
                    totalSemuanya: transaction.totalAmount,
                    uangBayar: actualPaid,
                    kembalian: kembalian,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mencetak struk...')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal mencetak struk: $e')),
                    );
                  }
                }
              },
              child: const Text('Cetak Struk'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
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

/// Cart item using real Product model
class _CartItem {
  final Product product;
  final int quantity;

  const _CartItem({required this.product, required this.quantity});

  _CartItem copyWith({int? quantity}) {
    return _CartItem(product: product, quantity: quantity ?? this.quantity);
  }
}
