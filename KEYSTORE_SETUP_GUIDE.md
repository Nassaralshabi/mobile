# 🔐 دليل إعداد Keystore للإصدارات الإنتاجية

> **⚠️ تحذير مهم:** هذا الدليل لإعداد keystore إنتاجي آمن للإصدارات الرسمية. المفاتيح المفقودة تعني عدم القدرة على تحديث التطبيق على متجر Google Play!

## 📋 نظرة عامة

عند بناء تطبيق Flutter للإنتاج، تحتاج إلى توقيع التطبيق بمفتاح رقمي (keystore) يضمن أصالة التطبيق وهويته. **يجب** استخدام نفس المفتاح لكل الإصدارات المستقبلية.

### لماذا نحتاج keystore منفصل؟

- ✅ **للإنتاج:** مفتاح دائم يستخدم لكل الإصدارات الرسمية
- ✅ **للتطوير:** مفتاح مؤقت للاختبار فقط (يتم توليده تلقائياً)
- ⚠️ **بدون keystore:** لن تتمكن من تحديث التطبيق على المتجر

---

## 🔧 الخطوة 1: إنشاء Keystore للإنتاج (مرة واحدة فقط)

قم بتشغيل هذا الأمر على جهازك المحلي:

```bash
keytool -genkey -v \
  -keystore marina-hotel-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias marina-hotel
```

### سيطلب منك الأمر:
1. **كلمة مرور الـ keystore** - اختر كلمة مرور قوية واحفظها
2. **كلمة مرور الـ key** - يمكن أن تكون نفس كلمة مرور keystore
3. **معلومات المطور:**
   - الاسم الكامل: Marina Hotel
   - الوحدة التنظيمية: IT Department
   - المنظمة: Marina Hotel
   - المدينة: Sana'a
   - المحافظة/الولاية: Sana'a
   - رمز البلد: YE

### مثال على التعبئة:
```
What is your first and last name?
  [Unknown]:  Marina Hotel
What is the name of your organizational unit?
  [Unknown]:  IT Department
What is the name of your organization?
  [Unknown]:  Marina Hotel
What is the name of your City or Locality?
  [Unknown]:  Sana'a
What is the name of your State or Province?
  [Unknown]:  Sana'a
What is the two-letter country code for this unit?
  [Unknown]:  YE
Is CN=Marina Hotel, OU=IT Department, O=Marina Hotel, L=Sana'a, ST=Sana'a, C=YE correct?
  [no]:  yes
```

**⚠️ ملاحظة بالغة الأهمية:**
- احفظ ملف `marina-hotel-release.jks` في مكان آمن جداً (خزنة، cloud خاص، إلخ)
- احفظ كلمات المرور في مدير كلمات مرور آمن
- لا تشارك هذه المعلومات مع أحد
- **إذا فقدت هذا الملف أو كلمات المرور، لن تتمكن أبداً من تحديث التطبيق على المتجر!**

---

## 🔄 الخطوة 2: تحويل Keystore إلى Base64 (للـ GitHub Actions)

لاستخدام keystore في GitHub Actions بشكل آمن، نحتاج لتحويله إلى نص Base64:

### على Linux / macOS:
```bash
base64 marina-hotel-release.jks > keystore.base64.txt
```

### على Windows:
```powershell
certutil -encode marina-hotel-release.jks keystore.base64.txt
# ثم احذف السطر الأول والأخير من الملف (BEGIN CERTIFICATE و END CERTIFICATE)
```

أو استخدم PowerShell:
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("marina-hotel-release.jks")) | Out-File keystore.base64.txt
```

---

## 🔐 الخطوة 3: إضافة GitHub Secrets

الآن سنضيف المعلومات السرية إلى GitHub بشكل آمن:

1. **افتح مستودع GitHub الخاص بك**
2. **اذهب إلى:** `Settings` → `Secrets and variables` → `Actions`
3. **انقر على:** `New repository secret`
4. **أضف الـ Secrets التالية:**

### Secret 1: KEYSTORE_BASE64
- **الاسم:** `KEYSTORE_BASE64`
- **القيمة:** محتوى ملف `keystore.base64.txt` كاملاً
- انسخ كل المحتوى ولصقه (سيكون نص طويل)

### Secret 2: KEYSTORE_PASSWORD
- **الاسم:** `KEYSTORE_PASSWORD`
- **القيمة:** كلمة مرور الـ keystore التي أدخلتها في الخطوة 1

### Secret 3: KEY_ALIAS
- **الاسم:** `KEY_ALIAS`
- **القيمة:** `marina-hotel`

### Secret 4: KEY_PASSWORD
- **الاسم:** `KEY_PASSWORD`
- **القيمة:** كلمة مرور الـ key التي أدخلتها في الخطوة 1

---

## 💻 الخطوة 4: البناء المحلي (للتطوير)

إذا كنت تريد بناء APK موقع على جهازك المحلي:

### 1. أنشئ مجلد للمفاتيح:
```bash
mkdir -p keys
```

### 2. انقل keystore إلى مجلد keys:
```bash
mv marina-hotel-release.jks keys/
```

### 3. أنشئ ملف `mobile/android/key.properties`:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=marina-hotel
storeFile=../../keys/marina-hotel-release.jks
```

**⚠️ مهم جداً:**
- **لا تضف** ملف `key.properties` إلى Git
- **لا تضف** مجلد `keys/` إلى Git
- هذه الملفات للاستخدام المحلي فقط

### 4. قم ببناء التطبيق:
```bash
cd mobile
flutter build apk --release
# أو
flutter build appbundle --release
```

---

## 🔍 التحقق من نجاح الإعداد

### للتحقق من وجود Secrets في GitHub:
1. اذهب إلى `Settings` → `Secrets and variables` → `Actions`
2. يجب أن ترى:
   - ✅ KEYSTORE_BASE64
   - ✅ KEYSTORE_PASSWORD
   - ✅ KEY_ALIAS
   - ✅ KEY_PASSWORD

### للتحقق من توقيع APK:
بعد بناء APK، يمكنك التحقق من التوقيع:

```bash
# التحقق من توقيع APK
jarsigner -verify -verbose -certs mobile/build/app/outputs/flutter-apk/app-release.apk

# عرض معلومات التوقيع
keytool -printcert -jarfile mobile/build/app/outputs/flutter-apk/app-release.apk
```

يجب أن ترى:
- ✅ `jar verified.`
- ✅ معلومات التوقيع تطابق ما أدخلته في الخطوة 1

---

## 🔄 كيف تعمل GitHub Actions الآن؟

### مع Production Keystore:
عند توفر Secrets في GitHub:
1. ✅ يتم فك تشفير keystore من Base64
2. ✅ يتم إنشاء key.properties تلقائياً
3. ✅ يتم بناء APK موقع بمفتاح الإنتاج
4. ✅ يمكن رفع APK إلى Google Play Store

### بدون Production Keystore (Development):
عند عدم توفر Secrets:
1. ⚠️ يتم توليد keystore تطوير مؤقت
2. ⚠️ APK موقع بمفتاح تطوير (صالح للاختبار فقط)
3. ❌ **لا تستخدم هذا APK للإنتاج أو المتجر!**

---

## 📱 رفع التطبيق على Google Play Store

بعد إعداد keystore بنجاح:

### 1. بناء App Bundle (AAB):
```bash
cd mobile
flutter build appbundle --release
```

### 2. الملف الناتج:
```
mobile/build/app/outputs/bundle/release/app-release.aab
```

### 3. رفع على Google Play Console:
1. افتح [Google Play Console](https://play.google.com/console)
2. اختر تطبيقك أو أنشئ تطبيق جديد
3. اذهب إلى `Production` → `Create new release`
4. ارفع ملف `app-release.aab`
5. أكمل المعلومات المطلوبة
6. انشر التطبيق

---

## ⚠️ استكشاف الأخطاء والحلول

### المشكلة: "Keystore file not found"
**الحل:** تأكد من إضافة `KEYSTORE_BASE64` secret في GitHub

### المشكلة: "Keystore password is incorrect"
**الحل:** تحقق من صحة `KEYSTORE_PASSWORD` و `KEY_PASSWORD` secrets

### المشكلة: "Cannot update app on Play Store"
**الحل:** تأكد من استخدام نفس keystore للتحديث

### المشكلة: "Base64 decoding failed"
**الحل:** 
- تأكد من نسخ كل محتوى keystore.base64.txt
- على Windows، احذف سطور BEGIN/END CERTIFICATE

### المشكلة: "Upload failed - different signature"
**الحل:** لا يمكن تغيير keystore بعد النشر. إما:
1. استخدم نفس keystore الأصلي
2. أو أنشئ تطبيق جديد بـ package name مختلف

---

## 🔒 أفضل ممارسات الأمان

1. ✅ **احفظ نسخة احتياطية من keystore** في أماكن متعددة آمنة
2. ✅ **استخدم كلمات مرور قوية** لا تقل عن 16 حرف
3. ✅ **لا تشارك keystore** مع أي شخص غير مصرح له
4. ✅ **لا تضف keystore إلى Git** أبداً
5. ✅ **استخدم GitHub Secrets** لتخزين المعلومات السرية
6. ✅ **راجع الوصول إلى Secrets** بانتظام
7. ✅ **غيّر كلمات المرور** إذا تم اختراق الحساب
8. ✅ **وثّق مكان حفظ keystore** لفريقك

---

## 📞 الدعم والمساعدة

### موارد مفيدة:
- [Flutter - Build and release an Android app](https://docs.flutter.dev/deployment/android)
- [Android - Sign your app](https://developer.android.com/studio/publish/app-signing)
- [GitHub - Encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

### الحصول على المساعدة:
- إذا واجهت مشاكل، راجع قسم "استكشاف الأخطاء" أعلاه
- تحقق من logs في GitHub Actions للحصول على تفاصيل الأخطاء
- تأكد من صحة جميع الأوامر والمسارات

---

## ✅ قائمة التحقق النهائية

قبل البدء بالإنتاج، تأكد من:

- [ ] تم إنشاء keystore إنتاجي
- [ ] تم حفظ keystore في 3 أماكن آمنة على الأقل
- [ ] تم حفظ كلمات المرور في مدير كلمات مرور
- [ ] تم إضافة جميع GitHub Secrets الأربعة
- [ ] تم اختبار البناء في GitHub Actions
- [ ] تم التحقق من توقيع APK بنجاح
- [ ] تم تحديث .gitignore لحماية الملفات الحساسة
- [ ] تم توثيق معلومات keystore للفريق

---

**🏨 تم إعداد هذا الدليل خصيصاً لمشروع Marina Hotel**

آخر تحديث: أكتوبر 2025
