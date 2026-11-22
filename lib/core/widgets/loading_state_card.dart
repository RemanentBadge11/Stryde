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
    );
  }
}
