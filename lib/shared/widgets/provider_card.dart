import 'package:flutter/material.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../features/favorites/favorites_service.dart';
import '../../features/providers/provider_details_screen.dart';
import '../models/provider_summary.dart';
import 'app_network_image.dart';
import 'area_chip.dart';

class ProviderCard extends StatelessWidget {
  const ProviderCard({super.key, required this.provider});

  final ProviderSummary provider;

  void _open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProviderDetailsScreen(slug: provider.slug),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 16:9 keeps cover images consistently sized across mobile /
              // tablet — the image grows with card width instead of being
              // pinned to 130 px and looking lost on wide tablet cards.
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(
                      url: provider.coverImageUrl,
                      width: double.infinity,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                    ),
                    if (provider.isFeatured)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 13, color: Colors.white),
                              const SizedBox(width: 3),
                              Text(
                                AppStrings.of(context, 'featured'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: _FavoriteCircleButton(provider: provider),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (provider.categoryName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          provider.categoryName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    AreaChip(areaType: provider.areaType, dense: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteCircleButton extends StatelessWidget {
  const _FavoriteCircleButton({required this.provider});

  final ProviderSummary provider;

  @override
  Widget build(BuildContext context) {
    final fav = FavoritesService.instance;
    return AnimatedBuilder(
      animation: fav,
      builder: (_, __) {
        final isFav = fav.isFavorite(provider.id);
        return Material(
          color: Colors.white.withValues(alpha: .92),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => fav.toggle(provider),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? AppColors.danger : AppColors.textSecondary,
                size: 18,
              ),
            ),
          ),
        );
      },
    );
  }
}
