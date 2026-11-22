import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';

class PrCelebrationOverlay extends StatefulWidget {
  const PrCelebrationOverlay({
    required this.exerciseNames,
    required this.onDismiss,
    this.accentColor,
    super.key,
  });

  final List<String> exerciseNames;
  final VoidCallback onDismiss;
  final Color? accentColor;

  static Future<void> show({
    required BuildContext context,
    required List<String> exerciseNames,
    Color? accentColor,
  }) {
    return Navigator.of(context).push<void>(
      PageRouteBuilder(
        opaque: true,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            PrCelebrationOverlay(
          exerciseNames: exerciseNames,
          onDismiss: () => Navigator.of(context).pop(),
          accentColor: accentColor,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  State<PrCelebrationOverlay> createState() => _PrCelebrationOverlayState();
}

class _PrCelebrationOverlayState extends State<PrCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.exerciseNames.length == 1
        ? widget.exerciseNames.first
        : widget.exerciseNames.join(' & ');

    final accent = widget.accentColor ??
        (Theme.of(context).colorScheme.primary != Colors.transparent
            ? Theme.of(context).colorScheme.primary
            : AppColors.primary);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onDismiss,
        child: SafeArea(
          child: SizedBox.expand(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.45),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: _HexagonPainter(
                            color: accent,
                            strokeWidth: 3.5,
                            fillColor: accent.withValues(alpha: 0.18),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.fitness_center_rounded,
                              size: 52,
                              color: accent,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space32),
                    FadeTransition(
                      opacity: _opacityAnimation,
                      child: Column(
                        children: <Widget>[
                          Text(
                            'NEW PR!',
                            key: const ValueKey<String>('new-pr-header'),
                            style: TextStyle(
                              color: accent,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4.0,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space12),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space32,
                            ),
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space8),
                          Text(
                            'Volume record broken',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 32,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Text(
                      'TAP ANYWHERE TO CONTINUE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  const _HexagonPainter({
    required this.color,
    required this.strokeWidth,
    required this.fillColor,
  });

  final Color color;
  final double strokeWidth;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;
    final path = Path();

    for (var i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
