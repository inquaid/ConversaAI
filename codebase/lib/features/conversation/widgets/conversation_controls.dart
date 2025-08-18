import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class ConversationControls extends StatelessWidget {
  final ConversationState conversationState;
  final VoidCallback onStartSpeaking;
  final VoidCallback onStartListening;
  final VoidCallback onStopConversation;

  const ConversationControls({
    super.key,
    required this.conversationState,
    required this.onStartSpeaking,
    required this.onStartListening,
    required this.onStopConversation,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        if (appState.isAutoFlowActive) {
          return _buildNaturalFlowControls(context, appState);
        } else {
          return _buildManualControls(context);
        }
      },
    );
  }

  Widget _buildNaturalFlowControls(
    BuildContext context,
    AppStateProvider appState,
  ) {
    return Column(
      children: [
        // Status indicator
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingS,
          ),
          decoration: BoxDecoration(
            color: _getStateColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getStateIcon(),
                color: _getStateColor(),
                size: AppDimensions.iconS,
              ),
              const SizedBox(width: AppDimensions.paddingS),
              Text(
                _getFlowStatusText(),
                style: TextStyle(
                  color: _getStateColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.paddingL),

        // Interrupt controls
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Force Listen',
                onPressed: () => appState.forceStartSpeaking(),
                icon: Icons.mic_rounded,
                isOutlined: true,
                backgroundColor: AppColors.speakingActive,
                useGradient: false,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: CustomButton(
                text: 'Force Speak',
                onPressed: () => appState.forceStartListening(),
                icon: Icons.volume_up_rounded,
                isOutlined: true,
                backgroundColor: AppColors.listeningActive,
                useGradient: false,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.paddingM),

        // Stop conversation button
        CustomButton(
          text: 'Stop Conversation',
          onPressed: () => appState.interruptConversation(),
          icon: Icons.stop_circle_outlined,
          backgroundColor: AppColors.error,
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _buildManualControls(BuildContext context) {
    return Column(
      children: [
        // Main start button
        CustomButton(
          text: 'Start Natural Conversation',
          onPressed: () {
            final appState = context.read<AppStateProvider>();
            appState.startNaturalConversation();
          },
          icon: Icons.play_circle_filled_rounded,
          backgroundColor: AppColors.primaryPurple,
          useGradient: true,
          width: double.infinity,
        ),

        const SizedBox(height: AppDimensions.paddingM),

        // Manual controls
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Manual Listen',
                onPressed: onStartSpeaking,
                icon: Icons.mic_rounded,
                isOutlined: true,
                backgroundColor: AppColors.speakingActive,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: CustomButton(
                text: 'Manual Speak',
                onPressed: onStartListening,
                icon: Icons.volume_up_rounded,
                isOutlined: true,
                backgroundColor: AppColors.listeningActive,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStateColor() {
    switch (conversationState) {
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

  IconData _getStateIcon() {
    switch (conversationState) {
      case ConversationState.speaking:
        return Icons.mic_rounded;
      case ConversationState.listening:
        return Icons.volume_up_rounded;
      case ConversationState.processing:
        return Icons.hourglass_empty_rounded;
      case ConversationState.idle:
        return Icons.pause_circle_outline_rounded;
    }
  }

  String _getFlowStatusText() {
    switch (conversationState) {
      case ConversationState.speaking:
        return 'Natural flow: You are speaking';
      case ConversationState.listening:
        return 'Natural flow: AI is responding';
      case ConversationState.processing:
        return 'Natural flow: Processing...';
      case ConversationState.idle:
        return 'Natural flow: Paused';
    }
  }
}
