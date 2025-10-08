# 🚀 دليل إعداد GitHub Actions للبناء التلقائي

## 📋 المتطلبات

يجب إعداد GitHub Secrets التالية في مستودع GitHub:

### 🔐 Secrets المطلوبة

#### للتوقيع (Signing) - اختر أحد الخيارين:

**الخيار 1: استخدام Keystore المُنشأ تلقائياً (مُوصى للاختبار)**
```
KEYSTORE_BASE64: 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
KEYSTORE_PASSWORD: Marina2024!SecureKey789
KEY_ALIAS: marina-hotel-key
KEY_PASSWORD: HotelApp@2024#Strong456
```

**الخيار 2: استخدام Keystore المُوفر (للإنتاج)**
```
KEYSTORE_BASE64: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUR4RENDQXF5Z0F3SUJBZ0lVYkx4TW9kNjJQMmt0Q2lBa3huS0p3dEU5VlBZd0RRWUpLb1pJaHZjTkFRRUwKQlFBd2F6RUxNQWtHQTFVRUJoTUNWVk14RURBT0JnTlZCQWdNQjBSbGJIZGhjbVV4RXpBUkJnTlZCQWNNQ2s1bApkeUJEWVhOMGJHVXhGVEFUQmdOVkJBb01ERk4xY0dGaVlYTmxJRWx1WXpFZU1Cd0dBMVVFQXd3VlUzVndZV0poCmMyVWdVbTl2ZENBeU1ESXhJRU5CTUI0WERUSXhNRFF5T0RFd05UWTFNMW9YRFRNeE1EUXlOakV3TlRZMU0xb3cKYXpFTE1Ba0dBMVVFQmhNQ1ZWTXhFREFPQmdOVkJBZ01CMFJsYkhkaGNtVXhFekFSQmdOVkJBY01DazVsZHlCRApZWE4wYkdVeEZUQVRCZ05WQkFvTURGTjFjR0ZpWVhObElFbHVZekVlTUJ3R0ExVUVBd3dWVTNWd1lXSmhjMlVnClVtOXZkQ0F5TURJeElFTkJNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQXFRWFcKUXlIT0IrcVIyR0pvYkNxL0NCbVE0MEcwb0RtQ0MzbXpWbm44c3Y0WE5lV3RFNVhjRUwwdVZpaDdKbzREa3gxUQpEbUdIQkgxekRmZ3MycVhpTGI2eHB3L0NLUVB5cFpXMUpzc09UTUlmUXBwTlE4N0s3NVlhMHAyNVkzZVBTMnQyCkd0dkh4TmpVVjZrak9aakVuMnlXRWNCZHBPVkNVWUJWRkJOTUI0WUJIa05SRGEvK1M0dXl3QW9hVFduQ0pMVWkKY3ZUbEhtTXc2eFNRUW4xVWZSUUhrNTBETUNFSjdDeTFSeHJaSnJrWFhSUDNMcVFMMmlqSjZGNHlNZmgrR3liNApPNFhham9Wai8rUjRHd3l3S1lyclM4UHJTTnR3eHI1U3RsUU84eklRVVNNaXEyNndNOG1nRUxGbFMvMzJVY2x0Ck5hUTF4QlJpemt6cFpjdDlEd0lEQVFBQm8yQXdYakFMQmdOVkhROEVCQU1DQVFZd0hRWURWUjBPQkJZRUZLalgKdVhZMzJDenRraEltbmc0eUpOVXRhVVlzTUI4R0ExVWRJd1FZTUJhQUZLalh1WFkzMkN6dGtoSW1uZzR5Sk5VdAphVVlzTUE4R0ExVWRFd0VCL3dRRk1BTUJBZjh3RFFZSktvWklodmNOQVFFTEJRQURnZ0VCQUI4c3B6Tm4rNFZVCnRWeGJkTWFYKzM5WjUwc2M3dUFUbXVzMTZqbW1IamhJSHorbC85R2xKNUtxQU1PeDI2bVBaZ2Z6RzdvbmVMMmIKVlcrV2dZVWtUVDNYRVBGV25UcDJSSndRYW84L3RZUFhXRUpEYzBXVlFIcnBtbldPRktVL2QzTXFCZ0JtNXkrNgpqQjgxVFUvUkcyclZlclBEV1ArMU1NY05OeTA0OTFDVEw1WFFaN0pmREpKOUNDbVhTZHRUbDR1VVFuU3V2L1F4CkNlYTEzQlgyWmdKYzdBdTMwdmloTGh1YjUyRGU0UC80Z29uS3NOSFlkYldqZzdPV0t3TnYveml0R0RWREI5WTIKQ01UeVpLRzNYRXU1R2hsMUxFbkkzUW1FK3NxYUNMdjEyQm5WamJrU2Vac01uZXZKUHMxWWU2VGpqSndkaWs1UApvL2JLaUl6K0ZxOD0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
KEYSTORE_PASSWORD: [كلمة مرور keystore الخاص بك]
KEY_ALIAS: [معرف المفتاح الخاص بك]
KEY_PASSWORD: [كلمة مرور المفتاح الخاص بك]
```

## 🔧 خطوات إعداد GitHub Secrets

1. اذهب إلى مستودع GitHub
2. اذهب إلى **Settings** > **Secrets and variables** > **Actions**
3. اضغط **New repository secret**
4. أضف كل secret باسمه وقيمته المحددة أعلاه

## 🚀 متى يتم تشغيل الـ Workflow

الـ workflow يتشغل تلقائياً عند:
- **Push لـ tags**: عند إنشاء tag جديد مثل `v1.0.0`
- **Push لـ branches**: على main و branches التي تبدأ بـ `capy/`
- **Pull Requests**: عند إنشاء/تحديث PR للـ main branch
- **يدوياً**: من خلال GitHub Actions tab

## 📦 المخرجات المُتوقعة

### ✅ عند نجاح البناء:
- **Debug APK**: `marina-hotel-debug-v1.0-20241008_171234.apk`
- **Release APK**: `marina-hotel-release-v1.0-20241008_171234.apk` (موقع)
- **GitHub Release**: عند push tag
- **Artifacts**: متاحة لمدة 30 يوم (debug) و 90 يوم (release)

### 📊 معلومات البناء:
- نسخة JDK 17
- Android SDK أحدث إصدار
- Clean + Build debug + Build release
- تسمية تلقائية بالإصدار والوقت
- Release notes تلقائية

## 🏷️ إنشاء Release

لإنشاء release جديد:

```bash
# إنشاء tag جديد
git tag v1.0.0
git push origin v1.0.0

# أو مباشرة من GitHub web interface
```

سيتم تلقائياً:
- بناء APK موقع
- إنشاء GitHub Release
- رفع APK للـ release
- إنشاء release notes

## 🐛 استكشاف الأخطاء

### مشكلة keystore:
```
Error: Could not read keystore
```
**الحل**: تأكد من صحة KEYSTORE_BASE64 و secrets

### مشكلة signing:
```
Error: Failed to sign APK  
```
**الحل**: تأكد من KEYSTORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD

### مشكلة build:
```
Error: Task assembleRelease failed
```
**الحل**: تحقق من build.gradle.kts و dependencies

## 🔄 تحديث الـ Workflow

إذا احتجت تعديل الـ workflow:
1. عدّل `.github/workflows/build-signed-apk.yml`
2. Commit و push للمستودع  
3. الـ workflow الجديد سيُستخدم في البناء التالي

## 📋 Checklist للإعداد الأول

- [ ] إضافة جميع GitHub Secrets الأربعة
- [ ] تأكد من صحة KEYSTORE_BASE64
- [ ] اختبار بـ workflow_dispatch
- [ ] التأكد من صحة مسارات الملفات
- [ ] إنشاء tag للاختبار (v0.1.0)
- [ ] التحقق من APK المُنتج

---
**✨ بعد إنجاز هذه الخطوات، سيعمل البناء التلقائي بسلاسة!**