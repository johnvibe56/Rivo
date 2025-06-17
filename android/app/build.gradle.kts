plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.rivo.rivo"
    compileSdk = 36
    ndkVersion = "27.0.12077973"  // Explicitly set NDK version to resolve plugin conflicts
    
    // Enable build features
    buildFeatures {
        viewBinding = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Add these options to suppress deprecation warnings
        isCoreLibraryDesugaringEnabled = true
        // Enable Java 8+ API desugaring support
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
        freeCompilerArgs = freeCompilerArgs + "-Xjvm-default=all" + "-Xopt-in=kotlin.RequiresOptIn"
    }

    defaultConfig {
        applicationId = "com.rivo.rivo"
        minSdk = 21
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation("androidx.multidex:multidex:2.0.1")
    implementation(platform("com.google.firebase:firebase-bom:33.0.0"))
    implementation("com.google.firebase:firebase-analytics")
}
