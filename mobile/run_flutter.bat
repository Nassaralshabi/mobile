@echo off
echo =================================
echo Marina Hotel Mobile App
echo =================================

REM تحقق من وجود Flutter
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo Flutter غير مثبت على النظام
    echo.
    echo يرجى تثبيت Flutter من:
    echo https://flutter.dev/docs/get-started/install/windows
    echo.
    echo أو إذا كان Flutter مثبت في مجلد مخصص، قم بتحديث المسار أدناه:
    echo set FLUTTER_PATH=C:\flutter\bin
    echo set PATH=%FLUTTER_PATH%;%PATH%
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
echo تشغيل التطبيق...
echo ملاحظة: تأكد من توصيل جهاز Android أو تشغيل محاكي
echo.

flutter run

pause
