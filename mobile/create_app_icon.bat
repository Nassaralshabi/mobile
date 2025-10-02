@echo off
echo =================================
echo إنشاء أيقونة تطبيق فندق مارينا
echo =================================

echo تثبيت flutter_launcher_icons...
flutter pub add flutter_launcher_icons

echo إنشاء ملف تكوين الأيقونة...

(
echo flutter_icons:
echo   android: "launcher_icon"
echo   ios: true
echo   image_path: "assets/icon/app_icon.png"
echo   min_sdk_android: 21
echo   web:
echo     generate: true
echo     image_path: "assets/icon/app_icon.png"
echo     background_color: "#hexcode"
echo     theme_color: "#hexcode"
echo   windows:
echo     generate: true
echo     image_path: "assets/icon/app_icon.png"
echo     icon_size: 48
) > flutter_launcher_icons.yaml

echo تم إنشاء ملف التكوين: flutter_launcher_icons.yaml

echo.
echo ملاحظة: يرجى إضافة ملف الأيقونة:
echo assets/icon/app_icon.png
echo (حجم 1024x1024 بكسل)

echo.
echo لتطبيق الأيقونة، شغل:
echo flutter pub get
echo flutter pub run flutter_launcher_icons:main

pause
