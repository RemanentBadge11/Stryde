import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';

class LoadingStateCard extends StatelessWidget {
  const LoadingStateCard({this.height = 112, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: SizedBox(
        height: height,
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 250),
            builder: (context, opacity, child) =>
                Opacity(opacity: opacity, child: child),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
