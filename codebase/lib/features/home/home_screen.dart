import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/providers/app_state_provider.dart';
import '../../shared/widgets/status_indicator.dart';
import '../conversation/conversation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, AppColors.surfaceVariant],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Modern App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.primaryPurple, AppColors.primaryBlue],
                    ).createShader(bounds),
                    child: Text(
                      'ConversaAI',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
              ),

              // Main Content
              SliverPadding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Welcome Card
                    _buildWelcomeCard(context),
                    const SizedBox(height: AppDimensions.paddingXL),

                    // Status Card
                    _buildStatusCard(context),
                    const SizedBox(height: AppDimensions.paddingXL),

                    // Main Action Card
                    _buildMainActionCard(context),
                    const SizedBox(height: AppDimensions.paddingL),

                    // Feature Cards
                    _buildFeatureCards(context),
                    const SizedBox(height: AppDimensions.paddingXL),

                    // Quick Tips Card
                    _buildTipsCard(context),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryPurple, AppColors.primaryBlue],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Modern Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            ),
            child: const Icon(
              Icons.waving_hand_rounded,
              size: AppDimensions.iconXL,
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),

          // Welcome Text
          Text(
            'Welcome to the Future of\nLanguage Learning',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingM),

          Text(
            'Experience natural AI conversations that adapt to your learning pace and style',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textOnPrimary.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: StatusIndicator(
            status: appState.statusMessage,
            isConnected: appState.isConnected,
          ),
        );
      },
    );
  }

  Widget _buildMainActionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Gradient Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.speakingGradientStart,
                  AppColors.speakingGradientEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
              boxShadow: [
                BoxShadow(
                  color: AppColors.speakingActive.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.mic_rounded,
              size: AppDimensions.iconXL,
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),

          Text(
            'Start Your AI Conversation',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingM),

          Text(
            'Begin practicing English with our advanced AI that understands context and provides real-time feedback',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingXL),

          // Modern Start Button
          Consumer<AppStateProvider>(
            builder: (context, appState, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.speakingGradientStart,
                      AppColors.speakingGradientEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.speakingActive.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const ConversationScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                return SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0, 1),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      ),
                                  child: child,
                                );
                              },
                          transitionDuration: AppDurations.animationSlow,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingL,
                        horizontal: AppDimensions.paddingXL,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.textOnPrimary,
                            size: AppDimensions.iconL,
                          ),
                          const SizedBox(width: AppDimensions.paddingM),
                          Text(
                            'Start Conversation',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.textOnPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildFeatureCard(
            context,
            'Practice',
            'Interactive speaking practice',
            Icons.record_voice_over_rounded,
            AppColors.listeningGradientStart,
            () {
              // TODO: Navigate to practice mode
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Practice mode coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: AppDimensions.paddingM),
        Expanded(
          child: _buildFeatureCard(
            context,
            'Progress',
            'Track your learning journey',
            Icons.trending_up_rounded,
            AppColors.accent,
            () {
              // TODO: Navigate to progress
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Progress tracking coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Icon(icon, color: color, size: AppDimensions.iconL),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXS),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.info.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.info,
                  size: AppDimensions.iconM,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Text(
                'Quick Tips',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          ...[
            '🎯 Speak naturally and confidently',
            '🔊 Ensure your microphone is working',
            '🎧 Use headphones for better audio quality',
            '💡 Practice regularly for best results',
          ].map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
              child: Text(
                tip,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
