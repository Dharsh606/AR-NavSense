import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';
import '../widgets/glassmorphic_container.dart';

class CameraAwarenessScreen extends StatefulWidget {
  const CameraAwarenessScreen({Key? key}) : super(key: key);

  @override
  State<CameraAwarenessScreen> createState() => _CameraAwarenessScreenState();
}

class _CameraAwarenessScreenState extends State<CameraAwarenessScreen> {
  CameraController? _controller;
  String _status = 'Initializing camera awareness...';
  bool _torch = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _status = 'No camera found on this device.');
        return;
      }
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      setState(() {
        _controller = controller;
        _status = 'Camera active. AI object detection pipeline ready.';
      });
    } catch (error) {
      setState(() => _status = error.toString());
    }
  }

  Future<void> _toggleTorch() async {
    final controller = _controller;
    if (controller == null) return;
    _torch = !_torch;
    await controller.setFlashMode(_torch ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Camera Awareness'), centerTitle: true),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (controller?.value.isInitialized == true)
            CameraPreview(controller!)
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEAFBF2), Color(0xFFE8F7FF), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          IgnorePointer(
            child: CustomPaint(painter: _ScannerPainter()),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                GlassmorphicContainer(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(18),
                  borderRadius: 28,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.center_focus_strong, color: AppTheme.primaryGreen),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Environment Awareness',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textPrimary,
                                  ),
                            ),
                          ),
                          IconButton(
                            onPressed: _toggleTorch,
                            icon: Icon(_torch ? Icons.flash_on : Icons.flash_off),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _status,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: const [
                          _CapabilityPill(icon: Icons.visibility, label: 'Obstacle ready'),
                          SizedBox(width: 8),
                          _CapabilityPill(icon: Icons.memory, label: 'AI pipeline'),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: .2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CapabilityPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CapabilityPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.primaryGreen.withOpacity(.35)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentBlue.withOpacity(.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (var i = 1; i < 5; i++) {
      final y = size.height * (i / 6);
      canvas.drawLine(Offset(24, y), Offset(size.width - 24, y), paint);
    }
    final frame = Rect.fromLTWH(36, size.height * .22, size.width - 72, size.height * .42);
    canvas.drawRRect(RRect.fromRectAndRadius(frame, const Radius.circular(28)), paint..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
