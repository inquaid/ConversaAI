import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class StatusIndicator extends StatefulWidget {
  final String status;
  final bool isConnected;

  const StatusIndicator({
    super.key,
    required this.status,
    required this.isConnected,
  });

  @override
  State<StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<StatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDurations.pulseAnimation,
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isConnected) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isConnected != oldWidget.isConnected) {
      if (widget.isConnected) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: widget.isConnected
              ? AppColors.success.withOpacity(0.3)
              : AppColors.inactive.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isConnected ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: widget.isConnected
                        ? AppColors.success
                        : AppColors.inactive,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isConnected ? 'Connected' : 'Disconnected',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: widget.isConnected
                        ? AppColors.success
                        : AppColors.inactive,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXS),
                Text(
                  widget.status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            widget.isConnected ? Icons.check_circle : Icons.error_outline,
            color: widget.isConnected ? AppColors.success : AppColors.inactive,
            size: AppDimensions.iconM,
          ),
        ],
      ),
    );
  }
}
