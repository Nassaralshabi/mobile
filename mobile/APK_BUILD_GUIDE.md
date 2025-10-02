# 🚀 دليل بناء APK - تطبيق فندق مارينا

## 📱 نظرة عامة
هذا الدليل يوضح كيفية تحويل تطبيق Flutter إلى ملف APK قابل للتثبيت على أجهزة Android.

## ⚡ الطريقة السريعة

### 1. تثبيت Flutter (إذا لم يكن مثبتاً):
```bash
# انقر نقراً مزدوجاً على:
setup_flutter.bat
```

### 2. بناء APK:
```bash
# انقر نقراً مزدوجاً على:
build_complete_apk.bat
```

### 3. النتيجة:
- ستجد ملفات APK في مجلد: `build/app/outputs/flutter-apk/`
- استخدم `app-release.apk` للتوزيع العام

## 🛠️ الطريقة اليدوية

### المتطلبات:
- ✅ Flutter SDK 3.35.5 أو أحدث
- ✅ Android SDK
- ✅ Java JDK

### الخطوات:

#### 1. تحضير المشروع:
```bash
cd "e:\xampp\htdocs\marina hotel\mobile"
flutter clean
flutter pub get
```

#### 2. بناء APK للاختبار:
```bash
flutter build apk --debug
```

#### 3. بناء APK للإنتاج:
```bash
flutter build apk --release
```

#### 4. بناء APK مُحسن:
```bash
flutter build apk --release --shrink --obfuscate --split-debug-info=build/debug-info
```

#### 5. بناء APK مقسم:
```bash
flutter build apk --split-per-abi
```

## 📁 أنواع APK المُنشأة

| النوع | الملف | الحجم | الاستخدام |
|-------|-------|-------|-----------|
| Debug | `app-debug.apk` | ~50 MB | الاختبار والتطوير |
| Release | `app-release.apk` | ~25 MB | التوزيع العام |
| ARM64 | `app-arm64-v8a-release.apk` | ~20 MB | الأجهزة الحديثة |
| ARM32 | `app-armeabi-v7a-release.apk` | ~18 MB | الأجهزة القديمة |
| x86_64 | `app-x86_64-release.apk` | ~22 MB | المحاكيات |

## 🎯 أيهما تختار؟

### للاستخدام العام:
- **`app-release.apk`** - الخيار الأفضل للتوزيع

### للاختبار:
- **`app-debug.apk`** - سهل التثبيت والتصحيح

### للأجهزة المحددة:
- **Split APKs** - حجم أصغر لكل جهاز

## 📱 تثبيت APK على الجهاز

### الخطوات:
1. **انسخ ملف APK** إلى جهاز Android
2. **فعّل "مصادر غير معروفة"**:
   - الإعدادات → الأمان → مصادر غير معروفة ✓
3. **اضغط على ملف APK** لبدء التثبيت
4. **اتبع التعليمات** على الشاشة

### إذا واجهت مشاكل:
- تأكد من وجود مساحة كافية (100 MB)
- احذف الإصدار القديم أولاً
- أعد تشغيل الجهاز

## 🔧 ملفات مساعدة متوفرة

| الملف | الوصف |
|-------|--------|
| `setup_flutter.bat` | تثبيت وإعداد Flutter |
| `build_complete_apk.bat` | بناء APK شامل |
| `build_release_apk.bat` | بناء APK للإنتاج فقط |
| `create_app_icon.bat` | إنشاء أيقونة التطبيق |
| `setup_signing.bat` | إعداد توقيع APK |

## 🎨 تخصيص التطبيق

### تغيير الأيقونة:
1. ضع ملف أيقونة (1024x1024) في: `assets/icon/app_icon.png`
2. شغل: `create_app_icon.bat`
3. أعد بناء APK

### تغيير اسم التطبيق:
- عدّل في: `android/app/src/main/AndroidManifest.xml`
- السطر: `android:label="فندق مارينا"`

### تغيير Package Name:
- عدّل في: `android/app/src/main/AndroidManifest.xml`
- السطر: `package="com.marinahotel.mobile"`

## 🔒 التوقيع للنشر

### لنشر في Google Play Store:
1. شغل: `setup_signing.bat`
2. أنشئ مفتاح توقيع
3. احتفظ بالمفتاح وكلمة المرور
4. أعد بناء APK

## 📊 مواصفات التطبيق

### المتطلبات:
- **Android**: 5.0 (API 21) أو أحدث
- **مساحة**: 100 MB للتثبيت
- **ذاكرة**: 2 GB RAM مُوصى بها

### المميزات:
- ✅ يعمل بدون إنترنت
- ✅ مزامنة تلقائية
- ✅ واجهة عربية كاملة
- ✅ قاعدة بيانات محلية
- ✅ تشفير البيانات

### الأذونات:
- 🌐 الوصول للإنترنت
- 📶 حالة الشبكة
- 💾 التخزين المحلي
- 🔔 الإشعارات

## 🚨 استكشاف الأخطاء

### خطأ "Flutter not found":
```bash
# تأكد من تثبيت Flutter وإضافته لـ PATH
flutter --version
```

### خطأ "Build failed":
```bash
# نظف المشروع وأعد المحاولة
flutter clean
flutter pub get
flutter build apk --release
```

### خطأ "Gradle build failed":
```bash
# تحديث Gradle
cd android
./gradlew clean
cd ..
flutter build apk --release
```

### APK لا يعمل على الجهاز:
- تحقق من إصدار Android (يجب أن يكون 5.0+)
- تأكد من تفعيل "مصادر غير معروفة"
- جرب Debug APK بدلاً من Release

## 📞 الدعم

### للمساعدة:
1. راجع ملف `apk_info.md` للتفاصيل
2. تحقق من سجلات الأخطاء
3. جرب الملفات المساعدة المختلفة

### معلومات إضافية:
- **حجم APK**: ~25 MB (Release)
- **وقت البناء**: 3-5 دقائق
- **متوافق مع**: Android 5.0+

---

## 🎉 تهانينا!

تم إنشاء تطبيق فندق مارينا بنجاح! 

**التطبيق جاهز للتثبيت والاستخدام على أجهزة Android** 📱✨

*تم تطويره بـ ❤️ باستخدام Flutter*
