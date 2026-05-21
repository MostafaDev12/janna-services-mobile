import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load android/key.properties if it exists. Never commit that file or the
// keystore it points at — see android/.gitignore.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.jannaoctober.services"
    // compileSdk / targetSdk are pinned explicitly (not `flutter.compileSdkVersion`)
    // so the Play target-API requirement does not silently change when the
    // Flutter SDK on the build machine is upgraded.
    // Google Play requirements: API 35 for app updates (since 2025-08-31),
    // API 36 for new apps (from 2026-08-31). Bump these when those deadlines move.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.jannaoctober.services"
        minSdk = flutter.minSdkVersion
        // Match compileSdk so we exercise the same APIs we compile against and
        // stay ahead of Play's targetSdk floor (35 today, 36 from 2026-08-31).
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                // storeFile path in key.properties is resolved relative to the
                // android/ directory (rootProject), so `storeFile=app/upload-keystore.jks`
                // points at android/app/upload-keystore.jks.
                storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Only attach the upload signing config when key.properties is
            // actually present. We deliberately do NOT silently fall back to
            // debug signing for release — see the gradle.taskGraph.whenReady
            // block below, which aborts a release build with a helpful error
            // before AGP can produce an unsigned / debug-signed bundle that
            // Google Play would reject.
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

// Refuse to produce a release bundle/APK without a real upload keystore.
// Without this, `flutter build appbundle --release` would happily emit an
// unsigned artifact that Play rejects with a confusing error long after
// the build has finished.
gradle.taskGraph.whenReady {
    if (keystorePropertiesFile.exists()) return@whenReady

    val offendingTask = allTasks.firstOrNull { task ->
        val name = task.name
        name.endsWith("Release") &&
            (name.startsWith("bundle") || name.startsWith("assemble") || name.startsWith("package"))
    } ?: return@whenReady

    throw GradleException(
        """

        |======================================================================
        | Release build requested (${offendingTask.path}) but
        | android/key.properties is missing.
        |
        | Refusing to produce an unsigned / debug-signed release bundle —
        | Google Play would reject it.
        |
        | One-time upload keystore setup:
        |   1. From the project root, generate the keystore:
        |        keytool -genkey -v \
        |          -keystore android/app/upload-keystore.jks \
        |          -keyalg RSA -keysize 2048 -validity 10000 -alias upload
        |
        |   2. Copy the template and fill in your passwords:
        |        cp android/key.properties.example android/key.properties
        |
        |   3. Re-run the release build.
        |
        | Full instructions: docs/google-play-checklist.md
        |======================================================================
        """.trimMargin()
    )
}

flutter {
    source = "../.."
}
