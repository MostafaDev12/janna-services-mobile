import 'package:flutter/material.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/i18n/locale_service.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/category.dart';
import '../../shared/models/provider_summary.dart';
import '../../shared/widgets/empty_view.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_view.dart';
import '../../shared/widgets/provider_card.dart';
import '../categories/categories_repository.dart';
import '../important_numbers/important_numbers_screen.dart';
import '../search/search_screen.dart';
import 'providers_repository.dart';

class ProvidersListScreen extends StatefulWidget {
  const ProvidersListScreen({
    super.key,
    this.featured = false,
    this.initialCategorySlug,
  });

  final bool featured;
  final String? initialCategorySlug;

  @override
  State<ProvidersListScreen> createState() => _ProvidersListScreenState();
}

class _ProvidersListScreenState extends State<ProvidersListScreen> {
  final _repo = ProvidersRepository();
  final _catRepo = CategoriesRepository();
  final _scroll = ScrollController();
  final List<ProviderSummary> _items = [];

  List<Category> _categories = const [];
  String? _categorySlug;
  String? _areaType;
  late bool _featured = widget.featured;

  bool _loading = true;
  bool _loadingMore = false;
  Object? _error;
  int _page = 1;
  int _lastPage = 1;

  /// How many of the top categories are shown directly in the horizontal
  /// row; the rest fall under the "More" bottom sheet.
  static const int _primaryCategoriesCount = 4;

  @override
  void initState() {
    super.initState();
    _categorySlug = widget.initialCategorySlug;
    _scroll.addListener(_onScroll);
    LocaleService.instance.addListener(_onLocaleChanged);
    _loadCategories();
    _load();
  }

  @override
  void dispose() {
    LocaleService.instance.removeListener(_onLocaleChanged);
    _scroll.dispose();
    super.dispose();
  }

  void _onLocaleChanged() {
    if (!mounted) return;
    _loadCategories();
    _load();
  }

  Future<void> _loadCategories() async {
    try {
      final list = await _catRepo.all();
      if (mounted) setState(() => _categories = list);
    } catch (_) {}
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _items.clear();
      _page = 1;
    });
    try {
      final r = await _repo.list(
        page: _page,
        categorySlug: _categorySlug,
        areaType: _areaType,
        featured: _featured,
      );
      setState(() {
        _items.addAll(r.items);
        _lastPage = r.lastPage;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _onScroll() {
    if (_loadingMore || _page >= _lastPage) return;
    if (_scroll.position.pixels >
        _scroll.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    _page += 1;
    try {
      final r = await _repo.list(
        page: _page,
        categorySlug: _categorySlug,
        areaType: _areaType,
        featured: _featured,
      );
      setState(() {
        _items.addAll(r.items);
        _lastPage = r.lastPage;
      });
    } catch (_) {
      _page -= 1;
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _applyChange({
    String? Function(String?)? category,
    String? Function(String?)? area,
    bool Function(bool)? featured,
  }) {
    setState(() {
      if (category != null) _categorySlug = category(_categorySlug);
      if (area != null) _areaType = area(_areaType);
      if (featured != null) _featured = featured(_featured);
    });
    _load();
  }

  /// Emergency Numbers comes back from the API as a Category row, but it does
  /// not behave like a regular provider list (it links to phone numbers, not
  /// businesses). We hide it from the categories chip row and surface it as a
  /// dedicated quick action instead.
  bool _isEmergencyCategory(Category c) {
    final slug = c.slug.toLowerCase();
    final name = c.name.toLowerCase();
    return slug.contains('emergency') ||
        name.contains('emergency') ||
        name.contains('طوار'); // matches both "طوارئ" and "الطوارئ"
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
        _categories.where((c) => !_isEmergencyCategory(c)).toList();
    final primary = filtered.take(_primaryCategoriesCount).toList();
    final overflow = filtered.skip(_primaryCategoriesCount).toList();
    final hasEmergency = _categories.any(_isEmergencyCategory);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.of(context, 'providers')),
      ),
      body: Column(
        children: [
          _CompactFilters(
            primaryCategories: primary,
            overflowCategories: overflow,
            selectedSlug: _categorySlug,
            areaType: _areaType,
            featured: _featured,
            showEmergencyAction: hasEmergency,
            onFeaturedToggle: () =>
                _applyChange(featured: (v) => !v),
            onAreaSelected: (next) =>
                _applyChange(area: (cur) => cur == next ? null : next),
            onCategorySelected: (slug) => _applyChange(
              category: (cur) => cur == slug ? null : slug,
            ),
            onOpenSearch: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
            onOpenEmergencyNumbers: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ImportantNumbersScreen()),
            ),
          ),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_loading) return const LoadingView();
    if (_error != null) return ErrorView(error: _error, onRetry: _load);
    if (_items.isEmpty) {
      return EmptyView(
        title: AppStrings.of(context, 'no_providers_match'),
        message: AppStrings.of(context, 'try_removing_filters'),
        icon: Icons.search_off_rounded,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: GridView.builder(
        controller: _scroll,
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: _items.length + (_loadingMore ? 1 : 0),
        itemBuilder: (_, i) {
          if (i >= _items.length) {
            return const Center(child: CircularProgressIndicator());
          }
          return ProviderCard(provider: _items[i]);
        },
      ),
    );
  }
}

/// All filter chrome above the grid: search bar, area/featured segmented
/// chips, horizontally-scrollable categories with overflow into a "More"
/// bottom sheet, plus the Emergency Numbers quick action.
class _CompactFilters extends StatelessWidget {
  const _CompactFilters({
    required this.primaryCategories,
    required this.overflowCategories,
    required this.selectedSlug,
    required this.areaType,
    required this.featured,
    required this.showEmergencyAction,
    required this.onFeaturedToggle,
    required this.onAreaSelected,
    required this.onCategorySelected,
    required this.onOpenSearch,
    required this.onOpenEmergencyNumbers,
  });

  final List<Category> primaryCategories;
  final List<Category> overflowCategories;
  final String? selectedSlug;
  final String? areaType;
  final bool featured;
  final bool showEmergencyAction;

  final VoidCallback onFeaturedToggle;
  final ValueChanged<String> onAreaSelected;
  final ValueChanged<String?> onCategorySelected;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenEmergencyNumbers;

  bool get _isOverflowSelected =>
      selectedSlug != null &&
      overflowCategories.any((c) => c.slug == selectedSlug);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchTapBar(onTap: onOpenSearch),
          const SizedBox(height: 8),
          _AreaFeaturedRow(
            featured: featured,
            areaType: areaType,
            onFeaturedToggle: onFeaturedToggle,
            onAreaSelected: onAreaSelected,
          ),
          const SizedBox(height: 8),
          _CategoryRow(
            primaryCategories: primaryCategories,
            hasOverflow: overflowCategories.isNotEmpty,
            selectedSlug: selectedSlug,
            isOverflowSelected: _isOverflowSelected,
            onCategorySelected: onCategorySelected,
            onMore: () => _openMoreSheet(context),
          ),
          if (showEmergencyAction) ...[
            const SizedBox(height: 8),
            _EmergencyNumbersAction(onTap: onOpenEmergencyNumbers),
          ],
        ],
      ),
    );
  }

  Future<void> _openMoreSheet(BuildContext context) async {
    final picked = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _MoreCategoriesSheet(
        categories: overflowCategories,
        selectedSlug: selectedSlug,
      ),
    );
    // The sheet returns: a category slug to select, '' to mean "clear", or
    // null when dismissed without choosing — leave selection unchanged.
    if (picked == null) return;
    onCategorySelected(picked.isEmpty ? null : picked);
  }
}

class _SearchTapBar extends StatelessWidget {
  const _SearchTapBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.search_rounded,
                  size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.of(context, 'search_hint'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AreaFeaturedRow extends StatelessWidget {
  const _AreaFeaturedRow({
    required this.featured,
    required this.areaType,
    required this.onFeaturedToggle,
    required this.onAreaSelected,
  });

  final bool featured;
  final String? areaType;
  final VoidCallback onFeaturedToggle;
  final ValueChanged<String> onAreaSelected;

  @override
  Widget build(BuildContext context) {
    // Horizontal scroll so it never wraps to a second row on narrow phones.
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _CompactChip(
            label: AppStrings.of(context, 'featured'),
            icon: Icons.star_rounded,
            selected: featured,
            onTap: onFeaturedToggle,
          ),
          const SizedBox(width: 8),
          _CompactChip(
            label: AppStrings.of(context, 'inside_compound'),
            selected: areaType == 'inside_compound',
            onTap: () => onAreaSelected('inside_compound'),
          ),
          const SizedBox(width: 8),
          _CompactChip(
            label: AppStrings.of(context, 'near_compound'),
            selected: areaType == 'near_compound',
            onTap: () => onAreaSelected('near_compound'),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.primaryCategories,
    required this.hasOverflow,
    required this.selectedSlug,
    required this.isOverflowSelected,
    required this.onCategorySelected,
    required this.onMore,
  });

  final List<Category> primaryCategories;
  final bool hasOverflow;
  final String? selectedSlug;
  final bool isOverflowSelected;
  final ValueChanged<String?> onCategorySelected;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _CompactChip(
            label: AppStrings.of(context, 'all'),
            selected: selectedSlug == null,
            onTap: () => onCategorySelected(null),
          ),
          for (final c in primaryCategories) ...[
            const SizedBox(width: 8),
            _CompactChip(
              label: c.name,
              selected: selectedSlug == c.slug,
              onTap: () => onCategorySelected(c.slug),
            ),
          ],
          if (hasOverflow) ...[
            const SizedBox(width: 8),
            _CompactChip(
              label: AppStrings.of(context, 'more'),
              icon: Icons.tune_rounded,
              // Highlight "More" while a category from inside the sheet is
              // the active filter, so the user can see at a glance that
              // something behind it is selected.
              selected: isOverflowSelected,
              onTap: onMore,
            ),
          ],
        ],
      ),
    );
  }
}

class _EmergencyNumbersAction extends StatelessWidget {
  const _EmergencyNumbersAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accent.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.local_phone_rounded,
                  size: 18, color: AppColors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.of(context, 'important_numbers'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small pill used for both filters and categories. Selected state uses the
/// app primary color so users can see at a glance which filter is active.
class _CompactChip extends StatelessWidget {
  const _CompactChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.textPrimary;
    final bg = selected ? AppColors.primary : AppColors.background;
    final border = selected ? AppColors.primary : AppColors.border;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: fg),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreCategoriesSheet extends StatelessWidget {
  const _MoreCategoriesSheet({
    required this.categories,
    required this.selectedSlug,
  });

  final List<Category> categories;
  final String? selectedSlug;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              AppStrings.of(context, 'categories'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in categories)
                  _CompactChip(
                    label: c.name,
                    selected: selectedSlug == c.slug,
                    // Empty string is the "clear selection" signal; non-empty
                    // is the new slug. See _CompactFilters._openMoreSheet.
                    onTap: () => Navigator.of(context)
                        .pop(selectedSlug == c.slug ? '' : c.slug),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
