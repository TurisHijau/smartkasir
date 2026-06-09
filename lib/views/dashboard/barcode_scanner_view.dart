import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:vibration/vibration.dart';

class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({super.key});

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    returnImage: false,
  );

  bool _isFlashOn = false;
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasScanned) return;

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue == null) continue;

      _hasScanned = true;

      if (await Vibration.hasVibrator() != false) {
        Vibration.vibrate(duration: 200);
      }

      if (mounted) {
        Navigator.pop(
          context,
          rawValue,
        ); // ← return barcode ke halaman sebelumnya
      }
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Kamera
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // Overlay gelap + scan area
          _buildScanOverlay(),

          // Header
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Scan Barcode',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() => _isFlashOn = !_isFlashOn);
                          _controller.toggleTorch();
                        },
                        icon: Icon(
                          _isFlashOn
                              ? Icons.flashlight_off_outlined
                              : Icons.flashlight_on_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Teks bawah
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Text(
                'Arahkan kamera ke barcode',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return CustomPaint(
      painter: _ScanOverlayPainter(),
      child: Center(
        child: SizedBox(
          width: 260,
          height: 180,
          child: Stack(
            children: [
              _scanCorner(Alignment.topLeft),
              _scanCorner(Alignment.topRight),
              _scanCorner(Alignment.bottomLeft),
              _scanCorner(Alignment.bottomRight),
            ],
          ),
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
}

// Overlay gelap di sekitar scan area
class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const scanWidth = 260.0;
    const scanHeight = 180.0;

    final left = (size.width - scanWidth) / 2;
    final top = (size.height - scanHeight) / 2;
    final scanRect = Rect.fromLTWH(left, top, scanWidth, scanHeight);

    final paint = Paint()..color = Colors.black.withOpacity(0.6);

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(
          RRect.fromRectAndRadius(scanRect, const Radius.circular(8)),
        ),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter oldDelegate) => false;
}
