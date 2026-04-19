import 'package:flutter/material.dart';
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/constants/app_sizes.dart';

/// الزر الأصفر الموحد — المكون الأساسي للتفاعل
/// يدعم: أنيميشن ضغط، حالة تحميل، تعطيل، أيقونة اختيارية
class YellowButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double height;

  const YellowButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.width,
    this.height = AppSizes.buttonHeight,
  });

  @override
  State<YellowButton> createState() => _YellowButtonState();
}

class _YellowButtonState extends State<YellowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppSizes.animFast),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  void _onTapDown() {
    if (!_isEnabled) return;
    setState(() => _isPressed = true);
    _animController.forward();
  }

  void _onTapUp() {
    if (!_isEnabled) return;
    setState(() => _isPressed = false);
    _animController.reverse();
  }

  void _onTap() {
    if (!_isEnabled) return;
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: SizedBox(
        width: widget.isFullWidth ? double.infinity : widget.width,
        height: widget.height,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isEnabled ? _onTap : null,
            onTapDown: _isEnabled ? (_) => _onTapDown() : null,
            onTapUp: _isEnabled ? (_) => _onTapUp() : null,
            onTapCancel: _isEnabled ? _onTapUp : null,
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            child: Ink(
              decoration: BoxDecoration(
                gradient: _isEnabled ? AppColors.primaryGradient : null,
                color: _isEnabled
                    ? null
                    : (isDark ? AppColors.darkCard : AppColors.lightDivider),
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                boxShadow: _isEnabled
                    ? [
                        BoxShadow(
                          color:
                              AppColors.primaryYellow.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.onPrimary,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: _isEnabled
                                  ? AppColors.onPrimary
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary),
                              size: AppSizes.iconMD,
                            ),
                            const SizedBox(width: AppSizes.paddingSM),
                          ],
                          Text(
                            widget.text,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: _isEnabled
                                      ? AppColors.onPrimary
                                      : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
