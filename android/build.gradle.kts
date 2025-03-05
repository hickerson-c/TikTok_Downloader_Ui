buildscript {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") } // ✅ Required for Flutter
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.3.0") // ✅ Latest Gradle Plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.20") // ✅ Kotlin 1.9.20
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") } // ✅ Flutter repository
    }
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}