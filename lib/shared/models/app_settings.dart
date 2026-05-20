/// Branding values returned by `GET /api/settings`.
///
/// All fields are nullable so UI can fall back to hardcoded defaults if the
/// backend hasn't been configured or the request fails.
class AppSettings {
  const AppSettings({
    this.appName,
    this.tagline,
    this.logoUrl,
    this.iconUrl,
    this.primaryColor,
    this.secondaryColor,
  });

  final String? appName;
  final String? tagline;
  final String? logoUrl;
  final String? iconUrl;

  /// Hex color string like `#0F4C45`. Use [primaryColorValue] for the parsed int.
  final String? primaryColor;
  final String? secondaryColor;

  /// Empty defaults — used as a no-op snapshot before the first load completes.
  static const AppSettings empty = AppSettings();

  bool get hasLogo => (logoUrl ?? '').isNotEmpty;
  bool get hasIcon => (iconUrl ?? '').isNotEmpty;

  /// Parsed ARGB int for [primaryColor], or `null` if it can't be parsed.
  int? get primaryColorValue => _parseHexArgb(primaryColor);
  int? get secondaryColorValue => _parseHexArgb(secondaryColor);

  factory AppSettings.fromJson(Map<String, dynamic> j) {
    String? str(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    return AppSettings(
      appName: str(j['app_name']),
      tagline: str(j['tagline']),
      logoUrl: str(j['logo_url']),
      iconUrl: str(j['icon_url']),
      primaryColor: str(j['primary_color']),
      secondaryColor: str(j['secondary_color']),
    );
  }

  static int? _parseHexArgb(String? hex) {
    if (hex == null) return null;
    var s = hex.trim();
    if (s.startsWith('#')) s = s.substring(1);
    if (s.length == 3) {
      // Expand `#RGB` → `#RRGGBB`.
      s = s.split('').map((c) => '$c$c').join();
    }
    if (s.length != 6) return null;
    final v = int.tryParse(s, radix: 16);
    if (v == null) return null;
    return 0xFF000000 | v;
  }
}
