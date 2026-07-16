import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'press_scale.dart';

class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDestructive;
  final IconData? icon;
  final double? width;
  final double height;
  final bool compact;

  const GoldButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDestructive = false,
    this.icon,
    this.width,
    this.height = 52,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isDestructive ? AppColors.crimson : AppColors.gold;
    final fgColor = isDestructive ? Colors.white : AppColors.background;

    return PressScale(
      enabled: onPressed != null && !isLoading,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: isDestructive
                ? AppColors.crimsonGradient
                : AppColors.goldGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDestructive ? AppColors.crimson : AppColors.gold)
                  .withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onPressed != null && !isLoading ? onPressed : null,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: bgColor,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: compact ? 16 : 18, color: fgColor),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            color: fgColor,
                            fontSize: compact ? 13 : 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (isDestructive)
                          Transform.rotate(
                            angle: pi / 4,
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
