import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/conversation_models.dart';

class ConversaChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showTimestamp;
  final bool showAvatar;

  const ConversaChatBubble({
    super.key,
    required this.message,
    this.showTimestamp = false,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;
    final theme = Theme.of(context);

    return Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Assistant avatar (left side)
              if (!isUser && showAvatar) _buildAvatar(context, false),

              // Message content
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  margin: EdgeInsets.only(
                    left: isUser ? 40 : 8,
                    right: isUser ? 8 : 40,
                  ),
                  child: Column(
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      // Message bubble
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _getBubbleColor(context, isUser),
                          borderRadius: _getBubbleBorderRadius(isUser),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          message.content,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _getTextColor(context, isUser),
                            height: 1.4,
                          ),
                        ),
                      ),

                      // Timestamp
                      if (showTimestamp)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _formatTimestamp(message.timestamp),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // User avatar (right side)
              if (isUser && showAvatar) _buildAvatar(context, true),
            ],
          ),
        )
        .animate()
        .slideY(
          begin: 0.3,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        )
        .fadeIn(duration: const Duration(milliseconds: 300));
  }

  Widget _buildAvatar(BuildContext context, bool isUser) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isUser
              ? [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ]
              : [
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Color _getBubbleColor(BuildContext context, bool isUser) {
    final theme = Theme.of(context);
    if (isUser) {
      return theme.colorScheme.primary;
    } else {
      return theme.colorScheme.surfaceContainerHighest.withOpacity(0.8);
    }
  }

  Color _getTextColor(BuildContext context, bool isUser) {
    final theme = Theme.of(context);
    if (isUser) {
      return theme.colorScheme.onPrimary;
    } else {
      return theme.colorScheme.onSurface;
    }
  }

  BorderRadius _getBubbleBorderRadius(bool isUser) {
    const radius = Radius.circular(18);
    const smallRadius = Radius.circular(4);

    if (isUser) {
      return const BorderRadius.only(
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: smallRadius,
      );
    } else {
      return const BorderRadius.only(
        topLeft: radius,
        topRight: radius,
        bottomLeft: smallRadius,
        bottomRight: radius,
      );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

class TypingIndicatorBubble extends StatefulWidget {
  const TypingIndicatorBubble({super.key});

  @override
  State<TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<TypingIndicatorBubble>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _dotControllers;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _dotControllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
    });

    // Stagger the dot animations
    for (int i = 0; i < _dotControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _dotControllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _dotControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Row(
            children: [
              // Assistant avatar
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(bottom: 4, right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.secondary,
                      theme.colorScheme.secondaryContainer,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 18,
                ),
              ),

              // Typing bubble
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                    0.8,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < 3; i++)
                      AnimatedBuilder(
                        animation: _dotControllers[i],
                        builder: (context, child) {
                          return Container(
                            margin: EdgeInsets.only(
                              right: i < 2 ? 4 : 0,
                              bottom: _dotControllers[i].value * 4,
                            ),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.4 + (_dotControllers[i].value * 0.4),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .slideY(
          begin: 0.3,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        )
        .fadeIn(duration: const Duration(milliseconds: 300));
  }
}
