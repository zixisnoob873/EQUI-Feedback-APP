import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GoldRadarPulse extends StatefulWidget {
  final Widget child;
  final VoidCallback? onComplete;

  const GoldRadarPulse({
    super.key,
    required this.child,
    this.onComplete,
  });

  @override
  State<GoldRadarPulse> createState() => _GoldRadarPulseState();
}

class _GoldRadarPulseState extends State<GoldRadarPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward().then((_) => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _RadarPainter(
            progress: _controller.value,
            color: AppColors.gold,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RadarPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final currentRadius = maxRadius * progress;

    final paint = Paint()
      ..color = color.withValues(alpha: (1.0 - progress) * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, currentRadius, paint);

    final dotPaint = Paint()
      ..color = color.withValues(alpha: (1.0 - progress) * 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, currentRadius * 0.02, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
