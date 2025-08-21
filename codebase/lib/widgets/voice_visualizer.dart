import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../providers/voice_provider.dart';

class VoiceVisualizer extends StatefulWidget {
  final VoiceState voiceState;
  final double volumeLevel;
  final AnimationController waveController;

  const VoiceVisualizer({
    super.key,
    required this.voiceState,
    required this.volumeLevel,
    required this.waveController,
  });

  @override
  State<VoiceVisualizer> createState() => _VoiceVisualizerState();
}

class _VoiceVisualizerState extends State<VoiceVisualizer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: widget.waveController,
        builder: (context, child) {
          return CustomPaint(
            painter: WaveformPainter(
              voiceState: widget.voiceState,
              volumeLevel: widget.volumeLevel,
              animationValue: widget.waveController.value,
              isDarkMode: Theme.of(context).brightness == Brightness.dark,
              primaryColor: _getVisualizerColor(context),
            ),
            child: Container(),
          );
        },
      ),
    );
  }

  Color _getVisualizerColor(BuildContext context) {
    switch (widget.voiceState) {
      case VoiceState.listening:
        return const Color(0xFF007AFF); // iOS blue
      case VoiceState.speaking:
        return const Color(0xFF34C759); // iOS green
      case VoiceState.processing:
        return const Color(0xFFFF9500); // iOS orange
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}

class WaveformPainter extends CustomPainter {
  final VoiceState voiceState;
  final double volumeLevel;
  final double animationValue;
  final bool isDarkMode;
  final Color primaryColor;

  WaveformPainter({
    required this.voiceState,
    required this.volumeLevel,
    required this.animationValue,
    required this.isDarkMode,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    switch (voiceState) {
      case VoiceState.listening:
        _drawListeningWaves(canvas, size, center);
        break;
      case VoiceState.speaking:
        _drawSpeakingWaves(canvas, size, center);
        break;
      case VoiceState.processing:
        _drawProcessingOrb(canvas, size, center);
        break;
      default:
        break;
    }
  }

  void _drawListeningWaves(Canvas canvas, Size size, Offset center) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw multiple concentric circles that pulse based on volume
    for (int i = 0; i < 4; i++) {
      final radius = (30.0 + i * 20) * (1 + volumeLevel * 0.5);
      final opacity = math.max(0.1, 0.8 - i * 0.2 - (animationValue * 0.3));

      paint.color = primaryColor.withOpacity(opacity);

      // Create ripple effect
      final rippleRadius = radius + (animationValue * 20);
      canvas.drawCircle(center, rippleRadius, paint);
    }

    // Draw volume bars
    _drawVolumeBars(canvas, size, center);
  }

  void _drawSpeakingWaves(Canvas canvas, Size size, Offset center) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw sine wave pattern
    final path = Path();
    final waveWidth = size.width * 0.8;
    final waveHeight = 40.0;
    final frequency = 3.0;

    path.moveTo(center.dx - waveWidth / 2, center.dy);

    for (double x = -waveWidth / 2; x <= waveWidth / 2; x += 2) {
      final y =
          center.dy +
          math.sin(
                (x / waveWidth * frequency * 2 * math.pi) +
                    (animationValue * 2 * math.pi),
              ) *
              waveHeight *
              (0.5 + volumeLevel * 0.5);

      path.lineTo(center.dx + x, y);
    }

    // Create gradient effect
    for (int i = 0; i < 3; i++) {
      paint.color = primaryColor.withOpacity(0.8 - i * 0.2);
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 - i
        ..color = paint.color;

      canvas.drawPath(path, strokePaint);
    }
  }

  void _drawProcessingOrb(Canvas canvas, Size size, Offset center) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw pulsating orb with gradient
    final radius = 40 + (math.sin(animationValue * 2 * math.pi) * 10);

    // Outer glow
    paint.color = primaryColor.withOpacity(0.3);
    canvas.drawCircle(center, radius + 20, paint);

    // Main orb
    paint.color = primaryColor.withOpacity(0.8);
    canvas.drawCircle(center, radius, paint);

    // Inner highlight
    paint.color = primaryColor.withOpacity(0.4);
    canvas.drawCircle(center, radius * 0.6, paint);
  }

  void _drawVolumeBars(Canvas canvas, Size size, Offset center) {
    final paint = Paint()..style = PaintingStyle.fill;

    const barCount = 5;
    const barWidth = 4.0;
    const barSpacing = 8.0;
    const maxBarHeight = 30.0;

    for (int i = 0; i < barCount; i++) {
      final x =
          center.dx -
          (barCount * (barWidth + barSpacing)) / 2 +
          i * (barWidth + barSpacing);

      // Generate pseudo-random heights based on volume and animation
      final heightMultiplier =
          (math.sin(animationValue * 2 * math.pi + i) + 1) / 2;
      final barHeight = maxBarHeight * volumeLevel * heightMultiplier;

      final opacity = 0.4 + (volumeLevel * 0.6);
      paint.color = primaryColor.withOpacity(opacity);

      final rect = Rect.fromLTWH(
        x,
        center.dy - barHeight / 2,
        barWidth,
        barHeight,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.voiceState != voiceState ||
        oldDelegate.volumeLevel != volumeLevel ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.primaryColor != primaryColor;
  }
}
