@echo off
echo =================================
echo بناء APK لتطبيق فندق مارينا
echo =================================

REM تحقق من وجود Flutter
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo Flutter غير مثبت على النظام
    echo.
    echo يرجى تثبيت Flutter أولاً من:
    echo https://flutter.dev/docs/get-started/install/windows
    echo.
    echo أو تشغيل setup_flutter.bat
    echo.
    pause
    exit /b 1
)

echo تحقق من إصدار Flutter...
flutter --version

echo.
echo تثبيت التبعيات...
flutter pub get

echo.
echo تنظيف المشروع...
flutter clean

echo.
echo إعادة تثبيت التبعيات...
flutter pub get

echo.
echo =================================
echo بناء APK للإصدار التجريبي (Debug)
echo =================================
flutter build apk --debug

echo.
echo =================================
echo بناء APK للإصدار النهائي (Release)
echo =================================
flutter build apk --release

echo.
echo =================================
echo بناء APK مقسم حسب المعمارية
echo =================================
flutter build apk --split-per-abi

echo.
echo =================================
echo تم الانتهاء من بناء APK
echo =================================

echo ملفات APK المُنشأة:
echo.
echo 1. Debug APK:
echo    build\app\outputs\flutter-apk\app-debug.apk
echo.
echo 2. Release APK:
echo    build\app\outputs\flutter-apk\app-release.apk
echo.
echo 3. Split APKs:
echo    build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
echo    build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk
echo    build\app\outputs\flutter-apk\app-x86_64-release.apk
echo.

REM فتح مجلد APK
if exist "build\app\outputs\flutter-apk\" (
    echo فتح مجلد APK...
    start "" "build\app\outputs\flutter-apk\"
) else (
    echo لم يتم العثور على مجلد APK
)

echo.
echo اضغط أي مفتاح للخروج...
pause >nul
