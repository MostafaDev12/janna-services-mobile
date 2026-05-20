import 'package:flutter/material.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/i18n/locale_service.dart';
import '../../shared/models/category.dart';
import '../../shared/models/paginated.dart';
import '../../shared/models/provider_summary.dart';
import '../../shared/widgets/empty_view.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_view.dart';
import '../../shared/widgets/provider_card.dart';
import 'categories_repository.dart';

class CategoryProvidersScreen extends StatefulWidget {
  const CategoryProvidersScreen({super.key, required this.category});

  final Category category;

  @override
  State<CategoryProvidersScreen> createState() =>
      _CategoryProvidersScreenState();
}

class _CategoryProvidersScreenState extends State<CategoryProvidersScreen> {
  final _repo = CategoriesRepository();
  final _scroll = ScrollController();
  final List<ProviderSummary> _items = [];

  bool _loading = true;
  bool _loadingMore = false;
  Object? _error;
  int _page = 1;
  int _lastPage = 1;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    LocaleService.instance.addListener(_onLocaleChanged);
    _load();
  }

  @override
  void dispose() {
    LocaleService.instance.removeListener(_onLocaleChanged);
    _scroll.dispose();
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) _load();
  }

  Future<void> _load({bool reset = true}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
        _items.clear();
      });
    }
    try {
      final Paginated<ProviderSummary> r =
          await _repo.providersOf(widget.category.slug, page: _page);
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
      final r = await _repo.providersOf(widget.category.slug, page: _page);
      setState(() {
        _items.addAll(r.items);
        _lastPage = r.lastPage;
      });
    } catch (_) {
      _page -= 1; // roll back
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView();
    if (_error != null) return ErrorView(error: _error, onRetry: _load);
    if (_items.isEmpty) {
      return EmptyView(
        title: AppStrings.of(context, 'no_providers_yet'),
        message: AppStrings.of(context, 'no_providers_in_category'),
        icon: Icons.storefront_outlined,
      );
    }
    return RefreshIndicator(
      onRefresh: () => _load(),
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
