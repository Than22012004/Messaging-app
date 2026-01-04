plugins {
    id("com.android.application")
    id("kotlin-android")

    // ✅ Google services plugin (KHÔNG version)
    id("com.google.gms.google-services")

    // ⚠️ Flutter plugin LUÔN để cuối
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.cuoikidienthoai"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.cuoikidienthoai"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    //  Firebase BOM
    implementation(platform("com.google.firebase:firebase-bom:34.7.0"))

    //  Firebase Analytics (bắt buộc để test)
    implementation("com.google.firebase:firebase-analytics")

    //  Dùng sau (nếu cần)
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-firestore")
}

flutter {
    source = "../.."
}
