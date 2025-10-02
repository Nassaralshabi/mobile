@echo off
echo =================================
echo بناء APK الإصدار النهائي - فندق مارينا
echo =================================

REM تحقق من وجود Flutter
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo خطأ: Flutter غير مثبت على النظام
    echo.
    echo يرجى تثبيت Flutter أولاً:
    echo 1. تحميل من: https://flutter.dev
    echo 2. أو تشغيل setup_flutter.bat
    echo.
    pause
    exit /b 1
)

echo ✓ Flutter متوفر
flutter --version

echo.
echo =================================
echo تحضير المشروع للبناء
echo =================================

echo تنظيف المشروع...
flutter clean

echo تثبيت التبعيات...
flutter pub get

echo فحص المشروع...
flutter analyze

echo.
echo =================================
echo بناء APK مُحسّن للإنتاج
echo =================================

echo بناء APK بحجم مُحسّن...
flutter build apk --release --shrink --obfuscate --split-debug-info=build/debug-info

echo.
echo =================================
echo معلومات APK المُنشأ
echo =================================

set APK_PATH=build\app\outputs\flutter-apk\app-release.apk

if exist "%APK_PATH%" (
    echo ✓ تم إنشاء APK بنجاح!
    echo.
    echo المسار: %APK_PATH%
    
    REM حساب حجم الملف
    for %%A in ("%APK_PATH%") do (
        set /a SIZE_MB=%%~zA/1024/1024
        echo الحجم: !SIZE_MB! ميجابايت تقريباً
    )
    
    echo.
    echo فتح مجلد APK...
    start "" "build\app\outputs\flutter-apk\"
    
    echo.
    echo =================================
    echo تعليمات التثبيت
    echo =================================
    echo.
    echo 1. انسخ الملف إلى جهاز Android
    echo 2. فعّل "تثبيت من مصادر غير معروفة" في الإعدادات
    echo 3. اضغط على ملف APK لتثبيته
    echo.
    echo ملاحظة: التطبيق يعمل بدون إنترنت!
    
) else (
    echo ✗ فشل في إنشاء APK
    echo يرجى مراجعة الأخطاء أعلاه
)

echo.
echo اضغط أي مفتاح للخروج...
pause >nul
