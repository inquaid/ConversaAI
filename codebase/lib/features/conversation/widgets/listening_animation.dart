import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/constants/app_constants.dart';

class ListeningAnimation extends StatefulWidget {
  const ListeningAnimation({super.key});

  @override
  State<ListeningAnimation> createState() => _ListeningAnimationState();
}

class _ListeningAnimationState extends State<ListeningAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
    );

    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    _particleController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Main headphones with modern design and floating particles
        Stack(
          alignment: Alignment.center,
          children: [
            // Floating particles around the headphones
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(8, (index) {
                    double angle = (index * 45) * (math.pi / 180);
                    double radius = 80 + (20 * _particleAnimation.value);
                    double x =
                        radius *
                        math.cos(
                          angle + _particleAnimation.value * 2 * math.pi,
                        );
                    double y =
                        radius *
                        math.sin(
                          angle + _particleAnimation.value * 2 * math.pi,
                        );
                    double opacity = (0.8 - _particleAnimation.value).abs();

                    return Transform.translate(
                      offset: Offset(x, y),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.listeningActive.withOpacity(opacity),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),

            // Rotating outer ring
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * math.pi,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.listeningActive.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 5,
                          left: 75,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.listeningActive,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: 75,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.listeningActive.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Main headphones with gradient and pulse
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.listeningGradientStart,
                          AppColors.listeningGradientEnd,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.listeningActive.withOpacity(0.4),
                          blurRadius: 25,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: AppColors.listeningActive.withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.headset_rounded,
                      size: AppDimensions.iconXXL,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.paddingXXL),

        // Modern audio processing visualization
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: AppColors.listeningActive.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.graphic_eq_rounded,
                    color: AppColors.listeningActive,
                    size: AppDimensions.iconL,
                  ),
                  const SizedBox(width: AppDimensions.paddingS),
                  AnimatedBuilder(
                    animation: _particleController,
                    builder: (context, child) {
                      return Row(
                        children: List.generate(3, (index) {
                          double opacity =
                              (0.3 +
                              0.7 * ((index + _particleAnimation.value) % 1.0));
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.listeningActive.withOpacity(
                                opacity,
                              ),
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                'Processing audio...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.listeningActive,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.paddingXL),

        // Modern status text with gradient
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              AppColors.listeningGradientStart,
              AppColors.listeningGradientEnd,
            ],
          ).createShader(bounds),
          child: Text(
            'AI is processing...',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.paddingM),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingS,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
          ),
          child: Text(
            '🤖 Analyzing your pronunciation',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
