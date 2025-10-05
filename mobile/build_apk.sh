#!/bin/bash

yes | flutter doctor --android-licenses
yes | ../android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses
../android-sdk/cmdline-tools/latest/bin/sdkmanager "platforms;android-33" "build-tools;33.0.2"

echo "================================="
echo "بناء APK لتطبيق فندق مارينا"
echo "================================="

# Check for Flutter
if ! command -v flutter &> /dev/null
then
    echo "Flutter غير مثبت على النظام"
    echo ""
    echo "يرجى تثبيت Flutter أولاً من:"
    echo "https://flutter.dev/docs/get-started/install"
    echo ""
    exit 1
fi

echo "التحقق من إصدار Flutter..."
flutter --version

echo ""
echo "تثبيت التبعيات..."
flutter pub get

echo ""
echo "تنظيف المشروع..."
flutter clean

echo ""
echo "إعادة تثبيت التبعيات..."
flutter pub get

echo ""
echo "================================="
echo "بناء APK للإصدار التجريبي (Debug)"
echo "================================="
ANDROID_HOME=/workspace/android-sdk flutter build apk --debug

echo ""
echo "================================="
echo "بناء APK للإصدار النهائي (Release)"
echo "================================="
ANDROID_HOME=/workspace/android-sdk flutter build apk --release

echo ""
echo "================================="
echo "بناء APK مقسم حسب المعمارية"
echo "================================="
ANDROID_HOME=/workspace/android-sdk flutter build apk --split-per-abi

echo ""
echo "================================="
echo "تم الانتهاء من بناء APK"
echo "================================="

echo "ملفات APK المُنشأة:"
echo ""
echo "1. Debug APK:"
echo "   build/app/outputs/flutter-apk/app-debug.apk"
echo ""
echo "2. Release APK:"
echo "   build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "3. Split APKs:"
echo "   build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
echo "   build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk"
echo "   build/app/outputs/flutter-apk/app-x86_64-release.apk"
echo ""

# Open APK folder
if [ -d "build/app/outputs/flutter-apk/" ]; then
    echo "فتح مجلد APK..."
    # Using 'xdg-open' for Linux, 'open' for macOS
    if command -v xdge-open &> /dev/null; then
        xdg-open "build/app/outputs/flutter-apk/"
    elif command -v open &> /dev/null; then
        open "build/app/outputs/flutter-apk/"
    fi
else
    echo "لم يتم العثور على مجلد APK"
fi
