import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../domain/qr_parser.dart';

/// Camera QR Code Scanner with permission handling & UPI QR parsing (Feature F3)
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        _isProcessing = true;
        try {
          final payload = QrParser.parse(rawValue);
          // Navigate to Pay Screen with pre-filled details
          final Uri targetUri = Uri(
            path: '/pay',
            queryParameters: {
              'vpa': payload.vpa,
              if (payload.fixedAmountRupees != null)
                'am': payload.fixedAmountRupees.toString(),
            },
          );
          context.pushReplacement(targetUri.toString());
          break;
        } catch (e) {
          _isProcessing = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e is FormatException ? e.message : 'Invalid QR Code'),
              backgroundColor: Colors.red,
            ),
          );
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan & Pay'),
        actions: [
          IconButton(
            tooltip: 'Toggle Flash',
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: () => _cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Camera Permission Required',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'PayLite needs camera access to scan QR codes for payments.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Allow entering manual VPA fallback
                          context.pushReplacement('/pay');
                        },
                        child: const Text('Enter UPI ID Manually'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // QR Scanner Reticle Overlay
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00796B), width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // Bottom prompt
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Point camera at any UPI QR code',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
