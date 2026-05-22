import 'package:flutter/material.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/utils/responsive.dart';
import '../../shared/widgets/empty_view.dart';
import '../../shared/widgets/provider_card.dart';
import 'favorites_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.of(context, 'favorites'))),
      body: AnimatedBuilder(
        animation: FavoritesService.instance,
        builder: (_, __) {
          final favs = FavoritesService.instance.summaries;
          if (favs.isEmpty) {
            return EmptyView(
              title: AppStrings.of(context, 'no_favorites'),
              message: AppStrings.of(context, 'tap_heart_to_save'),
              icon: Icons.favorite_border_rounded,
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppBreakpoints.maxContent,
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: providerGridDelegate(w),
                    itemCount: favs.length,
                    itemBuilder: (_, i) => ProviderCard(provider: favs[i]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
