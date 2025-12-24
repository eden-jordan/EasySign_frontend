import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:async';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen>
    with SingleTickerProviderStateMixin {
  bool _isScanned = false;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  MobileScannerController? _controller;
  late AnimationController _animationController;
  late Animation<double> _scanLineAnimation;
  String? _lastScannedCode;
  Timer? _resetTimer;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      detectionTimeoutMs: 2000,
    );

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller?.dispose();
    _resetTimer?.cancel();
    super.dispose();
  }

  void _resetScanState() {
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isScanned = false;
          _lastScannedCode = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scanAreaSize = size.width * 0.7;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scanner QR Code',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              size: 24,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
            onPressed: () {
              setState(() {
                _isFlashOn = !_isFlashOn;
                _controller?.toggleTorch();
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.cameraswitch,
              size: 24,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
            onPressed: () {
              setState(() {
                _isFrontCamera = !_isFrontCamera;
                _controller?.switchCamera();
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner en arrière-plan
          MobileScanner(
            controller: _controller,
            onDetect: (BarcodeCapture capture) {
              if (_isScanned) return;

              final List<Barcode> barcodes = capture.barcodes;

              if (barcodes.isNotEmpty) {
                final String? qrCode = barcodes.first.rawValue;

                if (qrCode != null && qrCode.isNotEmpty) {
                  setState(() {
                    _isScanned = true;
                    _lastScannedCode = qrCode;
                  });

                  debugPrint('QR SCANNÉ = $qrCode');

                  Future.delayed(const Duration(milliseconds: 1500), () {
                    if (mounted) {
                      Navigator.pop(context, qrCode);
                    }
                  });

                  _resetScanState();
                }
              }
            },
          ),

          // Overlay avec cadre de scan BIEN VISIBLE
          Container(
            color: Colors.black.withOpacity(0.5),
            child: CustomPaint(painter: ScanOverlayPainter(scanAreaSize)),
          ),

          // Cadre de scan avec coins décoratifs
          Center(
            child: Container(
              width: scanAreaSize,
              height: scanAreaSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CustomPaint(painter: CornerPainter()),
            ),
          ),

          // Ligne de scan animée
          Positioned(
            top: (size.height - scanAreaSize) / 2,
            left: (size.width - scanAreaSize) / 2,
            right: (size.width - scanAreaSize) / 2,
            child: AnimatedBuilder(
              animation: _scanLineAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, scanAreaSize * _scanLineAnimation.value),
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          theme.colorScheme.primary,
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.8),
                          blurRadius: 12,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Instructions en bas
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Positionnez le QR Code dans le cadre',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Le scan se fera automatiquement',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                ),
              ],
            ),
          ),

          // Feedback de scan réussi
          if (_isScanned && _lastScannedCode != null)
            Container(
              color: Colors.black.withOpacity(0.85),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Scan Réussi !',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      decoration: BoxDecoration(
                        color: Colors.grey[900]!.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Traitement en cours...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _isScanned
          ? null
          : FloatingActionButton(
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                _isFlashOn ? Icons.flash_off : Icons.flash_on,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isFlashOn = !_isFlashOn;
                  _controller?.toggleTorch();
                });
              },
            ),
    );
  }
}

class ScanOverlayPainter extends CustomPainter {
  final double scanSize;

  ScanOverlayPainter(this.scanSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);

    // Zone de scan (transparente au centre)
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanSize,
      height: scanSize,
    );

    // Tout l'écran
    final screenRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Créer un chemin qui est tout l'écran MOINS le rectangle de scan
    final path = Path()..addRect(screenRect);

    final scanPath = Path()
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(12)));

    final combinedPath = Path.combine(PathOperation.difference, path, scanPath);

    canvas.drawPath(combinedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final cornerLength = 24.0;

    // Coin supérieur gauche
    canvas.drawLine(Offset(0, cornerLength), Offset(0, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(cornerLength, 0), paint);

    // Coin supérieur droit
    canvas.drawLine(
      Offset(size.width - cornerLength, 0),
      Offset(size.width, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );

    // Coin inférieur gauche
    canvas.drawLine(
      Offset(0, size.height - cornerLength),
      Offset(0, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );

    // Coin inférieur droit
    canvas.drawLine(
      Offset(size.width - cornerLength, size.height),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLength),
      paint,
    );

    // Ajouter un effet de glow léger
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
