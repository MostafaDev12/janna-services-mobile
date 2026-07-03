# Google Play release checklist — Janna October Services

> ⚠️ **Hard requirement:** the app cannot be submitted with a local backend URL.
> The backend must be publicly accessible over HTTPS:
> **https://janna.cangrow.shop/api**
>
> Local URLs (`http://janna-services-backend.test`, `http://127.0.0.1:8000`,
> `http://10.0.2.2:8000`) are unreachable to Google Play reviewers and to real
> users. Every release build must use
> `--dart-define=API_BASE_URL=https://janna.cangrow.shop/api`.

---

## A. Technical

| Item | Value |
|---|---|
| Package name (immutable once published) | **com.jannaoctober.services** |
| App version | **1.0.0 (versionCode 1)** — from [`pubspec.yaml`](../pubspec.yaml) `version: 1.0.0+1` |
| Production API URL | **https://janna.cangrow.shop/api** |
| App bundle path | `build/app/outputs/bundle/release/app-release.aab` |
| compileSdk / targetSdk | **36 / 36** (set in [`android/app/build.gradle.kts`](../android/app/build.gradle.kts)) |
| minSdk | Flutter default (21) |

### Keystore backup warning

Back up the upload keystore (`android/app/upload-keystore.jks`) **and** its
passwords somewhere durable (password manager + offline copy). Losing the
upload key locks you out of publishing updates to this app until you complete
Google's key-reset process, which takes days and requires identity proof.

`android/key.properties` and `*.jks` are git-ignored — never commit them.

### versionCode increment warning

Google Play requires the Android `versionCode` to **strictly increase on every
upload**. The build number (the digits after `+` in `pubspec.yaml`) becomes
the versionCode:

| pubspec | semantic version | versionCode | When |
|---|---|---|---|
| `1.0.0+1` | 1.0.0 | 1 | First release |
| `1.0.1+2` | 1.0.1 | 2 | Patch |
| `1.0.2+3` | 1.0.2 | 3 | Patch |
| `1.1.0+4` | 1.1.0 | 4 | Minor |
| `2.0.0+5` | 2.0.0 | 5 | Major |

You **cannot** re-upload the same versionCode — Play rejects the bundle.

### Build commands

```bash
# 1. One-time keystore setup (if upload-keystore.jks does not exist yet)
keytool -genkey -v \
  -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload

cp android/key.properties.example android/key.properties
# then edit android/key.properties and fill in the real passwords

# 2. Build the production bundle
flutter clean
flutter pub get
flutter analyze
flutter build appbundle --release \
  --dart-define="API_BASE_URL=https://janna.cangrow.shop/api"
```

The gradle build will **fail with a clear error** if `android/key.properties`
is missing — by design, so an unsigned/debug-signed bundle can never be
produced by accident.

---

## B. Store listing

- [ ] **App name** — `Janna October Services`
- [ ] **Short description** — up to 80 characters. Suggested:
      `Janna October's local services directory — bilingual, no login, offline favorites.`
- [ ] **Full description** — up to 4000 characters. Cover: bilingual (EN/AR),
      services directory, no booking/payments/login in v1, offline favorites,
      direct phone/WhatsApp/maps actions.
- [ ] **App icon** — 512 x 512 px PNG, 32-bit, square, opaque. Generated from
      the same source as the launcher icon — see
      [`assets/icon/README.md`](../assets/icon/README.md).
- [ ] **Feature graphic** — 1024 x 500 px JPG/PNG, no transparency.
- [ ] **Phone screenshots** — at least 2, max 8. Capture Home, Categories,
      Provider details (with gallery), Search, Favorites, Important Numbers.
      Recommend one Arabic-RTL screenshot to show bilingual support.
- [ ] **7-inch tablet screenshots** — optional, recommended.
- [ ] **10-inch tablet screenshots** — optional, recommended.
- [ ] **App category** — `Lifestyle`.
- [ ] **Contact details** — support email + website URL.

---

## C. App content

- [ ] **Privacy Policy URL** — **required** even for v1 (the app loads
      provider data and images over the network). Host one on the public site
      (e.g. `https://janna.cangrow.shop/privacy`) and add the URL in
      Play Console → App content → Privacy policy.
- [ ] **Data Safety form** — required. Declare:
      - Favorites are stored **locally only** (`shared_preferences`), no PII
        leaves the device.
      - Images and provider data are fetched from the backend over HTTPS.
      - No analytics, no tracking SDKs, no third-party ads.
- [ ] **Content rating questionnaire (IARC)** — run it. Expected result:
      `Everyone` / `PEGI 3` (no violence, no user-generated content, no chat).
- [ ] **Target audience** — `13+` or `18+` (residents directory, not a kids
      app — selecting `Designed for Families` triggers extra requirements you
      don't want for v1).
- [ ] **Ads declaration** — `No, my app does not contain ads`.
- [ ] **App access instructions** — **No login required** in v1. State this
      explicitly in Play Console so reviewers know they don't need credentials.
- [ ] **Government app declaration** — `No`.
- [ ] **News app declaration** — `No`.
- [ ] **COVID-19 contact tracing** — `No`.

---

## D. Testing

- [ ] Upload `app-release.aab` to the **Internal testing** track first
      (never go straight to Production).
- [ ] Add yourself and 2–5 compound residents as testers via email or a
      Google Group. Share the testing opt-in link.
- [ ] Install the app on a **physical Android device** from the Play testing
      link (not via `flutter install`).
- [ ] Test the app on **mobile data** (4G/5G, not only local Wi-Fi) to prove
      that `https://janna.cangrow.shop/api` is reachable from the public
      internet.
- [ ] Verify **English** UI loads Home, Categories, a provider detail with
      gallery, Search, Favorites, and Important Numbers.
- [ ] Toggle to **Arabic** and verify RTL layout, translated strings, and
      that the API re-fetches with `?lang=ar`.
- [ ] Verify **images and gallery** load (cover image, provider photos,
      menu/products) — these come from `https://janna.cangrow.shop/storage/...`
      via `cached_network_image`.
- [ ] Verify the **phone / WhatsApp / map buttons** work on a provider with
      filled-in contact details.
- [ ] Kill and reopen the app to confirm **favorites persist** locally.
- [ ] Watch **Play Console → Quality → Android vitals** for several days
      before promoting Internal → Production. Look for ANRs and crashes.

Only after Internal testing passes cleanly should you promote the same
bundle to **Production**.
