import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/conversation_models.dart';
import '../providers/voice_provider.dart';
import 'chat_bubble.dart';

class ConversationList extends StatefulWidget {
  final List<ChatMessage> messages;
  final bool isTyping;
  final VoiceState voiceState;
  final String currentTranscript;

  const ConversationList({
    super.key,
    required this.messages,
    this.isTyping = false,
    required this.voiceState,
    this.currentTranscript = '',
  });

  @override
  State<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(ConversationList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Auto-scroll to bottom when new messages arrive
    if (widget.messages.length != oldWidget.messages.length ||
        widget.isTyping != oldWidget.isTyping) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty &&
        !widget.isTyping &&
        widget.currentTranscript.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _calculateItemCount(),
        itemBuilder: (context, index) {
          return _buildListItem(context, index);
        },
      ),
    );
  }

  int _calculateItemCount() {
    int count = widget.messages.length;

    // Add current transcript if listening
    if (widget.voiceState == VoiceState.listening &&
        widget.currentTranscript.isNotEmpty) {
      count += 1;
    }

    // Add typing indicator if typing
    if (widget.isTyping) {
      count += 1;
    }

    return count;
  }

  Widget _buildListItem(BuildContext context, int index) {
    // Regular messages
    if (index < widget.messages.length) {
      final message = widget.messages[index];
      return ConversaChatBubble(
        message: message,
        showTimestamp: _shouldShowTimestamp(index),
        showAvatar: _shouldShowAvatar(index),
      );
    }

    // Current transcript while listening
    if (widget.voiceState == VoiceState.listening &&
        widget.currentTranscript.isNotEmpty &&
        index == widget.messages.length) {
      return _buildLiveTranscriptBubble(context);
    }

    // Typing indicator
    if (widget.isTyping) {
      return const TypingIndicatorBubble();
    }

    return const SizedBox.shrink();
  }

  Widget _buildLiveTranscriptBubble(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  margin: const EdgeInsets.only(left: 40, right: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.7),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(4),
                      ),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.currentTranscript,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              // User avatar
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primaryContainer,
                    ],
                  ),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 18),
              ),
            ],
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 2000),
          color: Colors.white.withOpacity(0.3),
        );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.2),
                        theme.colorScheme.secondary.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: 40,
                    color: theme.colorScheme.primary.withOpacity(0.6),
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.05, 1.05),
                  duration: const Duration(milliseconds: 2000),
                ),

            const SizedBox(height: 24),

            Text(
              'Welcome to ConversaAI!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Start a conversation by tapping the microphone button below.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                  0.3,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Speak clearly and naturally for best results!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowTimestamp(int index) {
    if (index == 0) return true;

    final currentMessage = widget.messages[index];
    final previousMessage = widget.messages[index - 1];

    // Show timestamp if more than 5 minutes apart
    return currentMessage.timestamp
            .difference(previousMessage.timestamp)
            .inMinutes >
        5;
  }

  bool _shouldShowAvatar(int index) {
    if (index == widget.messages.length - 1) return true;

    final currentMessage = widget.messages[index];
    final nextMessage = widget.messages[index + 1];

    // Show avatar if next message is from different sender
    return currentMessage.type != nextMessage.type;
  }
}
