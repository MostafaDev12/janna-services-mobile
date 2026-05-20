import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/i18n/locale_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/launch_helpers.dart';
import '../../shared/models/banner.dart';
import '../../shared/models/category.dart';
import '../../shared/models/important_number.dart';
import '../../shared/models/provider_summary.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_view.dart';
import '../../shared/widgets/provider_card.dart';
import '../../shared/widgets/section_header.dart';
import '../branding/branding_service.dart';
import '../categories/category_providers_screen.dart';
import '../important_numbers/important_numbers_screen.dart';
import '../providers/provider_details_screen.dart';
import '../providers/providers_list_screen.dart';
import '../search/search_screen.dart';
import 'home_repository.dart';

/// Responsive breakpoints used across the Home screen.
class _Bp {
  _Bp._();

  static const double tablet = 600;
  static const double desktop = 1024;

  /// Maximum width the centered content column may grow to on large screens.
  static const double maxContent = 1200;

  /// Outer horizontal padding inside the centered content column.
  static double hPad(double w) {
    if (w < tablet) return 16;
    if (w < desktop) return 24;
    return 32;
  }

  /// Hero banner height — grows with available width.
  static double bannerHeight(double w) {
    if (w < tablet) return 160;
    if (w < desktop) return 220;
    return 280;
  }

  /// Columns to use for the categories grid. Returning 0 means
  /// "use the horizontal strip instead" (mobile).
  static int categoryColumns(double w) {
    if (w < tablet) return 0;
    if (w < 900) return 3;
    if (w < desktop) return 4;
    if (w < 1400) return 5;
    return 6;
  }

  /// Columns for the featured providers grid. Returning 0 means
  /// "use the horizontal strip instead" (mobile).
  static int featuredColumns(double w) {
    if (w < tablet) return 0;
    if (w < desktop) return 2;
    if (w < 1400) return 3;
    return 4;
  }

  /// How many category tiles to show per page in the mobile slider.
  /// We let the page snap so the user never sees a half-clipped tile.
  static int categoryTilesPerPage(double w) {
    if (w < 360) return 3;
    if (w < 500) return 4;
    return 5;
  }

  /// How many important-number tiles per slider page. Each tile is wider than
  /// a category tile (it shows a phone string), so the per-page counts are
  /// lower at every breakpoint.
  static int numberTilesPerPage(double w) {
    if (w < 360) return 1;
    if (w < 600) return 2;
    if (w < 1024) return 3;
    return 4;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = HomeRepository();
  late Future<HomeData> _future = _repo.loadAll();

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

  /// Re-fetch home data + branding so banners/categories/featured AND the
  /// app-bar title come back in the new language. Triggered by the language
  /// switcher.
  void _onLocaleChanged() {
    BrandingService.instance.refresh();
    if (!mounted) return;
    setState(() {
      _future = _repo.loadAll();
    });
  }

  Future<void> _refresh() async {
    BrandingService.instance.refresh();
    setState(() {
      _future = _repo.loadAll();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Rebuild only the title so the rest of the app bar stays static
        // while branding is loaded asynchronously.
        title: AnimatedBuilder(
          animation: BrandingService.instance,
          builder: (_, __) => const _AppBarBrand(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: AppStrings.of(context, 'search'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          const _LanguageSwitcher(),
        ],
      ),
      body: FutureBuilder<HomeData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(error: snapshot.error, onRetry: _refresh);
          }
          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final hPad = _Bp.hPad(w);
                final bannerH = _Bp.bannerHeight(w);
                final catCols = _Bp.categoryColumns(w);
                final featCols = _Bp.featuredColumns(w);

                // Single outer scrollable. Inner grids/strips use
                // shrinkWrap or fixed-height SizedBoxes so we never nest a
                // vertically-scrolling Grid inside this ListView.
                return ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: _Bp.maxContent),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (data.banners.isNotEmpty)
                              _BannerCarousel(
                                banners: data.banners,
                                horizontalPadding: hPad,
                                height: bannerH,
                              ),
                            _SearchBar(horizontalPadding: hPad),
                            if (data.categories.isNotEmpty) ...[
                              SectionHeader(
                                title: AppStrings.of(context, 'categories'),
                                actionLabel: AppStrings.of(context, 'see_all'),
                                onAction: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ProvidersListScreen(),
                                  ),
                                ),
                                padding:
                                    EdgeInsets.fromLTRB(hPad, 18, hPad, 8),
                              ),
                              if (catCols == 0)
                                _CategoriesSlider(
                                  categories: data.categories,
                                  horizontalPadding: hPad,
                                  tilesPerPage:
                                      _Bp.categoryTilesPerPage(w),
                                )
                              else
                                _CategoriesGrid(
                                  categories: data.categories,
                                  columns: catCols,
                                  horizontalPadding: hPad,
                                ),
                            ],
                            if (data.featured.isNotEmpty) ...[
                              SectionHeader(
                                title: AppStrings.of(context, 'featured_providers'),
                                actionLabel: AppStrings.of(context, 'view_all'),
                                onAction: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ProvidersListScreen(
                                      featured: true,
                                    ),
                                  ),
                                ),
                                padding:
                                    EdgeInsets.fromLTRB(hPad, 18, hPad, 8),
                              ),
                              if (featCols == 0)
                                _FeaturedSlider(providers: data.featured)
                              else
                                _FeaturedGrid(
                                  providers: data.featured,
                                  columns: featCols,
                                  horizontalPadding: hPad,
                                ),
                            ],
                            if (data.importantNumbers.isNotEmpty) ...[
                              SectionHeader(
                                title: AppStrings.of(context, 'important_numbers'),
                                actionLabel: AppStrings.of(context, 'view_all'),
                                onAction: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ImportantNumbersScreen(),
                                  ),
                                ),
                                padding:
                                    EdgeInsets.fromLTRB(hPad, 18, hPad, 8),
                              ),
                              _ImportantNumbersSlider(
                                numbers: data.importantNumbers,
                                horizontalPadding: hPad,
                                tilesPerPage: _Bp.numberTilesPerPage(w),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search bar
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.horizontalPadding});
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 0),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.of(context, 'search_hint'),
                    style: const TextStyle(color: AppColors.textSecondary),
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

// ─────────────────────────────────────────────────────────────────────────────
// Banner carousel
// ─────────────────────────────────────────────────────────────────────────────

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel({
    required this.banners,
    required this.horizontalPadding,
    required this.height,
  });

  final List<HomeBanner> banners;
  final double horizontalPadding;
  final double height;

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  PageController? _controller;
  int _index = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _ensureController(double viewportFraction) {
    if (_controller == null ||
        _controller!.viewportFraction != viewportFraction) {
      _controller?.dispose();
      _controller = PageController(
        viewportFraction: viewportFraction,
        initialPage: _index,
      );
      _timer?.cancel();
      if (widget.banners.length > 1) {
        _timer = Timer.periodic(const Duration(seconds: 5), (_) {
          if (_controller?.hasClients != true) return;
          final next = (_index + 1) % widget.banners.length;
          _controller!.animateToPage(
            next,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        });
      }
    }
  }

  void _onTap(HomeBanner b) {
    final slug = b.providerSlug;
    if (slug != null && slug.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProviderDetailsScreen(slug: slug),
        ),
      );
    } else if ((b.linkUrl ?? '').isNotEmpty) {
      LaunchHelpers.openUrl(b.linkUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tighter card peek on desktop, more aggressive on mobile.
    final w = MediaQuery.of(context).size.width;
    final viewportFraction = w >= _Bp.desktop ? 0.85 : 0.92;
    _ensureController(viewportFraction);

    return Padding(
      padding:
          EdgeInsets.fromLTRB(widget.horizontalPadding - 6, 8, widget.horizontalPadding - 6, 0),
      child: Column(
        children: [
          SizedBox(
            height: widget.height,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.banners.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) {
                final b = widget.banners[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: GestureDetector(
                    onTap: () => _onTap(b),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppNetworkImage(
                          url: b.imageUrl,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        if ((b.title ?? '').isNotEmpty)
                          Positioned(
                            left: 14,
                            right: 14,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: .42),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    b.title!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if ((b.subtitle ?? '').isNotEmpty)
                                    Text(
                                      b.subtitle!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.banners.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.banners.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Categories — horizontal strip (mobile) + grid (tablet/desktop)
// ─────────────────────────────────────────────────────────────────────────────

/// Mobile categories slider. Each page snaps to `tilesPerPage` tiles so the
/// user never sees a half-clipped tile with wrapped/cut-off text.
class _CategoriesSlider extends StatefulWidget {
  const _CategoriesSlider({
    required this.categories,
    required this.horizontalPadding,
    required this.tilesPerPage,
  });

  final List<Category> categories;
  final double horizontalPadding;
  final int tilesPerPage;

  @override
  State<_CategoriesSlider> createState() => _CategoriesSliderState();
}

class _CategoriesSliderState extends State<_CategoriesSlider> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _CategoriesSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If page geometry changes (rotation, window resize crossing a breakpoint),
    // clamp the current index so we never sit on a non-existent page.
    final pages = (widget.categories.length / widget.tilesPerPage).ceil();
    if (_index >= pages && pages > 0) {
      _index = pages - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.hasClients) {
          _controller.jumpToPage(_index);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageCount =
        (widget.categories.length / widget.tilesPerPage).ceil();

    return Column(
      children: [
        SizedBox(
          height: 110,
          child: PageView.builder(
            controller: _controller,
            itemCount: pageCount,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, pageIndex) {
              final start = pageIndex * widget.tilesPerPage;
              final end = (start + widget.tilesPerPage)
                  .clamp(0, widget.categories.length);
              final pageItems = widget.categories.sublist(start, end);

              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: widget.horizontalPadding),
                child: Row(
                  children: [
                    for (var i = 0; i < widget.tilesPerPage; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(
                        child: i < pageItems.length
                            ? _CategoryTile(
                                category: pageItems[i],
                                compact: true,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        if (pageCount > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _DotsIndicator(count: pageCount, index: _index),
          ),
      ],
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid({
    required this.categories,
    required this.columns,
    required this.horizontalPadding,
  });

  final List<Category> categories;
  final int columns;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          // Wide row-style tile: 64px icon + label + count fits at this ratio
          // across the breakpoint range.
          childAspectRatio: 2.6,
        ),
        itemCount: categories.length,
        itemBuilder: (_, i) => _CategoryTile(category: categories[i]),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, this.compact = false});
  final Category category;

  /// `true` for the mobile strip layout (icon on top, label below).
  /// `false` for the tablet/desktop grid layout (icon left, label right).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoryProvidersScreen(category: category),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: compact ? _buildCompact() : _buildWide(),
        ),
      ),
    );
  }

  Widget _icon(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.chipBg,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: category.imageUrl != null
            ? AppNetworkImage(
                url: category.imageUrl,
                width: size,
                height: size,
                borderRadius: BorderRadius.circular(10),
              )
            : const Icon(Icons.category_outlined, color: AppColors.chipFg),
      );

  Widget _buildCompact() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _icon(44),
        const SizedBox(height: 6),
        Expanded(
          child: Text(
            category.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWide() {
    return Row(
      children: [
        _icon(44),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (category.providersCount != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '${category.providersCount} providers',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Featured providers — horizontal strip (mobile) + grid (tablet/desktop)
// ─────────────────────────────────────────────────────────────────────────────

/// Mobile featured-providers slider. Uses PageView with viewportFraction so
/// the next card peeks ~14% on the right — clear "swipe me" affordance —
/// and snaps to one card per page. Page-indicator dots are shown below.
class _FeaturedSlider extends StatefulWidget {
  const _FeaturedSlider({required this.providers});

  final List<ProviderSummary> providers;

  @override
  State<_FeaturedSlider> createState() => _FeaturedSliderState();
}

class _FeaturedSliderState extends State<_FeaturedSlider> {
  final _controller = PageController(viewportFraction: 0.86);
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.providers.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ProviderCard(provider: widget.providers[i]),
            ),
          ),
        ),
        if (widget.providers.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _DotsIndicator(
              count: widget.providers.length,
              index: _index,
            ),
          ),
      ],
    );
  }
}

/// Shared page-indicator dots used by both mobile sliders (matches the
/// banner carousel's existing visual style).
class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class _FeaturedGrid extends StatelessWidget {
  const _FeaturedGrid({
    required this.providers,
    required this.columns,
    required this.horizontalPadding,
  });

  final List<ProviderSummary> providers;
  final int columns;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          // Slightly wider than ProvidersListScreen (0.72): grid cells get
          // bigger on desktop, so 0.85 keeps the card from looking sparse.
          childAspectRatio: 0.85,
        ),
        itemCount: providers.length,
        itemBuilder: (_, i) => ProviderCard(provider: providers[i]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Important numbers — paged slider with dots, mirrors the categories slider
// so users get the same swipe-snap-dots interaction across both sections.
// ─────────────────────────────────────────────────────────────────────────────

class _ImportantNumbersSlider extends StatefulWidget {
  const _ImportantNumbersSlider({
    required this.numbers,
    required this.horizontalPadding,
    required this.tilesPerPage,
  });

  final List<ImportantNumber> numbers;
  final double horizontalPadding;
  final int tilesPerPage;

  @override
  State<_ImportantNumbersSlider> createState() =>
      _ImportantNumbersSliderState();
}

class _ImportantNumbersSliderState extends State<_ImportantNumbersSlider> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ImportantNumbersSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clamp current page if a window resize changed the per-page count.
    final preview = widget.numbers.take(6).toList();
    final pages = (preview.length / widget.tilesPerPage).ceil();
    if (_index >= pages && pages > 0) {
      _index = pages - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.hasClients) {
          _controller.jumpToPage(_index);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = widget.numbers.take(6).toList();
    final pageCount = (preview.length / widget.tilesPerPage).ceil();

    return Column(
      children: [
        SizedBox(
          height: 96,
          child: PageView.builder(
            controller: _controller,
            itemCount: pageCount,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, pageIndex) {
              final start = pageIndex * widget.tilesPerPage;
              final end =
                  (start + widget.tilesPerPage).clamp(0, preview.length);
              final pageItems = preview.sublist(start, end);

              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: widget.horizontalPadding),
                child: Row(
                  children: [
                    for (var i = 0; i < widget.tilesPerPage; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(
                        child: i < pageItems.length
                            ? _NumberTile(number: pageItems[i])
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        if (pageCount > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _DotsIndicator(count: pageCount, index: _index),
          ),
      ],
    );
  }
}

class _NumberTile extends StatelessWidget {
  const _NumberTile({required this.number});
  final ImportantNumber number;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => LaunchHelpers.dial(number.phone),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              number.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Row(
              children: [
                const Icon(Icons.phone_in_talk_rounded,
                    size: 16, color: AppColors.success),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    number.phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App-bar brand — small logo/icon + dynamic app name from /api/settings.
// Falls back to the localized AppStrings name when no logo/icon is set or the
// remote image fails to load.
// ─────────────────────────────────────────────────────────────────────────────

class _AppBarBrand extends StatelessWidget {
  const _AppBarBrand();

  @override
  Widget build(BuildContext context) {
    final settings = BrandingService.instance.settings;
    // Prefer icon (square) for the app bar, fall back to the full logo.
    final imageUrl = settings.hasIcon ? settings.iconUrl : settings.logoUrl;
    final name = (settings.appName ?? '').isNotEmpty
        ? settings.appName!
        : AppStrings.of(context, 'app_name');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if ((imageUrl ?? '').isNotEmpty) ...[
          SizedBox(
            width: 44,
            height: 44,
            child: CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.contain,
              placeholder: (_, __) => const SizedBox.shrink(),
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Language switcher — appears in the Home app bar.
// ─────────────────────────────────────────────────────────────────────────────

class _LanguageSwitcher extends StatelessWidget {
  const _LanguageSwitcher();

  @override
  Widget build(BuildContext context) {
    final current = Localizations.localeOf(context).languageCode;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.translate_rounded),
      tooltip: AppStrings.of(context, 'language'),
      onSelected: (code) =>
          LocaleService.instance.setLocale(Locale(code)),
      itemBuilder: (ctx) => [
        CheckedPopupMenuItem<String>(
          value: 'en',
          checked: current == 'en',
          child: Text(AppStrings.of(ctx, 'language_english')),
        ),
        CheckedPopupMenuItem<String>(
          value: 'ar',
          checked: current == 'ar',
          child: Text(AppStrings.of(ctx, 'language_arabic')),
        ),
      ],
    );
  }
}
