// Schermata camera con overlay rettangolare guida biglietto
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'scan_provider.dart';
import 'scan_review_screen.dart';

class ScanCardScreen extends ConsumerStatefulWidget {
  const ScanCardScreen({super.key});

  @override
  ConsumerState<ScanCardScreen> createState() => _ScanCardScreenState();
}

class _ScanCardScreenState extends ConsumerState<ScanCardScreen> {
  CameraController? _controller;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview full screen
          if (_controller?.value.isInitialized ?? false)
            Positioned.fill(child: CameraPreview(_controller!)),

          // Overlay scuro con rettangolo ritagliato
          Positioned.fill(child: _CardOverlay()),

          // UI sopra
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Inquadra il biglietto',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      // Scegli da galleria
                      IconButton(
                        icon: const Icon(Icons.photo_library, color: Colors.white),
                        onPressed: _pickFromGallery,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Hint text
                const Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Text(
                    'Tieni il biglietto orizzontale e ben illuminato',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),

                // Bottone scatto
                Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: GestureDetector(
                    onTap: _isCapturing ? null : _capture,
                    child: Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: _isCapturing
                            ? Colors.white38
                            : Colors.white,
                      ),
                      child: _isCapturing
                          ? const CircularProgressIndicator(color: Colors.black)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    setState(() => _isCapturing = true);

    try {
      final image = await _controller!.takePicture();
      await _processAndNavigate(image);
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) await _processAndNavigate(image);
  }

  Future<void> _processAndNavigate(XFile image) async {
    // Crop opzionale
    final cropped = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Ritaglia biglietto',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio16x9,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Ritaglia biglietto',
        ),
      ],
    );

    final finalImage = cropped != null
        ? XFile(cropped.path)
        : image;

    await ref.read(scanNotifierProvider.notifier).processImage(finalImage);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ScanReviewScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

// Overlay con rettangolo trasparente al centro
class _CardOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _OverlayPainter());
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;

    // Rettangolo biglietto da visita (proporzione 16:9 circa)
    final rectWidth = size.width * 0.85;
    final rectHeight = rectWidth * 0.56; // proporzione biglietto
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: rectWidth,
      height: rectHeight,
    );

    // Disegna overlay scuro escludendo il rettangolo
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Bordo bianco attorno al rettangolo
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      borderPaint,
    );

    // Angoli evidenziati
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLength = 20.0;
    // Top-left
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, cornerLength), cornerPaint);
    // Top-right
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(-cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(0, cornerLength), cornerPaint);
    // Bottom-left
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(0, -cornerLength), cornerPaint);
    // Bottom-right
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(-cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(0, -cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}