@echo off
echo =================================
echo إنشاء مفاتيح التوقيع - فندق مارينا
echo =================================

REM تحقق من وجود Java
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo Java غير مثبت. يرجى تثبيت Java JDK أولاً
    echo يمكنك تحميله من: https://www.oracle.com/java/technologies/downloads/
    pause
    exit /b 1
)

echo Java متوفر ✓

REM إنشاء مجلد للمفاتيح
if not exist "keys" mkdir keys
cd keys

echo.
echo =================================
echo إنشاء Keystore للتوقيع
echo =================================

REM إنشاء keystore مع معلومات فندق مارينا
keytool -genkey -v ^
    -keystore marina-hotel-release-key.jks ^
    -keyalg RSA ^
    -keysize 2048 ^
    -validity 10000 ^
    -alias marina-hotel ^
    -dname "CN=Marina Hotel, OU=IT Department, O=Marina Hotel, L=Sana'a, ST=Sana'a, C=YE" ^
    -storepass marinahotel2024 ^
    -keypass marinahotel2024

if %errorlevel% equ 0 (
    echo.
    echo ✅ تم إنشاء Keystore بنجاح!
    echo.
    echo معلومات المفتاح:
    echo ================
    echo الملف: marina-hotel-release-key.jks
    echo الاسم المستعار: marina-hotel
    echo كلمة مرور Keystore: marinahotel2024
    echo كلمة مرور المفتاح: marinahotel2024
    echo صالح لمدة: 27 سنة
    echo.
) else (
    echo ❌ فشل في إنشاء Keystore
    pause
    exit /b 1
)

echo =================================
echo إنشاء ملف key.properties
echo =================================

REM إنشاء ملف key.properties
cd ..
(
echo storePassword=marinahotel2024
echo keyPassword=marinahotel2024
echo keyAlias=marina-hotel
echo storeFile=../keys/marina-hotel-release-key.jks
) > android\key.properties

echo ✅ تم إنشاء ملف key.properties

echo.
echo =================================
echo إنشاء ملف الإعدادات المشفر
echo =================================

REM تشفير المعلومات لـ GitHub Secrets
cd keys
certutil -encode marina-hotel-release-key.jks keystore-base64.txt >nul 2>&1

if exist keystore-base64.txt (
    echo ✅ تم تشفير Keystore إلى Base64
    echo الملف: keys\keystore-base64.txt
) else (
    echo ⚠️ لم يتم تشفير Keystore (اختياري)
)

cd ..

echo.
echo =================================
echo إنشاء ملف معلومات GitHub Secrets
echo =================================

(
echo # GitHub Secrets للتوقيع التلقائي
echo # أضف هذه المتغيرات في GitHub Repository Settings ^> Secrets and variables ^> Actions
echo.
echo KEYSTORE_BASE64=^<محتوى ملف keys\keystore-base64.txt^>
echo KEYSTORE_PASSWORD=marinahotel2024
echo KEY_PASSWORD=marinahotel2024
echo KEY_ALIAS=marina-hotel
echo.
echo # ملاحظات:
echo # 1. انسخ محتوى keystore-base64.txt كاملاً إلى KEYSTORE_BASE64
echo # 2. تأكد من عدم وجود مسافات إضافية
echo # 3. هذه المفاتيح آمنة ومُنشأة خصيصاً لفندق مارينا
) > GITHUB_SECRETS.txt

echo ✅ تم إنشاء ملف GITHUB_SECRETS.txt

echo.
echo =================================
echo تحديث .gitignore
echo =================================

REM إضافة ملفات الأمان إلى .gitignore
(
echo.
echo # Signing keys - لا تشارك هذه الملفات
echo android/key.properties
echo keys/
echo *.jks
echo *.keystore
) >> .gitignore

echo ✅ تم تحديث .gitignore

echo.
echo =================================
echo اختبار التوقيع
echo =================================

echo جاري اختبار التوقيع...
flutter build apk --release

if %errorlevel% equ 0 (
    echo ✅ تم بناء APK موقع بنجاح!
    echo الملف: build\app\outputs\flutter-apk\app-release.apk
) else (
    echo ⚠️ فشل في بناء APK موقع (تحقق من إعدادات Flutter)
)

echo.
echo =================================
echo ملخص الإنجاز
echo =================================
echo.
echo ✅ تم إنشاء مفاتيح التوقيع
echo ✅ تم إنشاء ملف key.properties
echo ✅ تم تشفير Keystore للـ GitHub Actions
echo ✅ تم إنشاء ملف GITHUB_SECRETS.txt
echo ✅ تم تحديث .gitignore للأمان
echo.
echo 📁 الملفات المُنشأة:
echo   - keys\marina-hotel-release-key.jks
echo   - android\key.properties
echo   - keys\keystore-base64.txt
echo   - GITHUB_SECRETS.txt
echo.
echo 🔐 معلومات التوقيع:
echo   - Store Password: marinahotel2024
echo   - Key Password: marinahotel2024
echo   - Key Alias: marina-hotel
echo.
echo 🚀 الخطوات التالية:
echo   1. ارفع الكود إلى GitHub
echo   2. أضف المتغيرات من GITHUB_SECRETS.txt إلى GitHub Secrets
echo   3. GitHub Actions سيبني APK موقع تلقائياً
echo.

echo اضغط أي مفتاح للخروج...
pause >nul
