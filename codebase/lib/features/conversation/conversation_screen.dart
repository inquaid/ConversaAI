import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/providers/app_state_provider.dart';
import 'widgets/speaking_animation.dart';
import 'widgets/listening_animation.dart';
import 'widgets/conversation_controls.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-start natural conversation flow when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppStateProvider>().setConnectionStatus(true);
      // Start natural conversation after a brief delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          context.read<AppStateProvider>().startNaturalConversation();
        }
      });
    });
  }

  @override
  void dispose() {
    // Stop natural conversation when leaving screen
    context.read<AppStateProvider>().stopNaturalConversation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<AppStateProvider>().stopNaturalConversation();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Consumer<AppStateProvider>(
            builder: (context, appState, child) {
              if (appState.isAutoFlowActive) {
                return IconButton(
                  icon: const Icon(Icons.stop_circle_outlined),
                  onPressed: () => appState.interruptConversation(),
                  tooltip: 'Stop Conversation',
                );
              }
              return IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfoDialog(context),
                tooltip: 'Help',
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  children: [
                    // Status Section
                    _buildStatusSection(),
                    const SizedBox(height: AppDimensions.paddingXL),

                    // Main Animation Area
                    Expanded(child: _buildAnimationArea()),

                    const SizedBox(height: AppDimensions.paddingXL),

                    // Controls Section
                    _buildControlsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            color: _getStatusColor(appState.conversationState).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(
              color: _getStatusColor(
                appState.conversationState,
              ).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                _getStatusIcon(appState.conversationState),
                color: _getStatusColor(appState.conversationState),
                size: AppDimensions.iconL,
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                appState.statusMessage,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _getStatusColor(appState.conversationState),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimationArea() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(child: _buildAnimation(appState.conversationState)),
        );
      },
    );
  }

  Widget _buildAnimation(ConversationState state) {
    switch (state) {
      case ConversationState.speaking:
        return const SpeakingAnimation();
      case ConversationState.listening:
        return const ListeningAnimation();
      case ConversationState.processing:
        return _buildProcessingAnimation();
      case ConversationState.idle:
        return _buildIdleState();
    }
  }

  Widget _buildProcessingAnimation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: AppDimensions.animationSizeMedium,
          height: AppDimensions.animationSizeMedium,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingL),
        Text(
          'Processing...',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.primaryBlue),
        ),
      ],
    );
  }

  Widget _buildIdleState() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        if (appState.isAutoFlowActive) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.pause_circle_rounded,
                  size: AppDimensions.iconXXL,
                  color: AppColors.textOnPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              Text(
                'Conversation Paused',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                'Use controls below to continue',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.inactive, width: 2),
              ),
              child: Icon(
                Icons.play_circle_rounded,
                size: AppDimensions.iconXXL,
                color: AppColors.inactive,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            Text(
              'Ready to Start',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              'Natural conversation will begin automatically',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlsSection() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return ConversationControls(
          conversationState: appState.conversationState,
          onStartSpeaking: () => appState.forceStartSpeaking(),
          onStartListening: () => appState.forceStartListening(),
          onStopConversation: () => appState.interruptConversation(),
        );
      },
    );
  }

  Color _getStatusColor(ConversationState state) {
    switch (state) {
      case ConversationState.speaking:
        return AppColors.speakingActive;
      case ConversationState.listening:
        return AppColors.listeningActive;
      case ConversationState.processing:
        return AppColors.warning;
      case ConversationState.idle:
        return AppColors.inactive;
    }
  }

  IconData _getStatusIcon(ConversationState state) {
    switch (state) {
      case ConversationState.speaking:
        return Icons.mic;
      case ConversationState.listening:
        return Icons.hearing;
      case ConversationState.processing:
        return Icons.hourglass_empty;
      case ConversationState.idle:
        return Icons.pause_circle_outline;
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Natural Conversation Mode'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🤖 Like Siri, Google Assistant, or Alexa:'),
            SizedBox(height: AppDimensions.paddingS),
            Text('1. Conversation starts automatically'),
            SizedBox(height: AppDimensions.paddingS),
            Text('2. Speak naturally when prompted'),
            SizedBox(height: AppDimensions.paddingS),
            Text('3. AI processes and responds automatically'),
            SizedBox(height: AppDimensions.paddingS),
            Text('4. Flow continues naturally'),
            SizedBox(height: AppDimensions.paddingM),
            Text(
              'Interrupt Controls:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: AppDimensions.paddingS),
            Text('• Force Listen: Make it listen to you'),
            SizedBox(height: AppDimensions.paddingS),
            Text('• Force Speak: Make AI respond'),
            SizedBox(height: AppDimensions.paddingS),
            Text('• Stop: End the conversation'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
