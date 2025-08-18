import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final List<Color>? gradientColors;
  final bool useGradient;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.gradientColors,
    this.useGradient = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOutlined) {
      return _buildOutlinedButton(context);
    }
    return _buildModernButton(context);
  }

  Widget _buildModernButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.onPressed != null ? _handleTapDown : null,
            onTapUp: widget.onPressed != null ? _handleTapUp : null,
            onTapCancel: _handleTapCancel,
            onTap: widget.isLoading ? null : widget.onPressed,
            child: Container(
              width: widget.width,
              height: widget.height ?? AppDimensions.buttonHeight,
              decoration: BoxDecoration(
                gradient: widget.useGradient
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors:
                            widget.gradientColors ??
                            [AppColors.gradientStart, AppColors.gradientEnd],
                      )
                    : null,
                color: widget.useGradient
                    ? null
                    : (widget.backgroundColor ?? AppColors.primaryPurple),
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                boxShadow: [
                  BoxShadow(
                    color: (widget.backgroundColor ?? AppColors.primaryPurple)
                        .withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                  if (_isPressed)
                    BoxShadow(
                      color: (widget.backgroundColor ?? AppColors.primaryPurple)
                          .withOpacity(0.5),
                      blurRadius: 25,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Center(child: _buildButtonContent()),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.onPressed != null ? _handleTapDown : null,
            onTapUp: widget.onPressed != null ? _handleTapUp : null,
            onTapCancel: _handleTapCancel,
            onTap: widget.isLoading ? null : widget.onPressed,
            child: Container(
              width: widget.width,
              height: widget.height ?? AppDimensions.buttonHeight,
              decoration: BoxDecoration(
                color: _isPressed
                    ? (widget.backgroundColor ?? AppColors.primaryPurple)
                          .withOpacity(0.1)
                    : Colors.transparent,
                border: Border.all(
                  color: widget.backgroundColor ?? AppColors.primaryPurple,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              child: Center(child: _buildButtonContent()),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent() {
    if (widget.isLoading) {
      return SizedBox(
        width: AppDimensions.iconM,
        height: AppDimensions.iconM,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.isOutlined
                ? (widget.textColor ?? AppColors.primaryPurple)
                : (widget.textColor ?? AppColors.textOnPrimary),
          ),
        ),
      );
    }

    Color textColor = widget.isOutlined
        ? (widget.textColor ?? AppColors.primaryPurple)
        : (widget.textColor ?? AppColors.textOnPrimary);

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: AppDimensions.iconM, color: textColor),
          const SizedBox(width: AppDimensions.paddingS),
          Text(
            widget.text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }
}
