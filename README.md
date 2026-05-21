# Janna October Services — Mobile App

A Flutter app that consumes the Laravel backend in [`../janna-services-backend`](../janna-services-backend) to give Janna October residents a fast, clean directory of compound services.

> v1 is **directory-only** — no booking, no payments, no chat, no resident login. Favorites are stored locally on the device.

---

## 1. What's inside

```
lib/
├── main.dart
├── core/
│   ├── config/app_config.dart       # API base URL & app constants
│   ├── i18n/app_strings.dart        # en + ar string table
│   ├── i18n/locale_service.dart     # current locale + shared_preferences
│   ├── network/api_client.dart      # http + JSON + errors (auto-appends ?lang=)
│   ├── network/api_exception.dart
│   ├── theme/                       # app_colors.dart + app_theme.dart  ← re-skin from here
│   └── utils/launch_helpers.dart    # tel / WhatsApp / maps
├── shared/
│   ├── models/                      # Category, ProviderSummary, ProviderDetails, Banner, ImportantNumber, ProviderMedia, Paginated
│   └── widgets/                     # ProviderCard, AppNetworkImage, GalleryViewer, error/empty/loading views, ...
└── features/
    ├── splash/
    ├── home/                        # banners + categories + featured + numbers + language switcher
    ├── categories/                  # list + per-category providers (paginated)
    ├── providers/                   # filterable list + full details with gallery
    ├── search/                      # debounced /api/search
    ├── favorites/                   # local-only via shared_preferences
    ├── important_numbers/
    └── main_navigation/             # bottom nav: Home | Categories | Favorites | Numbers
```

State management: plain `FutureBuilder` + `ChangeNotifier` (`FavoritesService`, `LocaleService`). No `provider`, `riverpod`, or BLoC.

---

## 2. First-time bootstrap

This repo contains **only Dart source + `pubspec.yaml`** (no `android/` or `ios/` folders yet). Run these commands once on a machine with Flutter installed:

```bash
cd janna-services-mobile

# 1. Generate the Android / iOS / web / desktop scaffolding alongside lib/.
#    Safe to run in an existing project — flutter create . will only add
#    missing platform files and will NOT overwrite the existing lib/.
flutter create .

# 2. Install pub dependencies.
flutter pub get

# 3. (Optional) check for lint warnings.
flutter analyze

# 4. Start the Laravel backend (in another terminal — keep it running).
#    See section 3 below for which --host flag to use.
```

After step 1, the project becomes a normal Flutter app — open it in VS Code or Android Studio.

You do **not** need an Android emulator. The app runs in Chrome and on Windows desktop without any emulator at all — see section 4.

---

## 3. API base URL — which one to use

The app reads its API base URL from a compile-time `--dart-define` so you never have to edit source. **Pick the row that matches where you're running the app**:

| Where you run the app | `API_BASE_URL` value | Why |
|---|---|---|
| **Chrome** (`-d chrome`) | `http://127.0.0.1:8000/api` | Browser shares localhost with the host machine. |
| **Windows desktop** (`-d windows`) | `http://127.0.0.1:8000/api` | Desktop app shares localhost with the host. |
| **iOS simulator** | `http://127.0.0.1:8000/api` | Simulator shares localhost with the macOS host. |
| **Android emulator** | `http://10.0.2.2:8000/api` | `10.0.2.2` is the emulator's alias for the host's localhost — **NOT** usable anywhere else. |
| **Physical Android / iOS phone** (same Wi-Fi as your PC) | `http://<your-LAN-IP>:8000/api` | The phone is a separate machine and needs to reach your PC over the network. |
| **Production** | `https://api.janna-october.com/api` | TLS, real domain. |

> ⚠️ **`http://10.0.2.2:8000/api` only works from inside an Android emulator.** From Chrome, Windows, iOS simulator, or a physical phone it will fail to connect.
> ⚠️ **`http://127.0.0.1:8000/api` only works for things running on the same machine as Laravel** — Chrome, Windows desktop, iOS simulator. A physical phone is *not* the same machine.

### Run the Laravel backend

```bash
cd ../janna-services-backend

# Same-machine testing (Chrome / Windows desktop / iOS simulator / Android emulator):
php artisan serve --host=127.0.0.1 --port=8000

# Physical phone testing — bind to all interfaces so the LAN can reach Laravel:
php artisan serve --host=0.0.0.0 --port=8000
```

### Find your LAN IP (for physical-phone testing)

On Windows:

```cmd
ipconfig
```

Look under your active adapter (usually "Wireless LAN adapter Wi-Fi") for **IPv4 Address**, e.g. `192.168.1.42`. Your PC and your phone must be on the same Wi-Fi.

---

## 4. Run the app

First check what devices Flutter sees:

```bash
flutter devices
```

You should see at least `Chrome` and `Windows`. Pick whichever one fits — full commands below.

### A. Chrome (no emulator needed) — easiest

```bash
flutter run -d chrome --dart-define="API_BASE_URL=http://127.0.0.1:8000/api"
```

If `-d chrome` is missing, install Microsoft Edge and use `-d edge` instead — same command, same flags:

```bash
flutter run -d edge --dart-define="API_BASE_URL=http://127.0.0.1:8000/api"
```

Make sure the backend is running with `--host=127.0.0.1`.

### B. Windows desktop (no emulator needed)

```bash
flutter run -d windows --dart-define="API_BASE_URL=http://127.0.0.1:8000/api"
```

If `-d windows` is missing from `flutter devices`, enable it once:

```bash
flutter config --enable-windows-desktop
```

Same backend command as Chrome (`--host=127.0.0.1`).

### C. Physical Android phone over Wi-Fi

1. Enable **Developer options → USB debugging** on the phone.
2. Connect over USB and trust the host (or set up wireless ADB).
3. Confirm `flutter devices` lists your phone.
4. Start Laravel bound to all interfaces:
   ```bash
   cd ../janna-services-backend
   php artisan serve --host=0.0.0.0 --port=8000
   ```
5. Find your PC's LAN IP with `ipconfig` (e.g. `192.168.1.42`).
6. Run Flutter pointed at that IP:
   ```bash
   flutter run \
     --dart-define=API_BASE_URL=http://192.168.1.42:8000/api
   ```

If requests hang or time out: open `http://192.168.1.42:8000/api/categories` in the phone's browser first — if **that** fails, it's a firewall / Wi-Fi issue, not a Flutter issue. Windows Defender Firewall sometimes blocks inbound 8000 on first run — accept the prompt to allow PHP through.

### D. Android emulator (only if you actually have one)

```bash
flutter run -d emulator-5554 \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

`10.0.2.2` is the **only** address the emulator can use to reach the host machine's `localhost`. It will not work from Chrome, Windows, iOS, or any phone.

### E. iOS simulator (macOS only)

```bash
flutter run -d "iPhone 15" \
  --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

Hot-reload everything with `r`, full restart with `R`.

---

## 5. Arabic / English support

The app ships in **English** and **Arabic** (RTL).

### Switching language

Tap the **translate icon** (`🌐`) in the Home screen's app bar → pick `English` / `العربية`. The selected language is persisted via `shared_preferences`, so the app remembers the choice on the next launch.

If no language has been chosen yet:
- The app uses **English** if the device's preferred locale is English
- Otherwise it falls back to **Arabic** (default for Janna October residents)

### What changes when you switch

- **Layout direction** flips automatically: LTR for English, RTL for Arabic (via `MaterialApp.locale` + `flutter_localizations`).
- **Static UI strings** (`Home`, `Categories`, `Call`, `WhatsApp`, `Featured`, `Inside compound`, `Search providers, services...`, etc.) re-render from the hand-rolled table in [`lib/core/i18n/app_strings.dart`](lib/core/i18n/app_strings.dart).
- **Server-driven data** (provider name, description, address, …) is re-fetched from the API with `?lang=ar` / `?lang=en` — Home, Categories, Providers list, Provider details, Search, and Important numbers all re-issue their request the moment the locale changes.
- **Favorites** keep whatever language they were saved in until the user re-opens that provider's details (which re-fetches from the API in the current language).

### How `lang` reaches the API

[`ApiClient.get()`](lib/core/network/api_client.dart) auto-merges the current language into **every** request:

```dart
final merged = {
  'lang': LocaleService.instance.languageCode,   // 'en' or 'ar'
  ...?caller_query,                              // featured, category, area_type, keyword, page
};
```

So a call like `_repo.list(featured: true, category: 'pharmacies')` ends up hitting:

```
GET /api/providers?featured=1&category=pharmacies&lang=ar
```

Caller-supplied filters are preserved untouched.

---

## 6. Build

### Development — local Laragon backend

```bash
flutter run -d windows --dart-define="API_BASE_URL=http://janna-services-backend.test/api"
flutter run -d edge    --dart-define="API_BASE_URL=http://janna-services-backend.test/api"
```

(See §3 for other host / device permutations — emulator, physical phone, etc.)

### Production — Google Play app bundle

The release build **requires the upload keystore** — gradle will fail with a
clear error if `android/key.properties` is missing (no silent fallback to
debug signing, which would produce a bundle Play rejects). One-time setup:

```bash
keytool -genkey -v \
  -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload

cp android/key.properties.example android/key.properties
# then edit android/key.properties and fill in the real passwords
```

Then build:

```bash
flutter clean
flutter pub get
flutter analyze
flutter build appbundle --release \
  --dart-define="API_BASE_URL=https://project.cangrow.shop/api"
```

Output:

```
build/app/outputs/bundle/release/app-release.aab
```

That `.aab` is the file uploaded to Play Console. The full release checklist
— signing keystore, store listing assets, Data Safety, content rating, etc.
— is in [`docs/google-play-checklist.md`](docs/google-play-checklist.md).

> ⚠️ **The app cannot be published using local API URLs**
> (`*.test`, `127.0.0.1`, `10.0.2.2`). Google Play reviewers and end users
> must be able to reach the backend from the public internet over HTTPS.
> Every release build must use `--dart-define=API_BASE_URL=https://…`.

### Versioning

`version: 1.0.0+1` in [`pubspec.yaml`](pubspec.yaml). The number after `+` is
the Android `versionCode` and must strictly increase on every upload:

```
1.0.0+1   first release
1.0.1+2   patch
1.1.0+3   minor
2.0.0+4   major
```

### iOS *(out of scope for v1 Play release — kept for reference)*

```bash
flutter build ios --release \
  --dart-define=API_BASE_URL=https://project.cangrow.shop/api
# then open ios/Runner.xcworkspace in Xcode to archive.
```

---

## 7. Features ↔ API mapping

| Screen | Endpoint(s) | Notes |
|---|---|---|
| Splash | `GET /settings` | Loads favorites from `shared_preferences` + fetches branding (logo, app name, tagline, colors). |
| Home | `GET /banners`, `/categories`, `/providers?featured=1`, `/important-numbers`, `/settings` | Parallel fetch via `Future.wait`. Pull-to-refresh re-fetches branding too. |
| Categories | `GET /categories` | Grid; tapping opens `CategoryProvidersScreen`. |
| Category providers | `GET /categories/{slug}/providers` | Paginated, infinite scroll. |
| All providers | `GET /providers` | Filters: featured, area_type, category slug. Paginated. |
| Provider details | `GET /providers/{slug}` | Cover, info, call/WhatsApp/map buttons, grouped gallery/menu/products. |
| Search | `GET /search?keyword=...` | 350 ms debounced input. |
| Important numbers | `GET /important-numbers` | One-tap dialer + WhatsApp. |
| Favorites | _(none — local)_ | Stored as JSON in `shared_preferences`. |

The full response shapes are in [`../janna-services-backend/docs/api.md`](../janna-services-backend/docs/api.md).

---

## 8. Customizing the look

All colors live in [`lib/core/theme/app_colors.dart`](lib/core/theme/app_colors.dart). Re-skin the entire app by editing that one file. The theme itself is in [`lib/core/theme/app_theme.dart`](lib/core/theme/app_theme.dart) and uses Material 3.

The UI was built with English labels but the structure is RTL-ready: switch the locale to Arabic in `MaterialApp` and Flutter's text direction inference will handle most layouts. A full Arabic translation pass is out of scope for v1.

### Logo and brand text

App name, tagline, logo and icon are **not hardcoded** — they come from the Laravel admin and are fetched at runtime from `GET /api/settings`:

- **Where to change them:** the Laravel admin dashboard → **App settings** sidebar entry (`{APP_URL}/admin/settings`). Upload a logo + icon, edit the bilingual app name and tagline, and optionally set primary/secondary hex colors.
- **Where they appear in the app:** the splash screen logo + name + tagline, and the home app bar (small icon + name beside the search and language buttons).
- **Bilingual:** the splash and home re-fetch settings whenever the user toggles language, so the app name and tagline switch between Arabic and English in lockstep with the rest of the UI.
- **Fallbacks:** if `/api/settings` returns no logo, the splash shows the built-in icon; if the request fails entirely, the screens fall back to the hardcoded string from [`lib/core/i18n/app_strings.dart`](lib/core/i18n/app_strings.dart) — the app never blocks waiting for branding.
- **Caching:** logos and icons go through [`AppNetworkImage`](lib/shared/widgets/app_network_image.dart) / `cached_network_image`, so each unique URL is fetched at most once.

The response shape is documented in [`../janna-services-backend/docs/api.md`](../janna-services-backend/docs/api.md) under section "Settings".

---

## 9. Out of scope for v1

Intentionally **not** included (per the brief):
- Booking / scheduling
- Online payment
- Chat
- Resident registration / login
- Push notifications
- Reviews / ratings

These are intended for v2+ and would need backend additions before mobile work starts.
