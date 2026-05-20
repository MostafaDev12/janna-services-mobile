import 'package:flutter/foundation.dart';

import '../../core/network/api_client.dart';
import '../../shared/models/app_settings.dart';

/// Holds the latest branding snapshot returned by `GET /api/settings`.
///
/// Subscribers (splash, home app bar) listen for changes so the UI refreshes
/// the moment settings finish loading and again whenever the language changes.
class BrandingService extends ChangeNotifier {
  BrandingService._();
  static final BrandingService instance = BrandingService._();

  AppSettings _settings = AppSettings.empty;
  AppSettings get settings => _settings;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  /// Fetches settings from the backend. Safe to call multiple times — failures
  /// keep the previous snapshot (or the empty default) instead of throwing.
  /// Call this on bootstrap and again when the language changes.
  Future<void> refresh({ApiClient? client}) async {
    try {
      final res = await (client ?? ApiClient.instance).get('/settings');
      final data = (res is Map<String, dynamic>) ? res['data'] : null;
      if (data is Map<String, dynamic>) {
        _settings = AppSettings.fromJson(data);
      }
    } catch (_) {
      // Network/parse failure — keep whatever snapshot we already had so the
      // splash and home screens can still render with their hardcoded fallbacks.
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }
}
