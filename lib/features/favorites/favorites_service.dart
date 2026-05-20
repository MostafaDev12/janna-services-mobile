import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/models/provider_summary.dart';

/// Local-only favorites store.
///
/// Stores a small snapshot of each provider (id, slug, name, cover, etc.)
/// so the favorites screen can render without re-hitting the network.
class FavoritesService extends ChangeNotifier {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  static const _key = 'favorite_providers_v1';

  final Map<int, _FavoriteEntry> _items = <int, _FavoriteEntry>{};
  SharedPreferences? _prefs;
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// Favorite ids in insertion order.
  List<int> get ids => _items.keys.toList(growable: false);

  /// Lightweight provider snapshots for rendering the favorites screen.
  List<ProviderSummary> get summaries =>
      _items.values.map((e) => e.toSummary()).toList(growable: false);

  bool isFavorite(int providerId) => _items.containsKey(providerId);

  Future<void> load() async {
    if (_loaded) return;
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      _items.clear();
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final j in decoded.whereType<Map<String, dynamic>>()) {
            // Per-entry try/catch so one malformed favorite (e.g. from an
            // older app version with a different schema) doesn't wipe out
            // the rest of the user's saved providers.
            try {
              final entry = _FavoriteEntry.fromJson(j);
              _items[entry.id] = entry;
            } catch (_) {
              // skip this entry
            }
          }
        }
      } catch (_) {
        // The whole blob is corrupt — start fresh.
        _items.clear();
      }
    }
    _loaded = true;
    notifyListeners();
  }

  /// Adds when missing, removes when already present.
  /// Requires a [ProviderSummary] so we can render the favorites list offline.
  Future<void> toggle(ProviderSummary provider) async {
    if (_items.containsKey(provider.id)) {
      _items.remove(provider.id);
    } else {
      _items[provider.id] = _FavoriteEntry.fromSummary(provider);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> remove(int providerId) async {
    if (_items.remove(providerId) != null) {
      notifyListeners();
      await _persist();
    }
  }

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_items.values.map((e) => e.toJson()).toList(growable: false)),
    );
  }
}

class _FavoriteEntry {
  _FavoriteEntry({
    required this.id,
    required this.slug,
    required this.name,
    required this.areaType,
    required this.isFeatured,
    this.shortDescription,
    this.coverImageUrl,
    this.logoUrl,
    this.categoryName,
    this.categorySlug,
  });

  final int id;
  final String slug;
  final String name;
  final String? shortDescription;
  final String? coverImageUrl;
  final String? logoUrl;
  final String areaType;
  final bool isFeatured;
  final String? categoryName;
  final String? categorySlug;

  factory _FavoriteEntry.fromSummary(ProviderSummary p) => _FavoriteEntry(
        id: p.id,
        slug: p.slug,
        name: p.name,
        shortDescription: p.shortDescription,
        coverImageUrl: p.coverImageUrl,
        logoUrl: p.logoUrl,
        areaType: p.areaType,
        isFeatured: p.isFeatured,
        categoryName: p.categoryName,
        categorySlug: p.categorySlug,
      );

  factory _FavoriteEntry.fromJson(Map<String, dynamic> j) => _FavoriteEntry(
        id: j['id'] as int,
        slug: j['slug'] as String,
        name: j['name'] as String,
        shortDescription: j['short_description'] as String?,
        coverImageUrl: j['cover_image_url'] as String?,
        logoUrl: j['logo_url'] as String?,
        areaType: (j['area_type'] as String?) ?? 'inside_compound',
        isFeatured: (j['is_featured'] as bool?) ?? false,
        categoryName: j['category_name'] as String?,
        categorySlug: j['category_slug'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'name': name,
        'short_description': shortDescription,
        'cover_image_url': coverImageUrl,
        'logo_url': logoUrl,
        'area_type': areaType,
        'is_featured': isFeatured,
        'category_name': categoryName,
        'category_slug': categorySlug,
      };

  ProviderSummary toSummary() => ProviderSummary(
        id: id,
        name: name,
        slug: slug,
        areaType: areaType,
        isFeatured: isFeatured,
        shortDescription: shortDescription,
        coverImageUrl: coverImageUrl,
        logoUrl: logoUrl,
        categoryName: categoryName,
        categorySlug: categorySlug,
      );
}
