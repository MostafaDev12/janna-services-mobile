import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../i18n/locale_service.dart';
import 'api_exception.dart';

/// Thin HTTP client wrapping `package:http` with:
/// - shared base URL
/// - JSON decoding
/// - timeouts
/// - consistent error mapping to [ApiException]
class ApiClient {
  ApiClient({http.Client? httpClient, String? baseUrl})
      : _client = httpClient ?? http.Client(),
        // Strip any trailing slashes so `${baseUrl}/categories` never produces
        // a double-slash, regardless of how the user configured API_BASE_URL.
        _baseUrl = _normalize(baseUrl ?? AppConfig.apiBaseUrl);

  static String _normalize(String url) {
    var u = url.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u;
  }

  static final ApiClient instance = ApiClient();

  final http.Client _client;
  final String _baseUrl;

  String get baseUrl => _baseUrl;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    // Auto-append the current app language so the backend returns
    // localized name/description/title/etc. Any caller-supplied params
    // (featured=1, category=..., keyword=...) are preserved untouched.
    final merged = <String, String>{
      'lang': LocaleService.instance.languageCode,
      if (query != null)
        for (final entry in query.entries) entry.key: '${entry.value}',
    };

    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: merged);

    try {
      final res = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(AppConfig.networkTimeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (res.body.isEmpty) return null;
        return jsonDecode(res.body);
      }

      throw ApiException(
        _extractMessage(res.body) ?? 'Request failed',
        statusCode: res.statusCode,
      );
    } on SocketException {
      throw ApiException(
        'No internet connection. Please check your network.',
      );
    } on TimeoutException {
      throw ApiException('The server took too long to respond.');
    } on FormatException {
      throw ApiException('Received an invalid response from the server.');
    }
  }

  String? _extractMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['message'] is String) {
        return decoded['message'] as String;
      }
    } catch (_) {}
    return null;
  }
}
