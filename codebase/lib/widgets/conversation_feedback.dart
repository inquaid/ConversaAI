import 'package:flutter/material.dart';
import '../providers/voice_provider.dart';

class ConversationFeedback extends StatelessWidget {
  final VoiceState voiceState;
  final String transcribedText;
  final String responseText;

  const ConversationFeedback({
    super.key,
    required this.voiceState,
    required this.transcribedText,
    required this.responseText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status indicator
          _buildStatusIndicator(context),

          const SizedBox(height: 24),

          // Conversation content
          _buildConversationContent(context),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (voiceState) {
      case VoiceState.idle:
        statusText = "Ready to chat";
        statusColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
        statusIcon = Icons.mic_none;
        break;
      case VoiceState.listening:
        statusText = "I'm listening...";
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.hearing;
        break;
      case VoiceState.processing:
        statusText = "Processing...";
        statusColor = Theme.of(context).colorScheme.secondary;
        statusIcon = Icons.psychology;
        break;
      case VoiceState.speaking:
        statusText = "Speaking...";
        statusColor = Theme.of(context).colorScheme.tertiary;
        statusIcon = Icons.volume_up;
        break;
      case VoiceState.error:
        statusText = "Something went wrong";
        statusColor = Theme.of(context).colorScheme.error;
        statusIcon = Icons.error_outline;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationContent(BuildContext context) {
    if (transcribedText.isEmpty && responseText.isEmpty) {
      return _buildWelcomeMessage(context);
    }

    return Column(
      children: [
        // User's transcribed text
        if (transcribedText.isNotEmpty)
          _buildMessageBubble(context, transcribedText, isUser: true),

        if (transcribedText.isNotEmpty && responseText.isNotEmpty)
          const SizedBox(height: 16),

        // AI response
        if (responseText.isNotEmpty)
          _buildMessageBubble(context, responseText, isUser: false),
      ],
    );
  }

  Widget _buildWelcomeMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.waving_hand,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            "Welcome to ConversaAI!",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the microphone to start practicing your English conversation skills.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    String text, {
    required bool isUser,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : null,
            bottomLeft: !isUser ? const Radius.circular(4) : null,
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isUser
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
