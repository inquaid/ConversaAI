import 'package:flutter/material.dart';
import 'dart:math' as math;

class PulsatingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool isPulsing;

  const PulsatingIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 24.0,
    this.isPulsing = false,
  });

  @override
  State<PulsatingIcon> createState() => _PulsatingIconState();
}

class _PulsatingIconState extends State<PulsatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(PulsatingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing != oldWidget.isPulsing) {
      if (widget.isPulsing) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isPulsing ? _scaleAnimation.value : 1.0,
          child: Icon(widget.icon, color: widget.color, size: widget.size),
        );
      },
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final List<Color> gradientColors;

  const GradientText({
    super.key,
    required this.text,
    required this.style,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(text, style: style),
    );
  }
}

class AnimatedWaveBackground extends StatefulWidget {
  final Widget child;
  final bool isDarkMode;

  const AnimatedWaveBackground({
    super.key,
    required this.child,
    required this.isDarkMode,
  });

  @override
  State<AnimatedWaveBackground> createState() => _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends State<AnimatedWaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: WaveBackgroundPainter(
                animationValue: _controller.value,
                isDarkMode: widget.isDarkMode,
              ),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class WaveBackgroundPainter extends CustomPainter {
  final double animationValue;
  final bool isDarkMode;

  WaveBackgroundPainter({
    required this.animationValue,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create subtle wave patterns in the background
    for (int i = 0; i < 3; i++) {
      final path = Path();
      final waveHeight = 30.0 + i * 10;
      final frequency = 0.02 + i * 0.01;
      final phase = animationValue * 2 * math.pi + i * math.pi / 3;

      paint.color =
          (isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFF8F9FA))
              .withOpacity(0.3 - i * 0.1);

      path.moveTo(0, size.height * 0.8 + i * 20);

      for (double x = 0; x <= size.width; x += 5) {
        final y =
            size.height * 0.8 +
            i * 20 +
            math.sin(x * frequency + phase) * waveHeight;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WaveBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
