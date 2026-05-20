import 'package:flutter/material.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/i18n/locale_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/launch_helpers.dart';
import '../../shared/models/provider_details.dart';
import '../../shared/models/provider_media.dart';
import '../../shared/models/provider_summary.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/area_chip.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/gallery_viewer.dart';
import '../../shared/widgets/loading_view.dart';
import '../favorites/favorites_service.dart';
import 'providers_repository.dart';

class ProviderDetailsScreen extends StatefulWidget {
  const ProviderDetailsScreen({super.key, required this.slug});

  final String slug;

  @override
  State<ProviderDetailsScreen> createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen> {
  final _repo = ProvidersRepository();
  late Future<ProviderDetails> _future = _repo.details(widget.slug);

  @override
  void initState() {
    super.initState();
    LocaleService.instance.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LocaleService.instance.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) setState(() => _future = _repo.details(widget.slug));
  }

  Future<void> _reload() async {
    setState(() => _future = _repo.details(widget.slug));
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ProviderDetails>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(),
              body: const LoadingView(),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(),
              body: ErrorView(error: snapshot.error, onRetry: _reload),
            );
          }
          return _DetailsBody(provider: snapshot.data!);
        },
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.provider});

  final ProviderDetails provider;

  @override
  Widget build(BuildContext context) {
    final hasPhone = (provider.phone ?? '').isNotEmpty;
    final hasWa    = (provider.whatsapp ?? '').isNotEmpty;
    final hasMap   = (provider.locationUrl ?? '').isNotEmpty;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 220,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            AnimatedBuilder(
              animation: FavoritesService.instance,
              builder: (_, __) {
                final fav = FavoritesService.instance.isFavorite(provider.id);
                return IconButton(
                  icon: Icon(
                    fav ? Icons.favorite : Icons.favorite_border,
                    color: fav ? Colors.redAccent : Colors.white,
                  ),
                  onPressed: () => FavoritesService.instance.toggle(
                    ProviderSummary(
                      id: provider.id,
                      name: provider.name,
                      slug: provider.slug,
                      areaType: provider.areaType,
                      isFeatured: provider.isFeatured,
                      shortDescription: provider.shortDescription,
                      coverImageUrl: provider.coverImageUrl,
                      logoUrl: provider.logoUrl,
                      categoryName: provider.categoryName,
                      categorySlug: provider.categorySlug,
                    ),
                  ),
                );
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                AppNetworkImage(url: provider.coverImageUrl),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x99000000),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.logoUrl != null) ...[
                      AppNetworkImage(
                        url: provider.logoUrl,
                        width: 64,
                        height: 64,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (provider.categoryName != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                provider.categoryName!,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          AreaChip(areaType: provider.areaType),
                        ],
                      ),
                    ),
                    if (provider.isFeatured)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(Icons.star_rounded,
                            color: AppColors.accent),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _ActionRow(
                  hasPhone: hasPhone,
                  hasWhatsApp: hasWa,
                  hasMap: hasMap,
                  phone: provider.phone,
                  whatsapp: provider.whatsapp,
                  locationUrl: provider.locationUrl,
                ),
                const SizedBox(height: 16),
                if ((provider.shortDescription ?? '').isNotEmpty)
                  Text(
                    provider.shortDescription!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 12),
                _InfoTile(
                  icon: Icons.location_on_outlined,
                  label: provider.address,
                ),
                _InfoTile(
                  icon: Icons.schedule,
                  label: provider.workingHours,
                ),
                _InfoTile(
                  icon: Icons.phone_outlined,
                  label: provider.phone,
                ),
                _InfoTile(
                  icon: Icons.chat_outlined,
                  label: provider.whatsapp,
                ),
                if ((provider.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.of(context, 'about'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    provider.description!,
                    style: const TextStyle(
                      height: 1.45,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (provider.hasGallery)
          _MediaSliver(
              title: AppStrings.of(context, 'gallery'),
              items: provider.gallery),
        if (provider.hasMenu)
          _MediaSliver(
              title: AppStrings.of(context, 'menu'),
              items: provider.menu,
              big: true),
        if (provider.hasProducts)
          _MediaSliver(
              title: AppStrings.of(context, 'products'),
              items: provider.products),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.hasPhone,
    required this.hasWhatsApp,
    required this.hasMap,
    required this.phone,
    required this.whatsapp,
    required this.locationUrl,
  });

  final bool hasPhone;
  final bool hasWhatsApp;
  final bool hasMap;
  final String? phone;
  final String? whatsapp;
  final String? locationUrl;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    if (hasPhone) {
      actions.add(_ActionButton(
        icon: Icons.phone_rounded,
        label: AppStrings.of(context, 'call'),
        color: AppColors.success,
        onTap: () => LaunchHelpers.dial(phone),
      ));
    }
    if (hasWhatsApp) {
      actions.add(_ActionButton(
        icon: Icons.chat_rounded,
        label: AppStrings.of(context, 'whatsapp'),
        color: AppColors.whatsapp,
        onTap: () => LaunchHelpers.openWhatsApp(whatsapp),
      ));
    }
    if (hasMap) {
      actions.add(_ActionButton(
        icon: Icons.location_on_rounded,
        label: AppStrings.of(context, 'location'),
        color: AppColors.primary,
        onTap: () => LaunchHelpers.openMap(locationUrl),
      ));
    }

    if (actions.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: actions[i]),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 13),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, this.label});

  final IconData icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    if (label == null || label!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label!,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaSliver extends StatelessWidget {
  const _MediaSliver({
    required this.title,
    required this.items,
    this.big = false,
  });

  final String title;
  final List<ProviderMedia> items;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final visible =
        items.where((e) => e.imageUrl.isNotEmpty).toList(growable: false);
    if (visible.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final urls = visible.map((e) => e.imageUrl).toList(growable: false);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(
              height: big ? 220 : 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: visible.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final m = visible[i];
                  return GestureDetector(
                    onTap: () => GalleryViewer.open(
                      context,
                      images: urls,
                      initialIndex: i,
                      title: title,
                    ),
                    child: Hero(
                      tag: m.imageUrl,
                      child: AppNetworkImage(
                        url: m.imageUrl,
                        width: big ? 160 : 130,
                        height: big ? 220 : 130,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
