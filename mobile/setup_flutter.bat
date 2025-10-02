@echo off
echo =================================
echo إعداد Flutter لفندق مارينا
echo =================================

REM إنشاء مجلد Flutter إذا لم يكن موجوداً
if not exist "C:\flutter" (
    echo إنشاء مجلد C:\flutter...
    mkdir "C:\flutter" 2>nul
)

REM تحقق من وجود Flutter
if exist "C:\flutter\bin\flutter.exe" (
    echo Flutter موجود في C:\flutter
    goto :setup_path
)

echo Flutter غير موجود. يرجى اتباع الخطوات التالية:
echo.
echo 1. اذهب إلى: https://flutter.dev/docs/get-started/install/windows
echo 2. حمل flutter_windows_3.35.5-stable.zip
echo 3. استخرج الملف إلى C:\flutter
echo 4. شغل هذا الملف مرة أخرى
echo.
pause
exit /b 1

:setup_path
echo إعداد متغير PATH...

REM إضافة Flutter إلى PATH للجلسة الحالية
set "FLUTTER_PATH=C:\flutter\bin"
set "PATH=%FLUTTER_PATH%;%PATH%"

echo تم إعداد Flutter مؤقتاً للجلسة الحالية
echo.

echo تحقق من إصدار Flutter...
"C:\flutter\bin\flutter.exe" --version

echo.
echo للإعداد الدائم، أضف C:\flutter\bin إلى متغيرات البيئة:
echo 1. اضغط Win + R واكتب: sysdm.cpl
echo 2. اذهب إلى Advanced → Environment Variables
echo 3. أضف C:\flutter\bin إلى PATH
echo.

echo الآن يمكنك تشغيل:
echo flutter pub get
echo flutter run
echo.

pause
