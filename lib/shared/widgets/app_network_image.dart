import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Cached network image with skeleton placeholder and graceful error fallback.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholderIcon = Icons.image_outlined,
  });

  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;

    if (url == null || url!.isEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: _Placeholder(
          icon: placeholderIcon,
          width: width,
          height: height,
        ),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: url!,
        fit: fit,
        width: width,
        height: height,
        placeholder: (_, __) => _Placeholder(
          icon: placeholderIcon,
          width: width,
          height: height,
          showSpinner: true,
        ),
        errorWidget: (_, __, ___) => _Placeholder(
          icon: Icons.broken_image_outlined,
          width: width,
          height: height,
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.icon,
    this.width,
    this.height,
    this.showSpinner = false,
  });

  final IconData icon;
  final double? width;
  final double? height;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.background,
      alignment: Alignment.center,
      child: showSpinner
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textMuted,
              ),
            )
          : Icon(icon, color: AppColors.textMuted, size: 32),
    );
  }
}
