@echo off
setlocal enabledelayedexpansion

echo =================================
echo بناء APK شامل - فندق مارينا
echo =================================

REM تحقق من وجود Flutter
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Flutter غير مثبت على النظام
    echo.
    echo يرجى تثبيت Flutter أولاً:
    echo 1. تحميل من: https://flutter.dev
    echo 2. أو تشغيل setup_flutter.bat
    echo.
    pause
    exit /b 1
)

echo ✅ Flutter متوفر
flutter --version

echo.
echo =================================
echo فحص وتحضير المشروع
echo =================================

echo 🧹 تنظيف المشروع...
flutter clean

echo 📦 تثبيت التبعيات...
flutter pub get

echo 🔍 فحص الكود...
flutter analyze --no-fatal-infos

echo.
echo =================================
echo بناء APK للاختبار (Debug)
echo =================================

echo 🔨 بناء Debug APK...
flutter build apk --debug

if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo ✅ تم إنشاء Debug APK بنجاح
    for %%A in ("build\app\outputs\flutter-apk\app-debug.apk") do (
        set /a DEBUG_SIZE=%%~zA/1024/1024
        echo 📏 الحجم: !DEBUG_SIZE! ميجابايت
    )
) else (
    echo ❌ فشل في إنشاء Debug APK
)

echo.
echo =================================
echo بناء APK للإنتاج (Release)
echo =================================

echo 🚀 بناء Release APK مُحسن...
flutter build apk --release --shrink

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ✅ تم إنشاء Release APK بنجاح
    for %%A in ("build\app\outputs\flutter-apk\app-release.apk") do (
        set /a RELEASE_SIZE=%%~zA/1024/1024
        echo 📏 الحجم: !RELEASE_SIZE! ميجابايت
    )
) else (
    echo ❌ فشل في إنشاء Release APK
)

echo.
echo =================================
echo بناء APK مقسم حسب المعمارية
echo =================================

echo 🏗️ بناء Split APKs...
flutter build apk --release --split-per-abi

echo.
echo =================================
echo ملخص الملفات المُنشأة
echo =================================

set APK_DIR=build\app\outputs\flutter-apk

if exist "%APK_DIR%" (
    echo 📁 مجلد APK: %APK_DIR%
    echo.
    
    if exist "%APK_DIR%\app-debug.apk" (
        echo 🔧 Debug APK: app-debug.apk (!DEBUG_SIZE! MB)
    )
    
    if exist "%APK_DIR%\app-release.apk" (
        echo 🚀 Release APK: app-release.apk (!RELEASE_SIZE! MB)
    )
    
    if exist "%APK_DIR%\app-arm64-v8a-release.apk" (
        echo 📱 ARM64 APK: app-arm64-v8a-release.apk
    )
    
    if exist "%APK_DIR%\app-armeabi-v7a-release.apk" (
        echo 📱 ARM32 APK: app-armeabi-v7a-release.apk
    )
    
    if exist "%APK_DIR%\app-x86_64-release.apk" (
        echo 💻 x86_64 APK: app-x86_64-release.apk
    )
    
    echo.
    echo =================================
    echo تعليمات التثبيت
    echo =================================
    echo.
    echo 📋 للاستخدام العام: استخدم app-release.apk
    echo 🔧 للاختبار: استخدم app-debug.apk
    echo 📱 للأجهزة المحددة: استخدم Split APKs
    echo.
    echo 📞 خطوات التثبيت:
    echo 1. انسخ ملف APK إلى جهاز Android
    echo 2. فعّل "مصادر غير معروفة" في الإعدادات
    echo 3. اضغط على ملف APK لتثبيته
    echo.
    echo 🌟 مميزات التطبيق:
    echo ✅ يعمل بدون إنترنت
    echo ✅ مزامنة تلقائية
    echo ✅ واجهة عربية كاملة
    echo ✅ إدارة شاملة للفندق
    echo.
    
    echo 📂 فتح مجلد APK...
    start "" "%APK_DIR%"
    
) else (
    echo ❌ لم يتم العثور على مجلد APK
    echo يرجى مراجعة الأخطاء أعلاه
)

echo.
echo =================================
echo اكتمل بناء APK
echo =================================

echo 📊 إحصائيات:
echo - Debug APK: !DEBUG_SIZE! MB (للاختبار)
echo - Release APK: !RELEASE_SIZE! MB (للإنتاج)
echo - Split APKs: متاحة للأجهزة المحددة

echo.
echo 💡 نصائح:
echo - استخدم Release APK للتوزيع
echo - احتفظ بنسخة احتياطية من البيانات
echo - تأكد من تفعيل "مصادر غير معروفة"

echo.
echo اضغط أي مفتاح للخروج...
pause >nul
