import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/i18n/locale_service.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/responsive.dart';
import '../../shared/models/paginated.dart';
import '../../shared/models/provider_summary.dart';
import '../../shared/widgets/empty_view.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_view.dart';
import '../../shared/widgets/provider_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _api = ApiClient.instance;
  Timer? _debounce;

  bool _loading = false;
  Object? _error;
  List<ProviderSummary> _results = const [];
  String _activeKeyword = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    LocaleService.instance.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LocaleService.instance.removeListener(_onLocaleChanged);
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onLocaleChanged() {
    // Re-run the current keyword against the API in the new language.
    if (mounted && _activeKeyword.isNotEmpty) {
      final kw = _activeKeyword;
      _activeKeyword = ''; // force _run() to proceed past its short-circuit
      _run(kw);
    }
  }

  /// Triggers a rebuild whenever the search field text changes — so the
  /// clear (X) button can appear/disappear correctly.
  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _run(value));
  }

  Future<void> _run(String keyword) async {
    final kw = keyword.trim();
    if (kw == _activeKeyword) return;
    _activeKeyword = kw;
    if (kw.isEmpty) {
      setState(() {
        _results = const [];
        _loading = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final json = await _api.get('/search', query: {'keyword': kw});
      final page = Paginated.fromJson(
        json as Map<String, dynamic>,
        ProviderSummary.fromJson,
      );
      if (!mounted) return;
      setState(() {
        _results = page.items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: AppStrings.of(context, 'search_hint'),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
            fillColor: Colors.transparent,
            filled: false,
          ),
          onChanged: _onChanged,
          onSubmitted: _run,
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _controller.clear();
                _onChanged('');
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView();
    if (_error != null) {
      return ErrorView(error: _error, onRetry: () => _run(_controller.text));
    }
    if (_activeKeyword.isEmpty) {
      return EmptyView(
        title: AppStrings.of(context, 'find_something'),
        message: AppStrings.of(context, 'find_something_hint'),
        icon: Icons.search_rounded,
      );
    }
    if (_results.isEmpty) {
      return EmptyView(
        title: AppStrings.of(context, 'no_results'),
        message: context.trf('no_results_for', {'q': _activeKeyword}),
        icon: Icons.search_off_rounded,
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
              itemCount: _results.length,
              itemBuilder: (_, i) => ProviderCard(provider: _results[i]),
            ),
          ),
        );
      },
    );
  }
}
