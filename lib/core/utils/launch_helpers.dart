import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helpers for opening external apps (dialer, WhatsApp, maps, web links).
///
/// All entry points safely bail on null/empty input so callers can pass
/// raw API fields without a guard.
class LaunchHelpers {
  LaunchHelpers._();

  /// Opens the system dialer with the given phone number.
  ///
  /// Uses `Uri.parse('tel:$phone')` instead of `Uri(scheme: 'tel', path: ...)`
  /// so the leading `+` in international numbers (e.g. `+20150...`) is sent
  /// literally rather than percent-encoded — some Android dialers reject `%2B`.
  static Future<void> dial(String? phone) async {
    final trimmed = phone?.trim() ?? '';
    if (trimmed.isEmpty) return;
    final uri = Uri.parse('tel:$trimmed');
    await _launchOrCopy(uri, fallback: trimmed);
  }

  /// Opens WhatsApp chat to the given phone number. Strips every non-digit
  /// character (so `+20 150 000 1111` becomes `201500001111`).
  static Future<void> openWhatsApp(String? phone, {String? message}) async {
    if (phone == null) return;
    final cleaned = phone.replaceAll(RegExp(r'\D+'), '');
    if (cleaned.isEmpty) return;
    final qs = (message == null || message.isEmpty)
        ? ''
        : '?text=${Uri.encodeComponent(message)}';
    final uri = Uri.parse('https://wa.me/$cleaned$qs');
    await _launchOrCopy(uri, fallback: phone);
  }

  /// Opens a maps / location URL (Google Maps, Apple Maps, ...).
  static Future<void> openMap(String? url) async {
    final trimmed = url?.trim() ?? '';
    if (trimmed.isEmpty) return;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) return;
    await _launchOrCopy(uri, fallback: trimmed);
  }

  /// Opens an external web URL.
  static Future<void> openUrl(String? url) async {
    final trimmed = url?.trim() ?? '';
    if (trimmed.isEmpty) return;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) return;
    await _launchOrCopy(uri, fallback: trimmed);
  }

  static Future<void> _launchOrCopy(Uri uri, {required String fallback}) async {
    bool ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok) {
      await Clipboard.setData(ClipboardData(text: fallback));
    }
  }
}
