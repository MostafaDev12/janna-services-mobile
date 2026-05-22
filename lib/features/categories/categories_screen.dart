import 'package:flutter/material.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/i18n/locale_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../shared/models/category.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/empty_view.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_view.dart';
import 'categories_repository.dart';
import 'category_providers_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _repo = CategoriesRepository();
  late Future<List<Category>> _future = _repo.all();

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
    if (mounted) setState(() => _future = _repo.all());
  }

  Future<void> _refresh() async {
    setState(() => _future = _repo.all());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.of(context, 'categories'))),
      body: FutureBuilder<List<Category>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(error: snapshot.error, onRetry: _refresh);
          }
          final categories = snapshot.data ?? const <Category>[];
          if (categories.isEmpty) {
            return EmptyView(
              title: AppStrings.of(context, 'no_categories_yet'),
              message: AppStrings.of(context, 'no_categories_message'),
              icon: Icons.category_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final tablet = isTabletWidth(w);
                // Cap content width on huge tablets / desktop so cards don't
                // stretch edge-to-edge.
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppBreakpoints.maxContent,
                    ),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: categoryGridDelegate(w),
                      itemCount: categories.length,
                      itemBuilder: (_, i) => _CategoryTile(
                        category: categories[i],
                        wide: tablet,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, this.wide = false});

  final Category category;

  /// `true` on tablet+ — renders a compact row tile (icon left, text right)
  /// that fits the ~130 px tile height. `false` keeps the original mobile
  /// 2-column column layout.
  final bool wide;

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
          padding: EdgeInsets.all(wide ? 12 : 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: wide ? _buildWide(context) : _buildColumn(context),
        ),
      ),
    );
  }

  Widget _icon(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.chipBg,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: category.imageUrl != null
            ? AppNetworkImage(
                url: category.imageUrl,
                width: size,
                height: size,
                borderRadius: BorderRadius.circular(14),
              )
            : Icon(Icons.category_rounded,
                color: AppColors.chipFg, size: size * 0.5),
      );

  Widget _buildColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _icon(56),
        const Spacer(),
        Text(
          category.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.trf('n_providers', {'n': '${category.providersCount ?? 0}'}),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildWide(BuildContext context) {
    return Row(
      children: [
        _icon(52),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.trf(
                    'n_providers', {'n': '${category.providersCount ?? 0}'}),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
