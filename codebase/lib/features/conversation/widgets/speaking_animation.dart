import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class SpeakingAnimation extends StatefulWidget {
  const SpeakingAnimation({super.key});

  @override
  State<SpeakingAnimation> createState() => _SpeakingAnimationState();
}

class _SpeakingAnimationState extends State<SpeakingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _outerRingController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _outerRingAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _outerRingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    _outerRingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _outerRingController, curve: Curves.easeOut),
    );

    _pulseController.repeat(reverse: true);
    _waveController.repeat();
    _outerRingController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _outerRingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Main microphone with modern pulse effect and outer rings
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer animated rings
            AnimatedBuilder(
              animation: _outerRingController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(3, (index) {
                    double delay = index * 0.3;
                    double animValue =
                        (_outerRingAnimation.value + delay) % 1.0;
                    double scale = 1.0 + (animValue * 1.5);
                    double opacity = 1.0 - animValue;

                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.speakingActive.withOpacity(
                              opacity * 0.3,
                            ),
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),

            // Main microphone container with gradient
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.speakingGradientStart,
                          AppColors.speakingGradientEnd,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.speakingActive.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: AppColors.speakingActive.withOpacity(0.2),
                          blurRadius: 50,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mic_rounded,
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

        // Modern sound wave visualization
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingXL,
            vertical: AppDimensions.paddingL,
          ),
          decoration: BoxDecoration(
            color: AppColors.speakingActive.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
          ),
          child: AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(7, (index) {
                  double delay = index * 0.15;
                  double animValue = (_waveAnimation.value + delay) % 1.0;
                  double height =
                      15 +
                      (40 * (0.5 + 0.5 * -((animValue - 0.5) * 2).abs() + 0.5));

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 6,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.speakingGradientStart,
                          AppColors.speakingGradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              );
            },
          ),
        ),

        const SizedBox(height: AppDimensions.paddingXL),

        // Modern status text with gradient
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              AppColors.speakingGradientStart,
              AppColors.speakingGradientEnd,
            ],
          ).createShader(bounds),
          child: Text(
            'Listening to your voice...',
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
            '🎤 Speak clearly and naturally',
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
