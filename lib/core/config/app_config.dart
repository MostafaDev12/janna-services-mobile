/// App-wide configuration values.
///
/// The API base URL can be overridden at build time without editing source:
///
///   flutter run --dart-define=API_BASE_URL=https://api.janna-october.com/api
///
/// If no value is provided, [defaultApiBaseUrl] is used.
class AppConfig {
  AppConfig._();

  /// Default value when no `--dart-define=API_BASE_URL=...` is given.
  ///
  /// IMPORTANT: there is no single URL that works everywhere — see README §3.
  ///
  /// - Android emulator             →  http://10.0.2.2:8000/api    (current default)
  /// - Chrome / Windows / iOS sim   →  http://127.0.0.1:8000/api
  /// - Physical phone on same Wi-Fi →  http://<your-LAN-IP>:8000/api
  ///
  /// Always prefer `--dart-define=API_BASE_URL=...` over editing this constant.
  static const String defaultApiBaseUrl =
      'http://10.0.2.2:8000/api';

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: defaultApiBaseUrl,
  );

  static const String appName = 'Janna October Services';
  static const Duration networkTimeout = Duration(seconds: 20);
}
