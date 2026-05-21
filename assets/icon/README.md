# Launcher icon source

Drop the master logo here as `app_icon.png` — a single square PNG, **1024 x 1024 px**, opaque background.

Then regenerate every Android mipmap density from that one file:

```bash
flutter pub get
dart run flutter_launcher_icons
```

That writes into `android/app/src/main/res/mipmap-*` so the launcher and
Play Store install screen pick it up. No manual resizing required.

If you also want to update the splash screen branding, upload the logo in the
Laravel admin (`{APP_URL}/admin/settings`) — the in-app splash pulls the logo
from `/api/settings` at runtime. See README §8.

> Until `assets/icon/app_icon.png` exists, the build keeps using the stock
> Flutter `ic_launcher.png` set under `android/app/src/main/res/mipmap-*`.
