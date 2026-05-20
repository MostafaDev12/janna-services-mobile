import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the app's current locale (en / ar) and persists it across launches.
///
/// Read by:
/// - `MaterialApp.locale` (wrapped in `AnimatedBuilder` so the app rebuilds
///    when the locale changes)
/// - `ApiClient.get` (appends `?lang=` to every request)
/// - Each screen that fetches data (re-runs its future on locale change)
class LocaleService extends ChangeNotifier {
  LocaleService._();
  static final LocaleService instance = LocaleService._();

  static const String _key = 'app_locale_v1';
  static const List<String> supportedCodes = ['en', 'ar'];

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  /// Current language code as it should be sent to the API (`en` or `ar`).
  String get languageCode => _locale.languageCode;

  bool get isRtl => _locale.languageCode == 'ar';

  bool _loaded = false;
  bool get isLoaded => _loaded;

  /// Resolves initial locale in this order:
  ///   1. Persisted choice from `shared_preferences`
  ///   2. Device locale (if Arabic)
  ///   3. English fallback
  Future<void> load({Locale? deviceLocale}) async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored != null && supportedCodes.contains(stored)) {
      _locale = Locale(stored);
    } else if (deviceLocale != null &&
        deviceLocale.languageCode == 'ar') {
      _locale = const Locale('ar');
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale next) async {
    if (!supportedCodes.contains(next.languageCode)) return;
    if (_locale.languageCode == next.languageCode) return;
    _locale = Locale(next.languageCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _locale.languageCode);
  }
}
