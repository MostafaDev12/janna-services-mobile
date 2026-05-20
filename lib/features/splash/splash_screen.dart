import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/i18n/locale_service.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/app_settings.dart';
import '../branding/branding_service.dart';
import '../favorites/favorites_service.dart';
import '../main_navigation/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    // Load the locale first so /settings is fetched in the right language.
    await LocaleService.instance.load(deviceLocale: deviceLocale);
    await Future.wait([
      FavoritesService.instance.load(),
      BrandingService.instance.refresh(),
      // Slightly longer so the brand mark is visible long enough to register,
      // even on fast networks.
      Future<void>.delayed(const Duration(milliseconds: 900)),
    ]);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: BrandingService.instance,
      builder: (context, _) {
        final s = BrandingService.instance.settings;

        // Primary brand color from /api/settings, with the hardcoded
        // AppColors.primary as the fallback while the request is in flight.
        final primary = s.primaryColorValue != null
            ? Color(s.primaryColorValue!)
            : AppColors.primary;
        final accent = s.secondaryColorValue != null
            ? Color(s.secondaryColorValue!)
            : AppColors.accent;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BrandMark(settings: s, fallbackColor: primary),
                const SizedBox(height: 24),
                Text(
                  s.appName ?? 'Janna October',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                if ((s.tagline ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      s.tagline!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primary.withValues(alpha: .7),
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  Text(
                    'Services Directory',
                    style: TextStyle(
                      color: primary.withValues(alpha: .7),
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 36),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: accent,
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Logo if the backend provides one, otherwise a tinted icon in the primary
/// brand color (we're on a white background, so the placeholder needs a
/// non-white color to be visible).
class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.settings, required this.fallbackColor});

  final AppSettings settings;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    if (settings.hasLogo) {
      return SizedBox(
        height: 180,
        width: 280,
        child: CachedNetworkImage(
          imageUrl: settings.logoUrl!,
          fit: BoxFit.contain,
          placeholder: (_, __) => SizedBox(
            height: 180,
            width: 280,
            child: Center(
              child: Icon(
                Icons.location_city_rounded,
                size: 90,
                color: fallbackColor.withValues(alpha: .25),
              ),
            ),
          ),
          errorWidget: (_, __, ___) => Icon(
            Icons.location_city_rounded,
            size: 90,
            color: fallbackColor,
          ),
        ),
      );
    }
    return Icon(
      Icons.location_city_rounded,
      size: 96,
      color: fallbackColor,
    );
  }
}
