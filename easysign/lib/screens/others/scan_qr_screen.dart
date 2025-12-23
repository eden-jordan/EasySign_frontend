import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner le QR')),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          facing: CameraFacing.back,
        ),
        onDetect: (BarcodeCapture capture) {
          if (_isScanned) return;

          final List<Barcode> barcodes = capture.barcodes;

          if (barcodes.isNotEmpty) {
            final String? qrCode = barcodes.first.rawValue;

            if (qrCode != null && qrCode.isNotEmpty) {
              _isScanned = true;

              debugPrint('QR SCANNÉ = $qrCode');

              Navigator.pop(context, qrCode);
            }
          }
        },
      ),
    );
  }
}
