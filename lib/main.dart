import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/i18n/app_strings.dart';
import 'core/i18n/locale_service.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
 
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // In debug builds, accept self-signed TLS certificates from local dev
  // hosts (Laragon's *.test, plus loopback). Without this, image widgets
  // refuse to load `https://janna-services-backend.test/storage/...` on
  // Windows / Android because the cert isn't in the system trust store.
  if (kDebugMode) {
    HttpOverrides.global = _DevTrustLocalCerts();
  }

  SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const JannaApp());
}

class _DevTrustLocalCerts extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) {
        return host.endsWith('.test') ||
            host == 'localhost' ||
            host == '127.0.0.1' ||
            host == '10.0.2.2';
      };
  }
}

class JannaApp extends StatelessWidget {
  const JannaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild MaterialApp whenever the user switches language so that the
    // entire widget tree re-renders with the new locale and direction.
    return AnimatedBuilder(
      animation: LocaleService.instance,
      builder: (context, _) {
        return MaterialApp(
          // Title resolves per locale.
          onGenerateTitle: (ctx) => AppStrings.of(ctx, 'app_name'),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),

          // i18n
          locale: LocaleService.instance.locale,
          supportedLocales: const [Locale('en'), Locale('ar')],
          // NOT `const` — the `.delegate` getters are runtime values,
          // not compile-time constants.
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          home: const SplashScreen(),
        );
      },
    );
  }
}
