@echo off
echo =================================
echo إعداد توقيع APK لفندق مارينا
echo =================================

echo هذا الملف لإنشاء مفتاح توقيع APK للنشر في Google Play Store

echo.
echo تحقق من وجود Java...
java -version
if %errorlevel% neq 0 (
    echo Java غير مثبت. يرجى تثبيت Java JDK أولاً
    pause
    exit /b 1
)

echo.
echo إنشاء مفتاح التوقيع...
echo ملاحظة: احتفظ بكلمة المرور في مكان آمن!

keytool -genkey -v -keystore marina-hotel-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias marina-hotel

echo.
echo تم إنشاء ملف المفتاح: marina-hotel-key.jks

echo.
echo إنشاء ملف key.properties...

(
echo storePassword=YOUR_STORE_PASSWORD
echo keyPassword=YOUR_KEY_PASSWORD  
echo keyAlias=marina-hotel
echo storeFile=../marina-hotel-key.jks
) > android\key.properties

echo.
echo تم إنشاء ملف: android\key.properties

echo.
echo =================================
echo خطوات مهمة:
echo =================================
echo.
echo 1. احتفظ بملف marina-hotel-key.jks في مكان آمن
echo 2. احتفظ بكلمات المرور
echo 3. حدث ملف android\key.properties بكلمات المرور الصحيحة
echo 4. أضف key.properties إلى .gitignore
echo.

echo إنشاء .gitignore للأمان...
echo android/key.properties >> .gitignore
echo *.jks >> .gitignore

echo تم إضافة ملفات الأمان إلى .gitignore

pause
