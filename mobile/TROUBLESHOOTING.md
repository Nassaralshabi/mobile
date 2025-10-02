# 🔧 دليل استكشاف الأخطاء - فندق مارينا

## ❌ **خطأ "Failed to fetch"**

### الأسباب المحتملة:
1. **الخادم غير مُشغل** (XAMPP متوقف)
2. **رابط خاطئ** أو غير صحيح
3. **مشاكل CORS** (Cross-Origin Resource Sharing)
4. **حاجز ناري** يحجب الاتصال
5. **مشاكل في الشبكة**

### الحلول:

#### 1. **تأكد من تشغيل XAMPP:**
```bash
# تحقق من حالة Apache
http://localhost/xampp/
```

#### 2. **اختبر الرابط يدوياً:**
```
http://localhost/marina-hotel/api/test_local.php
```

#### 3. **تحقق من إعدادات CORS:**
- تأكد من وجود ملف `test_local.php` في مجلد API
- تحقق من headers في الملف

#### 4. **استخدم الرابط الصحيح:**
```
✅ صحيح: http://localhost/marina-hotel/api
❌ خاطئ: http://localhost/marina hotel/api (مسافة)
❌ خاطئ: https://localhost/marina-hotel/api (https بدلاً من http)
```

## 🛠️ **خطوات الإصلاح السريع:**

### الخطوة 1: تشغيل XAMPP
```bash
1. افتح XAMPP Control Panel
2. اضغط "Start" بجانب Apache
3. اضغط "Start" بجانب MySQL
4. تأكد من اللون الأخضر
```

### الخطوة 2: اختبار الملفات
```bash
1. اذهب إلى: http://localhost/marina-hotel/api/test_local.php
2. يجب أن ترى استجابة JSON
3. إذا لم تعمل، تحقق من مسار الملفات
```

### الخطوة 3: تحديث الإعدادات
```bash
1. افتح صفحة الإعدادات
2. استخدم: http://localhost/marina-hotel/api
3. اضغط "اختبار الاتصال"
4. يجب أن ترى "متصل بنجاح"
```

## 📋 **قائمة فحص سريعة:**

### ✅ **تحقق من:**
- [ ] XAMPP يعمل (Apache + MySQL)
- [ ] الملفات في المكان الصحيح
- [ ] الرابط صحيح (بدون مسافات)
- [ ] لا يوجد حاجز ناري يحجب المنفذ 80
- [ ] المتصفح يدعم JavaScript

### 🔍 **اختبارات إضافية:**

#### اختبار 1: الوصول المباشر
```
http://localhost/marina-hotel/api/test_local.php
```
**النتيجة المتوقعة:** JSON response مع معلومات الخادم

#### اختبار 2: فحص المجلد
```
http://localhost/marina-hotel/api/
```
**النتيجة المتوقعة:** قائمة بالملفات أو صفحة index

#### اختبار 3: فحص XAMPP
```
http://localhost/xampp/
```
**النتيجة المتوقعة:** صفحة XAMPP الرئيسية

## 🚨 **أخطاء شائعة وحلولها:**

### خطأ: "Connection refused"
**السبب:** Apache غير مُشغل
**الحل:** تشغيل Apache من XAMPP

### خطأ: "404 Not Found"
**السبب:** مسار الملف خاطئ
**الحل:** تحقق من مجلد `marina-hotel/api/`

### خطأ: "CORS policy"
**السبب:** إعدادات CORS مفقودة
**الحل:** استخدام `test_local.php` بدلاً من `test.php`

### خطأ: "Timeout"
**السبب:** الخادم بطيء أو معطل
**الحل:** زيادة مهلة الاتصال أو إعادة تشغيل XAMPP

## 🔧 **إعدادات متقدمة:**

### تفعيل تسجيل الأخطاء:
```php
// في ملف test_local.php
error_reporting(E_ALL);
ini_set('display_errors', 1);
```

### فحص سجلات Apache:
```
xampp/apache/logs/error.log
```

### تخصيص منفذ Apache:
```
1. افتح xampp/apache/conf/httpd.conf
2. غيّر "Listen 80" إلى "Listen 8080"
3. أعد تشغيل Apache
4. استخدم http://localhost:8080/marina-hotel/api
```

## 📱 **للتطبيق المحمول:**

### إعدادات الشبكة المحلية:
```dart
// للاتصال من الهاتف بالكمبيوتر
String serverUrl = 'http://192.168.1.100/marina-hotel/api';
// استبدل 192.168.1.100 بـ IP الكمبيوتر الفعلي
```

### العثور على IP الكمبيوتر:
```bash
# في Windows
ipconfig

# ابحث عن IPv4 Address
```

## 🆘 **إذا لم تنجح الحلول:**

### 1. **إعادة تعيين كاملة:**
```bash
1. أوقف XAMPP
2. احذف مجلد marina-hotel
3. أعد نسخ الملفات
4. شغّل XAMPP
5. اختبر الاتصال
```

### 2. **استخدام منفذ مختلف:**
```bash
1. غيّر Apache للمنفذ 8080
2. استخدم http://localhost:8080/marina-hotel/api
3. اختبر الاتصال
```

### 3. **تعطيل الحاجز الناري مؤقتاً:**
```bash
1. افتح Windows Defender Firewall
2. اختر "Turn Windows Defender Firewall on or off"
3. عطّل للشبكة الخاصة مؤقتاً
4. اختبر الاتصال
5. أعد تفعيل الحاجز الناري
```

## 📞 **الحصول على المساعدة:**

### معلومات مفيدة للدعم:
- إصدار XAMPP
- إصدار Windows
- رسالة الخطأ الكاملة
- لقطة شاشة من XAMPP Control Panel
- محتويات مجلد `marina-hotel/api/`

---

## ✅ **تم حل المشكلة؟**

إذا تم حل المشكلة، يجب أن ترى:
- 🟢 **"متصل بنجاح!"** في صفحة الإعدادات
- معلومات الخادم (إصدار PHP، الوقت)
- إمكانية حفظ الإعدادات والمزامنة

**التطبيق الآن جاهز للعمل مع الخادم المحلي!** 🎉
