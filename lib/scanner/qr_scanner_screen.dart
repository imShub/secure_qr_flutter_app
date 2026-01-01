import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:secure_qr_flutter/crypto/rsa_verifier.dart';
import 'package:secure_qr_flutter/decoder/base64_decoder.dart';
import 'package:secure_qr_flutter/decoder/block_splitter.dart';
import 'package:secure_qr_flutter/decoder/uidai_field_mapper.dart';
import 'package:secure_qr_flutter/ui/result_screen.dart';
import 'package:secure_qr_flutter/ui/theme.dart';

class QrScannerScreen extends StatefulWidget {
  @override
  _QrScannerScreenState createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _processQr(barcode.rawValue!);
        break;
      }
    }
  }

  Future<void> _processQr(String base64String) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final rawBytes = Base64DecoderHelper.decode(base64String);
      final blocks = BlockSplitter.split(rawBytes);
      final person = UidaiFieldMapper.map(blocks);

      if (person.signatureBytes == null || person.signatureBytes!.isEmpty) {
        throw Exception("No signature found");
      }

      final signature = person.signatureBytes!;
      int sigLen = signature.length;
      int payloadLen = rawBytes.length - sigLen - 1; // -1 for separator

      if (payloadLen <= 0) throw Exception("Invalid payload length");

      final payload = rawBytes.sublist(0, payloadLen);
      final isValid = RsaVerifier.verify(payload, signature);

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              person: person,
              isVerified: isValid,
            ),
          ),
        );
        // Resume scanning when coming back
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid Secure QR'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: GlassContainer(
          child: Text("Scan Secure QR", style: TextStyle(fontSize: 16)),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          borderRadius: BorderRadius.circular(30),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onDetect,
          ),

          // Custom Overlay
          CustomPaint(
            painter: ScannerOverlayPainter(
              borderColor: AppTheme.primary,
              borderRadius: 20,
              borderLength: 40,
              borderWidth: 8,
              cutOutSize: 300,
              overlayColor: Colors.black.withOpacity(0.7),
            ),
            child: Container(),
          ),

          // Scanning Line Animation
          if (!_isProcessing)
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Positioned(
                  top: MediaQuery.of(context).size.height / 2 -
                      150 +
                      (300 * _animController.value),
                  left: MediaQuery.of(context).size.width / 2 - 140,
                  child: Container(
                    width: 280,
                    height: 2,
                    decoration:
                        BoxDecoration(color: AppTheme.primary, boxShadow: [
                      BoxShadow(
                          color: AppTheme.primary.withOpacity(0.6),
                          blurRadius: 10,
                          spreadRadius: 2)
                    ]),
                  ),
                );
              },
            ),

          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            ),

          // Helper Text
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Align Frame with QR Code",
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final double cutOutSize;
  final Color overlayColor;

  ScannerOverlayPainter({
    required this.borderColor,
    required this.borderRadius,
    required this.borderLength,
    required this.borderWidth,
    required this.cutOutSize,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = cutOutSize;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final double right = left + scanAreaSize;
    final double bottom = top + scanAreaSize;

    // Background
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTRB(left, top, right, bottom),
          Radius.circular(borderRadius)));

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path.combine(PathOperation.difference, backgroundPath, cutoutPath),
      backgroundPaint,
    );

    // Borders
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Top Left
    path.moveTo(left, top + borderLength);
    path.lineTo(left, top + borderRadius);
    path.quadraticBezierTo(left, top, left + borderRadius, top);
    path.lineTo(left + borderLength, top);

    // Top Right
    path.moveTo(right - borderLength, top);
    path.lineTo(right - borderRadius, top);
    path.quadraticBezierTo(right, top, right, top + borderRadius);
    path.lineTo(right, top + borderLength);

    // Bottom Right
    path.moveTo(right, bottom - borderLength);
    path.lineTo(right, bottom - borderRadius);
    path.quadraticBezierTo(right, bottom, right - borderRadius, bottom);
    path.lineTo(right - borderLength, bottom);

    // Bottom Left
    path.moveTo(left + borderLength, bottom);
    path.lineTo(left + borderRadius, bottom);
    path.quadraticBezierTo(left, bottom, left, bottom - borderRadius);
    path.lineTo(left, bottom - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
