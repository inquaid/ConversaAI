import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../providers/voice_provider.dart';

class EnhancedVoiceVisualizer extends StatefulWidget {
  final VoiceState voiceState;
  final double volumeLevel;
  final Color? primaryColor;

  const EnhancedVoiceVisualizer({
    super.key,
    required this.voiceState,
    required this.volumeLevel,
    this.primaryColor,
  });

  @override
  State<EnhancedVoiceVisualizer> createState() =>
      _EnhancedVoiceVisualizerState();
}

class _EnhancedVoiceVisualizerState extends State<EnhancedVoiceVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _primaryController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    // Unified animation timings for consistent feel across all states
    _primaryController = AnimationController(
      duration: const Duration(
        milliseconds: 2000,
      ), // Consistent with speaking waves
      vsync: this,
    );

    // Breathing pulse - matches processing orb rhythm
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200), // Matches processing pulse
      vsync: this,
    );

    // Processing rotation
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _updateAnimations();
  }

  @override
  void didUpdateWidget(EnhancedVoiceVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.voiceState != oldWidget.voiceState) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    switch (widget.voiceState) {
      case VoiceState.listening:
        // Only use primary and pulse controllers for listening
        _primaryController.repeat();
        _pulseController.repeat(reverse: true);
        _rotationController.stop();
        break;
      case VoiceState.speaking:
        _primaryController.repeat();
        _pulseController.stop();
        _rotationController.stop();
        break;
      case VoiceState.processing:
        _primaryController.repeat();
        _pulseController.repeat(reverse: true);
        _rotationController.repeat();
        break;
      case VoiceState.idle:
      case VoiceState.error:
        _primaryController.stop();
        _pulseController.stop();
        _rotationController.stop();
        break;
    }
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.voiceState == VoiceState.idle) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 180,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _primaryController,
          _pulseController,
          _rotationController,
        ]),
        builder: (context, child) {
          return CustomPaint(
            painter: EnhancedWaveformPainter(
              voiceState: widget.voiceState,
              volumeLevel: widget.volumeLevel,
              primaryAnimation: _primaryController.value,
              pulseAnimation: _pulseController.value,
              rotationAnimation: _rotationController.value,
              primaryColor: widget.primaryColor ?? _getDefaultColor(context),
              isDarkMode: Theme.of(context).brightness == Brightness.dark,
            ),
            child: Container(),
          );
        },
      ),
    );
  }

  Color _getDefaultColor(BuildContext context) {
    switch (widget.voiceState) {
      case VoiceState.listening:
        return Theme.of(context).colorScheme.primary;
      case VoiceState.speaking:
        return Theme.of(context).colorScheme.secondary;
      case VoiceState.processing:
        return Theme.of(context).colorScheme.tertiary;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}

class EnhancedWaveformPainter extends CustomPainter {
  final VoiceState voiceState;
  final double volumeLevel;
  final double primaryAnimation;
  final double pulseAnimation;
  final double rotationAnimation;
  final Color primaryColor;
  final bool isDarkMode;

  EnhancedWaveformPainter({
    required this.voiceState,
    required this.volumeLevel,
    required this.primaryAnimation,
    required this.pulseAnimation,
    required this.rotationAnimation,
    required this.primaryColor,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    switch (voiceState) {
      case VoiceState.listening:
        _drawEnhancedListening(canvas, size, center);
        break;
      case VoiceState.speaking:
        _drawRichSpeaking(canvas, size, center);
        break;
      case VoiceState.processing:
        _drawRichProcessing(canvas, center);
        break;
      default:
        break;
    }
  }

  void _drawEnhancedListening(Canvas canvas, Size size, Offset center) {
    // Ultra-optimized listening animation - no lag guaranteed
    _drawOptimizedListeningRipples(canvas, center);
    _drawOptimizedListeningCore(canvas, center);
  }

  void _drawOptimizedListeningRipples(Canvas canvas, Offset center) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Only 2 simple ripples for maximum performance
    for (int i = 0; i < 2; i++) {
      final baseRadius = 40.0 + (i * 25);
      final phase = (primaryAnimation + i * 0.5) % 1.0;
      final radius = baseRadius * (1.0 + volumeLevel * 0.3);

      final opacity = (1.0 - phase) * (0.5 - i * 0.1);
      paint
        ..color = primaryColor.withValues(alpha: opacity)
        ..strokeWidth = 2.5 - (i * 0.5);

      canvas.drawCircle(center, radius + (phase * 20), paint);
    }
  }

  void _drawOptimizedListeningCore(Canvas canvas, Offset center) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Simple pulsing core - minimal calculations
    final baseRadius = 12.0 + (volumeLevel * 8.0);
    final pulseRadius = baseRadius * (1.0 + pulseAnimation * 0.2);

    // Outer core
    paint.color = primaryColor.withValues(alpha: 0.6);
    canvas.drawCircle(center, pulseRadius, paint);

    // Inner core
    paint.color = primaryColor.withValues(alpha: 0.9);
    canvas.drawCircle(center, pulseRadius * 0.6, paint);

    // Center point
    paint.color = Colors.white.withValues(alpha: 0.8);
    canvas.drawCircle(center, pulseRadius * 0.3, paint);
  }

  void _drawRichSpeaking(Canvas canvas, Size size, Offset center) {
    // Rich speaking visualization with flowing waves
    _drawFlowingWaves(canvas, size, center);
    _drawSpeakingParticles(canvas, size, center);
    _drawCentralGlow(canvas, center);
  }

  void _drawFlowingWaves(Canvas canvas, Size size, Offset center) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Multiple flowing sine waves
    for (int layer = 0; layer < 2; layer++) {
      final path = Path();
      final waveWidth = size.width * 0.8;
      final waveHeight = 20.0 + layer * 8; // slightly lower amplitude
      final frequency = 2.0 + layer * 0.5;
      final phase = primaryAnimation * 2 * math.pi + layer * math.pi / 3;

      paint
        ..strokeWidth = 3.5 - layer
        ..color = primaryColor.withValues(alpha: (0.8 - layer * 0.2));

      path.moveTo(center.dx - waveWidth / 2, center.dy);

      // Coarser sampling to reduce CPU work
      for (double x = -waveWidth / 2; x <= waveWidth / 2; x += 4) {
        final y =
            center.dy +
            math.sin((x / waveWidth * frequency * 2 * math.pi) + phase) *
                waveHeight *
                (0.5 + volumeLevel * 0.5);
        path.lineTo(center.dx + x, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  void _drawSpeakingParticles(Canvas canvas, Size size, Offset center) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false; // tiny circles don't need AA

    // Dynamic particles flowing outward
    for (int i = 0; i < 12; i++) {
      final angle = (i / 20) * 2 * math.pi;
      final distance =
          100.0 + (math.sin(primaryAnimation * 2 * math.pi + i) * 30);

      final x =
          center.dx +
          math.cos(angle + primaryAnimation * math.pi * 0.1) * distance;
      final y =
          center.dy +
          math.sin(angle + primaryAnimation * math.pi * 0.1) * distance;

      final particleSize =
          2.5 + (math.sin(primaryAnimation * 4 * math.pi + i) + 1) * 1.8;
      final opacity = 0.28 + (volumeLevel * 0.35);

      paint.color = primaryColor.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  void _drawCentralGlow(Canvas canvas, Offset center) {
    final paint = Paint()..style = PaintingStyle.fill;

    final radius = 20 + (pulseAnimation * 15);
    final glowOpacity = 0.6 - pulseAnimation * 0.4;

    paint.color = primaryColor.withValues(alpha: glowOpacity);
    canvas.drawCircle(center, radius, paint);
  }

  void _drawRichProcessing(Canvas canvas, Offset center) {
    // Rich processing visualization with rotating spiral and orbs
    _drawRotatingSpiral(canvas, center);
    _drawProcessingOrbs(canvas, center);
  }

  void _drawRotatingSpiral(Canvas canvas, Offset center) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const spiralTurns = 3.0;
    const maxRadius = 80.0;

    for (double t = 0; t <= spiralTurns * 2 * math.pi; t += 0.1) {
      final radius = (t / (spiralTurns * 2 * math.pi)) * maxRadius;
      final adjustedT = t + rotationAnimation * 2 * math.pi;

      final x = center.dx + radius * math.cos(adjustedT);
      final y = center.dy + radius * math.sin(adjustedT);

      if (t == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    paint.color = primaryColor.withOpacity(0.8);
    canvas.drawPath(path, paint);
  }

  void _drawProcessingOrbs(Canvas canvas, Offset center) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Multiple pulsating layers
    for (int i = 0; i < 3; i++) {
      final radius = (30.0 + i * 15) * (1 + pulseAnimation * 0.3);
      final opacity = (0.6 - i * 0.15) * (1 - pulseAnimation * 0.3);

      paint.color = primaryColor.withValues(alpha: opacity);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(EnhancedWaveformPainter oldDelegate) {
    return oldDelegate.voiceState != voiceState ||
        oldDelegate.volumeLevel != volumeLevel ||
        oldDelegate.primaryAnimation != primaryAnimation ||
        oldDelegate.pulseAnimation != pulseAnimation ||
        oldDelegate.rotationAnimation != rotationAnimation ||
        oldDelegate.primaryColor != primaryColor;
  }
}
