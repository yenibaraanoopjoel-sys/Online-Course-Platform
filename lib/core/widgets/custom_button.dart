import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum ButtonVariant { primary, secondary, outlined, danger, ghost }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool loading;
  final bool fullWidth;
  final Widget? icon;
  final double? height;
  final double? fontSize;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.loading = false,
    this.fullWidth = false,
    this.icon,
    this.height,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: fontSize ?? 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    final disabled = onPressed == null || loading;

    switch (variant) {
      case ButtonVariant.secondary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: height ?? 48,
          child: ElevatedButton(
            onPressed: disabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            child: child,
          ),
        );
      case ButtonVariant.outlined:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: height ?? 48,
          child: OutlinedButton(
            onPressed: disabled ? null : onPressed,
            child: child,
          ),
        );
      case ButtonVariant.danger:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: height ?? 48,
          child: ElevatedButton(
            onPressed: disabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: child,
          ),
        );
      case ButtonVariant.ghost:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: height ?? 48,
          child: TextButton(
            onPressed: disabled ? null : onPressed,
            child: child,
          ),
        );
      case ButtonVariant.primary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: height ?? 48,
          child: ElevatedButton(
            onPressed: disabled ? null : onPressed,
            child: child,
          ),
        );
    }
  }
}
