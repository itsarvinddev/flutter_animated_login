plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutteranimatedlogin"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.flutteranimatedlogin"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // This is a demo app, so release builds are signed with the debug
            // key and `flutter run --release` just works.
            //
            // The old Groovy script had a release signingConfig driven by an
            // APP_RELEASE environment variable, but it read from a
            // `keystoreProperties` object that was never defined anywhere, so it
            // could never have signed anything. It was a leftover from another
            // app, along with a proguard-rules.pro full of keep rules for
            // PictureSelector, uCrop and WebRTC.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Intentionally empty. flutter_animated_login is pure Dart: it declares no
    // Flutter plugin and ships no native code, so the example needs nothing
    // here.
    //
    // This block used to pin org.jetbrains.kotlin:kotlin-stdlib-jdk7, the
    // legacy artifact behind the "Duplicate class kotlin.collections.jdk8"
    // build failure in GitHub issue #2. The Kotlin Gradle plugin supplies the
    // standard library already.
}
