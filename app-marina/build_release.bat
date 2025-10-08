@echo off
echo بناء APK للإصدار النهائي...
call gradlew clean
call gradlew :app:assembleRelease
echo تم بناء APK بنجاح!
echo موقع APK: app\build\outputs\apk\release\
pause