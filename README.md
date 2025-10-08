# 🏨 Marina Hotel Management System

**نظام إدارة فندق مارينا الشامل** - تطبيقات محمولة لإدارة الفنادق مع أنظمة حجز، غرف، مدفوعات، ومصروفات.

[![📱 Build APKs](https://github.com/Nassaralshabi/mobile/actions/workflows/build-apks.yml/badge.svg)](https://github.com/Nassaralshabi/mobile/actions/workflows/build-apks.yml)
[![🧪 Tests](https://github.com/Nassaralshabi/mobile/actions/workflows/tests.yml/badge.svg)](https://github.com/Nassaralshabi/mobile/actions/workflows/tests.yml)
[![🚀 Release](https://github.com/Nassaralshabi/mobile/actions/workflows/release.yml/badge.svg)](https://github.com/Nassaralshabi/mobile/actions/workflows/release.yml)

---

## 📱 التطبيقات المتاحة

### 1. 🎯 Flutter Mobile App
تطبيق محمول حديث بواجهة مستخدم متقدمة

**الميزات**:
- ✅ واجهة مستخدم عربية كاملة
- ✅ دعم العمل بدون إنترنت (Offline)
- ✅ مزامنة البيانات التلقائية
- ✅ إشعارات فورية
- ✅ تصميم متجاوب لجميع الشاشات

### 2. 🤖 Android Native App (app-marina)
تطبيق أندرويد أصلي بأداء عالي

**الميزات**:
- ✅ أداء محسّن للأندرويد
- ✅ قاعدة بيانات محلية متقدمة
- ✅ واجهة Material Design
- ✅ إدارة مستخدمين متعددين
- ✅ تقارير شاملة

---

## 🔐 بيانات تسجيل الدخول

**جميع التطبيقات مُكونة مسبقاً بـ**:
- **اسم المستخدم**: `admin`
- **كلمة المرور**: `1234`

---

## 📥 تحميل التطبيقات

### 🚀 من الإصدارات الرسمية (مستحسن):
[![📱 Download Latest APKs](https://img.shields.io/github/v/release/Nassaralshabi/mobile?label=Download%20APKs&style=for-the-badge&logo=android)](https://github.com/Nassaralshabi/mobile/releases/latest)

### 🔧 من Builds التطوير:
1. اذهب إلى [Actions](https://github.com/Nassaralshabi/mobile/actions/workflows/build-apks.yml)
2. اختر آخر build ناجح
3. حمّل `marina-hotel-apks` من Artifacts

---

## ⚡ البناء التلقائي

### 🤖 GitHub Actions
يتم بناء ملفات APK تلقائياً عند:
- ✅ **Push** لـ branches الرئيسية
- ✅ **Pull Requests**
- ✅ **إنشاء Tags** (للإصدارات)
- ✅ **تشغيل يدوي**

### 📊 حالة البناء:
| Component | Status |
|-----------|---------|
| Flutter App | [![Flutter](https://github.com/Nassaralshabi/mobile/actions/workflows/build-apks.yml/badge.svg?event=push)](https://github.com/Nassaralshabi/mobile/actions) |
| Android App | [![Android](https://github.com/Nassaralshabi/mobile/actions/workflows/build-apks.yml/badge.svg?event=push)](https://github.com/Nassaralshabi/mobile/actions) |
| Tests | [![Tests](https://github.com/Nassaralshabi/mobile/actions/workflows/tests.yml/badge.svg)](https://github.com/Nassaralshabi/mobile/actions) |

---

## 🏗️ البناء المحلي

### متطلبات البناء:
- **Java**: 17+
- **Flutter**: 3.24.5+
- **Android SDK**: API 34
- **Git**: أحدث إصدار

### 🎯 بناء Flutter App:
```bash
# Clone المشروع
git clone https://github.com/Nassaralshabi/mobile.git
cd mobile/mobile

# تثبيت التبعيات
flutter pub get

# بناء APK
flutter build apk --release
```

### 🤖 بناء Android Native App:
```bash
# الانتقال للمشروع
cd mobile/app-marina

# بناء APK
./gradlew assembleRelease
```

### 📱 البناء السريع (الكل):
```bash
# استخدام السكريبت الجاهز
chmod +x build_apks.sh
./build_apks.sh
```

---

## 🚀 الميزات الرئيسية

### 🏨 إدارة الفندق:
- **إدارة الغرف**: حالة الغرف، أنواع، أسعار
- **نظام الحجوزات**: حجز، تعديل، إلغاء
- **إدارة النزلاء**: بيانات العملاء، سجلات
- **المدفوعات**: تتبع المدفوعات، فواتير
- **المصروفات**: تسجيل وتتبع المصروفات
- **الموظفين**: إدارة بيانات الفريق
- **التقارير**: تقارير شاملة ومفصلة

### 💻 المميزات التقنية:
- **Offline Support**: العمل بدون إنترنت (Flutter)
- **Auto Sync**: مزامنة تلقائية للبيانات
- **Multi-User**: دعم مستخدمين متعددين
- **Security**: تشفير البيانات وحماية متقدمة
- **Responsive**: تصميم متجاوب لجميع الشاشات
- **Arabic RTL**: دعم كامل للغة العربية

---

## 📋 دليل الاستخدام

### 🔧 التثبيت:
1. حمّل ملف APK المناسب
2. فعّل "المصادر غير المعروفة" في الأندرويد
3. قم بتثبيت التطبيق
4. افتح التطبيق وسجل دخول بـ `admin/1234`

### 🎯 البدء السريع:
1. **تسجيل الدخول**: استخدم admin/1234
2. **إضافة غرف**: حدد أنواع وأسعار الغرف
3. **إنشاء حجز**: أضف حجوزات العملاء
4. **تسجيل مدفوعات**: سجل المدفوعات والفواتير
5. **عرض التقارير**: راجع الأداء والإحصائيات

---

## 🔄 التطوير والمساهمة

### 📝 إنشاء Issues:
- [🐛 Bug Report](https://github.com/Nassaralshabi/mobile/issues/new?template=bug_report.yml)
- [✨ Feature Request](https://github.com/Nassaralshabi/mobile/issues/new?template=feature_request.yml)
- [🔧 Build Issue](https://github.com/Nassaralshabi/mobile/issues/new?template=build_issue.yml)

### 🔀 Pull Requests:
1. Fork المشروع
2. إنشاء branch جديد: `git checkout -b feature/amazing-feature`
3. Commit التغييرات: `git commit -m 'Add amazing feature'`
4. Push للـ branch: `git push origin feature/amazing-feature`
5. فتح Pull Request

### 🧪 الاختبارات:
```bash
# Flutter tests
cd mobile && flutter test

# Android tests
cd app-marina && ./gradlew test
```

---

## 📚 الوثائق

### 📖 الأدلة المتاحة:
- [🏗️ Build Guide](APK_BUILD_GUIDE.md)
- [⚙️ Settings Guide](SETTINGS_GUIDE.md)
- [🔑 Keystore Setup](KEYSTORE_SETUP_GUIDE.md)
- [🔄 GitHub Actions](.github/workflows/README.md)
- [📊 Configuration Report](CONFIGURATION_REPORT.md)

### 🔗 روابط مفيدة:
- [📥 التحميلات](https://github.com/Nassaralshabi/mobile/releases)
- [🚀 Actions](https://github.com/Nassaralshabi/mobile/actions)
- [📋 Issues](https://github.com/Nassaralshabi/mobile/issues)
- [💬 Discussions](https://github.com/Nassaralshabi/mobile/discussions)

---

## 🛠️ استكشاف الأخطاء

### ❌ مشاكل شائعة:

**مشكلة تسجيل الدخول**:
- تأكد من استخدام `admin/1234`
- جرب الوضع بدون إنترنت (Flutter)
- تأكد من إنشاء قاعدة البيانات (Android)

**مشكلة البناء**:
- تحقق من إصدارات SDK و Flutter
- قم بـ clean وإعادة بناء
- راجع [Build Issues](https://github.com/Nassaralshabi/mobile/issues/new?template=build_issue.yml)

**مشكلة التثبيت**:
- فعّل "المصادر غير المعروفة"
- تأكد من إصدار الأندرويد (API 21+/24+)
- احذف النسخة القديمة أولاً

---

## 📊 إحصائيات المشروع

![GitHub code size](https://img.shields.io/github/languages/code-size/Nassaralshabi/mobile)
![GitHub repo size](https://img.shields.io/github/repo-size/Nassaralshabi/mobile)
![GitHub contributors](https://img.shields.io/github/contributors/Nassaralshabi/mobile)
![GitHub last commit](https://img.shields.io/github/last-commit/Nassaralshabi/mobile)
![GitHub issues](https://img.shields.io/github/issues/Nassaralshabi/mobile)
![GitHub pull requests](https://img.shields.io/github/issues-pr/Nassaralshabi/mobile)

---

## 📞 الدعم والتواصل

### 🆘 الحصول على المساعدة:
1. **البحث أولاً**: راجع [Issues المغلقة](https://github.com/Nassaralshabi/mobile/issues?q=is%3Aissue+is%3Aclosed)
2. **الوثائق**: راجع الأدلة المتاحة
3. **إنشاء Issue**: استخدم القوالب المناسبة
4. **Discussions**: للأسئلة العامة والأفكار

### 📧 التواصل:
- **GitHub Issues**: للمشاكل التقنية
- **GitHub Discussions**: للأسئلة والاقتراحات
- **Email**: [ضع الإيميل هنا إذا متاح]

---

## 🎯 خارطة الطريق

### 🔄 التحديثات القادمة:
- [ ] دعم قاعدة بيانات سحابية
- [ ] تطبيق ويب إضافي
- [ ] نظام إشعارات متقدم
- [ ] تكامل مع أنظمة دفع
- [ ] تقارير تفاعلية متقدمة
- [ ] دعم لغات إضافية

### 📈 الإحصائيات:
- ✅ **2 تطبيقات** جاهزة
- ✅ **4 workflows** تلقائية
- ✅ **100%** التكامل المستمر
- ✅ **Auto-build** لكل commit

---

## 📜 الترخيص

هذا المشروع مرخص تحت [رخصة MIT](LICENSE) - راجع ملف الترخيص للتفاصيل.

---

## ⭐ إذا أعجبك المشروع

إذا وجدت هذا المشروع مفيداً، لا تنس إعطاءه نجمة ⭐ ومشاركته مع الآخرين!

[![Star this repo](https://img.shields.io/github/stars/Nassaralshabi/mobile?style=social)](https://github.com/Nassaralshabi/mobile/stargazers)
[![Fork this repo](https://img.shields.io/github/forks/Nassaralshabi/mobile?style=social)](https://github.com/Nassaralshabi/mobile/network/members)

---

**صُنع بـ ❤️ لإدارة الفنادق**