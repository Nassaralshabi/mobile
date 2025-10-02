# 🚀 دليل GitHub Actions - بناء APK تلقائياً

## 📱 **نظرة عامة**
تم إعداد GitHub Actions لبناء APK تلقائياً لتطبيق فندق مارينا عند كل push أو pull request.

---

## 🔧 **الملفات المُنشأة:**

### 1. **`.github/workflows/build-apk.yml`**
- بناء APK عادي (موقع وغير موقع)
- يعمل على كل push للفروع الرئيسية
- ينشئ artifacts قابلة للتحميل

### 2. **`.github/workflows/build-signed-apk.yml`**
- بناء APK موقع للإنتاج
- يعمل على tags (v1.0.0, v2.0.0, etc.)
- ينشئ releases على GitHub

### 3. **`android/app/build.gradle`**
- إعدادات Android محسنة
- دعم التوقيع
- تحسينات الأداء

### 4. **`android/app/proguard-rules.pro`**
- قواعد الحماية والتشفير
- تحسين حجم APK
- حماية الكود

---

## 🚀 **كيفية الاستخدام:**

### **الخطوة 1: رفع الكود إلى GitHub**
```bash
# إنشاء repository جديد على GitHub
# ثم في مجلد المشروع:

git init
git add .
git commit -m "Initial commit: Marina Hotel Mobile App"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/marina-hotel-mobile.git
git push -u origin main
```

### **الخطوة 2: تفعيل GitHub Actions**
1. اذهب إلى repository على GitHub
2. اضغط على تبويب "Actions"
3. ستجد workflows جاهزة للتشغيل

### **الخطوة 3: بناء APK تلقائياً**
```bash
# أي push سيبدأ البناء التلقائي
git add .
git commit -m "Update app features"
git push origin main

# سيبدأ GitHub Actions ببناء APK تلقائياً
```

---

## 🔑 **إعداد التوقيع (اختياري):**

### **إنشاء Keystore:**
```bash
keytool -genkey -v -keystore marina-hotel-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias marina-hotel
```

### **إعداد Secrets في GitHub:**
1. اذهب إلى Settings → Secrets and variables → Actions
2. أضف المتغيرات التالية:

```
KEYSTORE_BASE64: [محتوى keystore مُشفر base64]
KEYSTORE_PASSWORD: [كلمة مرور keystore]
KEY_PASSWORD: [كلمة مرور المفتاح]
KEY_ALIAS: marina-hotel
```

### **تشفير Keystore إلى Base64:**
```bash
# في Windows
certutil -encode marina-hotel-key.jks keystore.base64

# في Linux/Mac
base64 -i marina-hotel-key.jks -o keystore.base64
```

---

## 📊 **أنواع البناء:**

### **1. Build APK (تلقائي):**
- **متى يعمل:** عند كل push
- **النتيجة:** APK غير موقع للاختبار
- **التحميل:** من Artifacts في Actions

### **2. Build Signed APK (للإنتاج):**
- **متى يعمل:** عند إنشاء tag
- **النتيجة:** APK موقع + AAB للمتجر
- **التحميل:** من Releases

### **3. Manual Build:**
- **متى يعمل:** يدوياً من Actions tab
- **النتيجة:** حسب الاختيار (debug/release)
- **التحميل:** من Artifacts

---

## 📁 **ملفات APK المُنتجة:**

### **APK عادي:**
```
marina-hotel-v1.0.0-release-20241003-123.apk     (Universal)
marina-hotel-v1.0.0-arm64-20241003-123.apk       (64-bit ARM)
marina-hotel-v1.0.0-arm32-20241003-123.apk       (32-bit ARM)
marina-hotel-v1.0.0-x86_64-20241003-123.apk      (x86 64-bit)
```

### **للإنتاج:**
```
marina-hotel-1.0.0-20241003.apk                  (للتثبيت المباشر)
marina-hotel-1.0.0-20241003.aab                  (لمتجر Google Play)
marina-hotel-1.0.0-debug-symbols.tar.gz          (رموز التشخيص)
```

---

## 🔄 **سير العمل التلقائي:**

### **عند Push:**
```
1. GitHub يستلم الكود الجديد
2. يبدأ GitHub Actions تلقائياً
3. يحمل Flutter SDK
4. يبني APK
5. يرفع APK كـ Artifact
6. يرسل إشعار بالنتيجة
```

### **عند إنشاء Tag:**
```bash
# إنشاء إصدار جديد
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions سيبني إصدار موقع ويضعه في Releases
```

---

## 📱 **تحميل وتثبيت APK:**

### **من Artifacts (للاختبار):**
1. اذهب إلى Actions tab
2. اضغط على آخر build ناجح
3. حمل APK من Artifacts
4. ثبت على جهاز Android

### **من Releases (للإنتاج):**
1. اذهب إلى Releases tab
2. حمل APK من آخر إصدار
3. ثبت على جهاز Android

---

## ⚙️ **تخصيص البناء:**

### **تغيير إصدار Flutter:**
```yaml
# في build-apk.yml
env:
  FLUTTER_VERSION: '3.35.5'  # غيّر هنا
```

### **تغيير إعدادات Android:**
```gradle
// في android/app/build.gradle
defaultConfig {
    minSdkVersion 21        // أقل إصدار Android
    targetSdkVersion 34     // إصدار Android المستهدف
    versionCode 1           // رقم الإصدار
    versionName "1.0"       // اسم الإصدار
}
```

### **إضافة خطوات مخصصة:**
```yaml
# في workflow file
- name: Custom Step
  run: |
    echo "خطوة مخصصة"
    # أضف أوامرك هنا
```

---

## 🐛 **استكشاف الأخطاء:**

### **خطأ في البناء:**
1. اذهب إلى Actions tab
2. اضغط على البناء الفاشل
3. راجع السجلات (logs)
4. ابحث عن رسائل الخطأ

### **أخطاء شائعة:**

#### **Flutter SDK not found:**
```yaml
# تأكد من إصدار Flutter صحيح
flutter-version: '3.35.5'
```

#### **Gradle build failed:**
```bash
# نظف وأعد البناء
flutter clean
flutter pub get
flutter build apk
```

#### **Signing failed:**
```
# تحقق من:
- KEYSTORE_BASE64 صحيح
- كلمات المرور صحيحة
- KEY_ALIAS صحيح
```

---

## 📊 **مراقبة البناء:**

### **الحالة الحالية:**
- ✅ **نجح:** APK جاهز للتحميل
- ⏳ **جاري البناء:** انتظر انتهاء العملية
- ❌ **فشل:** راجع السجلات

### **الإشعارات:**
- GitHub يرسل إشعارات email
- يمكن إعداد Slack/Discord notifications
- تعليقات تلقائية على Pull Requests

---

## 🔧 **إعدادات متقدمة:**

### **بناء متوازي:**
```yaml
strategy:
  matrix:
    flutter-version: ['3.35.5', '3.36.0']
    build-type: ['debug', 'release']
```

### **تخزين مؤقت:**
```yaml
- name: Cache Flutter dependencies
  uses: actions/cache@v3
  with:
    path: ~/.pub-cache
    key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.lock') }}
```

### **اختبارات تلقائية:**
```yaml
- name: Run Tests
  run: flutter test
```

---

## 📞 **الدعم والمساعدة:**

### **مشاكل شائعة:**
- **البناء بطيء:** استخدم cache
- **APK كبير:** فعّل obfuscation
- **أخطاء التوقيع:** راجع المفاتيح

### **تحسينات مقترحة:**
- إضافة اختبارات تلقائية
- بناء متعدد المنصات (iOS)
- نشر تلقائي للمتاجر

---

## 🎉 **النتيجة النهائية:**

**GitHub Actions جاهز لبناء APK تلقائياً! 🚀**

✅ **بناء تلقائي** عند كل تحديث  
✅ **APK جاهز للتحميل** من Artifacts  
✅ **إصدارات موقعة** للإنتاج  
✅ **تحسينات الأداء** والحجم  
✅ **سهولة التحميل والتثبيت**  

**تطبيق فندق مارينا جاهز للتوزيع التلقائي! 📱✨**

*تم إعداده بـ ❤️ لفندق مارينا*
