#!/bin/bash
echo "بناء APK للإصدار النهائي..."
./gradlew clean
./gradlew :app:assembleRelease
echo "تم بناء APK بنجاح!"
echo "موقع APK: app/build/outputs/apk/release/"