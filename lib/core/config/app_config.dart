/// App-wide configuration values.
///
/// The API base URL is injected at build time via `--dart-define`:
///
///   flutter build appbundle --release \
///     --dart-define=API_BASE_URL=https://project.cangrow.shop/api
///
/// For development, pass the local Laragon host instead — see README §3.
class AppConfig {
  AppConfig._();

  /// Production fallback used when no `--dart-define=API_BASE_URL=...` is
  /// provided. Intentionally points at the public HTTPS backend so a release
  /// build that forgets the flag still ships a working app instead of a
  /// localhost URL Google Play reviewers cannot reach.
  static const String defaultApiBaseUrl =
      'https://project.cangrow.shop/api';

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: defaultApiBaseUrl,
  );

  static const String appName = 'Janna October Services';
  static const Duration networkTimeout = Duration(seconds: 20);
}
