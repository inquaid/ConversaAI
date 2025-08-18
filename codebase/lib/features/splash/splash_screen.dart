import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _logoController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _navigateToHome();
  }

  void _initializeAnimations() {
    // Main animation controller
    _animationController = AnimationController(
      duration: AppDurations.animationExtraSlow,
      vsync: this,
    );

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _logoRotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _logoController.repeat(reverse: true);
  }

  void _navigateToHome() {
    Future.delayed(AppDurations.splash, () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: child,
                  );
                },
            transitionDuration: AppDurations.animationSlow,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.gradientStart,
              AppColors.gradientMiddle,
              AppColors.gradientEnd,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 2),

                        // Modern Logo Container with animations
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _logoScaleAnimation.value,
                              child: Transform.rotate(
                                angle: _logoRotationAnimation.value,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusXXL,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                        spreadRadius: 5,
                                      ),
                                      BoxShadow(
                                        color: AppColors.textOnPrimary
                                            .withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, -5),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Background gradient circle
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppColors.primaryPurple
                                                  .withOpacity(0.2),
                                              AppColors.primaryBlue.withOpacity(
                                                0.2,
                                              ),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      // Main icon
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            const LinearGradient(
                                              colors: [
                                                AppColors.primaryPurple,
                                                AppColors.primaryBlue,
                                              ],
                                            ).createShader(bounds),
                                        child: const Icon(
                                          Icons.chat_bubble_outline_rounded,
                                          size: AppDimensions.iconXXXL,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: AppDimensions.paddingXXL),

                        // Modern App Name with gradient text
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              AppColors.textOnPrimary,
                              Color(0xFFE2E8F0),
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'ConversaAI',
                            style: AppTheme.lightTheme.textTheme.displayLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.5,
                                ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.paddingM),

                        // Modern tagline with typewriter animation
                        SizedBox(
                          height: 80,
                          child: AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                'Master English through\nnatural conversations',
                                textStyle: AppTheme
                                    .lightTheme
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: AppColors.textOnPrimary
                                          .withOpacity(0.9),
                                      fontSize: 18,
                                      height: 1.5,
                                    ),
                                textAlign: TextAlign.center,
                                speed: const Duration(milliseconds: 80),
                              ),
                            ],
                            totalRepeatCount: 1,
                          ),
                        ),

                        const Spacer(flex: 1),

                        // Modern loading indicator
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          decoration: BoxDecoration(
                            color: AppColors.textOnPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusCircle,
                            ),
                          ),
                          child: const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.textOnPrimary,
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.paddingXXL),

                        // Modern subtitle
                        Text(
                          'AI-Powered Language Learning',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.textOnPrimary.withOpacity(0.7),
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.w500,
                              ),
                        ),

                        const Spacer(flex: 1),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
