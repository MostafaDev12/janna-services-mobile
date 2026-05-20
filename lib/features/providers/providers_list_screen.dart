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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.of(context, 'providers')),
      ),
      body: Column(
        children: [
          _FilterBar(
            categories: _categories,
            selectedSlug: _categorySlug,
            areaType: _areaType,
            featured: _featured,
            onChange: (cat, area, feat) {
              setState(() {
                _categorySlug = cat;
                _areaType = area;
                _featured = feat;
              });
              _load();
            },
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

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.categories,
    required this.selectedSlug,
    required this.areaType,
    required this.featured,
    required this.onChange,
  });

  final List<Category> categories;
  final String? selectedSlug;
  final String? areaType;
  final bool featured;
  final void Function(String? categorySlug, String? areaType, bool featured)
      onChange;

  @override
  Widget build(BuildContext context) {
    // Two `Wrap`s separated by a thin divider so the chips flow onto
    // multiple rows on narrow screens instead of clipping off the side.
    // Row 1 = type filters (featured + area); Row 2 = categories.
    final categoryChips = <Widget>[
      ChoiceChip(
        label: Text(AppStrings.of(context, 'all_categories')),
        selected: selectedSlug == null,
        onSelected: (_) => onChange(null, areaType, featured),
      ),
      for (final c in categories)
        ChoiceChip(
          label: Text(c.name),
          selected: selectedSlug == c.slug,
          onSelected: (v) => onChange(v ? c.slug : null, areaType, featured),
        ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: Text(AppStrings.of(context, 'featured')),
                selected: featured,
                onSelected: (v) => onChange(selectedSlug, areaType, v),
              ),
              ChoiceChip(
                label: Text(AppStrings.of(context, 'inside_compound')),
                selected: areaType == 'inside_compound',
                onSelected: (v) => onChange(
                  selectedSlug,
                  v ? 'inside_compound' : null,
                  featured,
                ),
              ),
              ChoiceChip(
                label: Text(AppStrings.of(context, 'near_compound')),
                selected: areaType == 'near_compound',
                onSelected: (v) => onChange(
                  selectedSlug,
                  v ? 'near_compound' : null,
                  featured,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categoryChips,
          ),
        ],
      ),
    );
  }
}
