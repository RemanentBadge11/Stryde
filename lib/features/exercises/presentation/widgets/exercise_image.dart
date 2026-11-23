import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';

/// Renders a bundled exercise illustration with a graceful fallback.
///
/// The catalog stores local sources as `asset:assets/images/...`; older data
/// could still contain an HTTP URL, so both are supported.
class ExerciseImage extends StatelessWidget {
  const ExerciseImage({
    required this.imageUrl,
    this.localImage,
    required this.semanticLabel,
    this.width,
    this.height,
    this.borderRadius = 14,
    super.key,
  });

  final String imageUrl;
  final String? localImage;
  final String semanticLabel;
  final double? width;
  final double? height;
  final double borderRadius;

  static const ColorFilter _grayscaleFilter = ColorFilter.matrix(<double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: ColoredBox(
          color: AppColors.surfaceVariant,
          child: ColorFiltered(
            colorFilter: _grayscaleFilter,
            child: _buildImage(),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final assetPath = (localImage != null && localImage!.isNotEmpty)
        ? localImage!
        : (imageUrl.startsWith('asset:')
              ? imageUrl.substring('asset:'.length)
              : null);

    if (assetPath != null) {
      return Image.asset(
        assetPath,
        semanticLabel: semanticLabel,
        width: width,
        height: height,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return const _ImagePlaceholder();
        },
        errorBuilder: (context, error, stackTrace) => const _ImageFallback(),
      );
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        semanticLabel: semanticLabel,
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const _ImagePlaceholder();
        },
        errorBuilder: (context, error, stackTrace) => const _ImageFallback(),
      );
    }

    return Image.asset(
      imageUrl,
      semanticLabel: semanticLabel,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const _ImageFallback(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(Icons.image_outlined, color: AppColors.textMuted, size: 20),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.fitness_center_rounded,
        color: AppColors.textMuted,
        size: 22,
      ),
    );
  }
}
