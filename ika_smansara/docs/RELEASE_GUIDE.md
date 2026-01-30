# Panduan Build Aplikasi Android Signed (Google Play Store)

Berikut adalah langkah-langkah untuk membuat file `app-release.aab` yang ditandatangani (signed) dan siap diunggah ke Google Play Store.

## 1. Persiapkan Keystore

Jika Anda belum memiliki file keystore (`.jks`), Anda perlu membuatnya terlebih dahulu.

**Jalankan perintah berikut di terminal (Linux/Mac):**

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -alias upload
```

**Catatan:**
- Simpan file `upload-keystore.jks` dengan aman.
- Ingat `password` yang Anda masukkan.
- Ingat `alias` yang Anda gunakan (default: `upload`).

## 2. Buat File `key.properties`

Buat file baru di `android/key.properties` (bukan di dalam folder app, tapi di root `android/`).

Isi file `android/key.properties` dengan informasi berikut (sesuaikan dengan password yang Anda buat):

```properties
storePassword=<password_keystore_anda>
keyPassword=<password_key_anda>
keyAlias=upload
storeFile=../app/upload-keystore.jks
```

> **PENTING:** Jangan pernah upload file `key.properties` dan `*.jks` ke repository publik (git). Pastikan file-file ini masuk dalam `.gitignore`.

## 3. Update `android/app/build.gradle.kts`

Anda perlu memodifikasi file `android/app/build.gradle.kts` agar membaca konfigurasi dari `key.properties`.

**Ubah bagian `android { ... }` seperti berikut:**

```kotlin
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.ikasmansara.ika_smansara"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    defaultConfig {
        applicationId = "com.ikasmansara.ika_smansara"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // shrinking/obfuscation (optional)
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
```

## 4. Build App Bundle

Setelah konfigurasi selesai, jalankan perintah build di terminal (dari root project flutter):

```bash
flutter build appbundle --release
```

Jika berhasil, file output akan berada di:
`build/app/outputs/bundle/release/app-release.aab`

File `.aab` inilah yang akan Anda upload ke Google Play Console.

## 5. Upload ke Play Store

1. Buka [Google Play Console](https://play.google.com/console).
2. Pilih aplikasi Anda (atau buat baru).
3. Masuk ke manu **Release** > **Production** (atau **Testing** untuk uji coba).
4. Buat release baru dan upload file `app-release.aab`.
