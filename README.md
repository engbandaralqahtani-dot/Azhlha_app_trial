# منصة إدارة حوادث المركبات

تطبيق لإدارة حوادث المركبات من لحظة البلاغ → السحب → التقدير → إصلاح السيارة → التوصيل للعميل.

## المميزات

- ✨ واجهة مستخدم سهلة وبسيطة
- 📱 دعم نظامي Android و iOS
- 📍 تحديد موقع الحادث باستخدام خرائط Google
- 📸 التقاط وإرفاق صور للحادث
- 🚗 تتبع حالة الطلب مباشرة
- 🔔 إشعارات فورية لتحديثات الحالة
- 🌙 دعم اللغة العربية
- 🔒 مصادقة آمنة للمستخدمين

## المتطلبات

- Flutter SDK
- Android Studio / VS Code
- Firebase Account
- Google Maps API Key

## التثبيت

1. استنساخ المشروع:
```bash
git clone https://github.com/yourusername/car_accident_management.git
```

2. تثبيت التبعيات:
```bash
flutter pub get
```

3. إعداد Firebase:
- أنشئ مشروع Firebase جديد
- أضف تطبيق Android و iOS
- قم بتحميل ملف `google-services.json` لـ Android
- قم بتحميل ملف `GoogleService-Info.plist` لـ iOS

4. إعداد Google Maps:
- احصل على مفتاح API من Google Cloud Console
- أضف المفتاح في `AndroidManifest.xml` و `AppDelegate.swift`

5. تشغيل التطبيق:
```bash
flutter run
```

## الهيكل

```
lib/
  ├── models/        # نماذج البيانات
  ├── screens/       # شاشات التطبيق
  ├── services/      # خدمات التطبيق
  ├── providers/     # مزودي الحالة
  ├── widgets/       # العناصر المشتركة
  └── utils/         # أدوات مساعدة
```

## التقنيات المستخدمة

- Flutter
- Firebase (Auth, Firestore, Storage, Messaging)
- Google Maps
- Provider (State Management)
- GetX (Navigation)
- Cached Network Image
- Share Plus

## المساهمة

1. Fork المشروع
2. أنشئ فرع لميزتك (`git checkout -b feature/amazing-feature`)
3. Commit التغييرات (`git commit -m 'إضافة ميزة رائعة'`)
4. Push إلى الفرع (`git push origin feature/amazing-feature`)
5. افتح Pull Request

## الترخيص

هذا المشروع مرخص تحت رخصة MIT - انظر ملف [LICENSE](LICENSE) للتفاصيل.
