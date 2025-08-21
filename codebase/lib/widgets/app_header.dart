import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  final VoidCallback? onDemoPressed;

  const AppHeader({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
    this.onDemoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App logo/title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ConversaAI',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),

          // Action buttons
          Row(
            children: [
              // Demo button
              if (onDemoPressed != null)
                IconButton(
                  onPressed: onDemoPressed,
                  icon: const Icon(Icons.play_circle_outline),
                  tooltip: 'Try Demo',
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

              if (onDemoPressed != null) const SizedBox(width: 8),

              // Theme toggle button
              IconButton(
                onPressed: onThemeToggle,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    key: ValueKey(isDarkMode),
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                tooltip: 'Toggle Theme',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surface.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
