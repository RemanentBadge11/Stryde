import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/features/progression/domain/entities/rank.dart';

class RankBadge extends StatelessWidget {
  const RankBadge({
    required this.rankName,
    this.size = 18,
    this.showLabel = false,
    super.key,
  });

  final String rankName;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final assetPath = RankAssetResolver.getSvgAssetPath(rankName);

    final svgIcon = SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => Icon(
          Icons.military_tech_rounded,
          size: size,
          color: AppColors.primary,
        ),
      ),
    );

    if (!showLabel) return svgIcon;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        svgIcon,
        const SizedBox(width: 4),
        Text(
          rankName,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
