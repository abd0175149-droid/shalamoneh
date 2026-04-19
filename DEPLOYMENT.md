# 🚀 دليل تشغيل ونشر تطبيق شلمونة

## 📋 المتطلبات
- Flutter SDK 3.x+
- Dart SDK 3.x+
- حساب Google Play Console ($25 مرة واحدة)
- حساب Apple Developer ($99/سنة)

---

## 1️⃣ تشغيل Backend محلياً

```powershell
# افتح terminal جديد
cd C:\Projects\shalamonh\backend

# تثبيت الحزم
dart pub get

# تشغيل السيرفر
dart run bin/server.dart
```

**السيرفر سيعمل على:** `http://localhost:8080`

### اختبار الـ API:
```powershell
# Health Check
curl http://localhost:8080/api/health

# إرسال OTP
curl -X POST http://localhost:8080/api/auth/send-otp -H "Content-Type: application/json" -d "{\"phone\":\"+962799999999\"}"

# التحقق من OTP (استخدم الرمز من الرد السابق)
curl -X POST http://localhost:8080/api/auth/verify-otp -H "Content-Type: application/json" -d "{\"phone\":\"+962799999999\",\"otp\":\"123456\"}"

# جلب المنيو
curl http://localhost:8080/api/categories
curl http://localhost:8080/api/products?popular=true

# جلب الفروع
curl http://localhost:8080/api/branches
```

---

## 2️⃣ تشغيل Flutter

```powershell
cd C:\Projects\shalamonh

# تثبيت حزمة http (للـ API Client)
flutter pub add http

# تشغيل على Chrome
flutter run -d chrome

# تشغيل على محاكي Android
flutter run -d emulator-5554

# تشغيل على جهاز حقيقي
flutter run
```

---

## 3️⃣ Google Maps (اختياري)

### الحصول على API Key:
1. اذهب إلى [Google Cloud Console](https://console.cloud.google.com)
2. أنشئ مشروع جديد
3. فعّل **Maps SDK for Android** و **Maps SDK for iOS**
4. أنشئ API Key من **Credentials**

### Android — أضف في `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

### iOS — أضف في `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

### تثبيت الحزمة:
```powershell
flutter pub add google_maps_flutter
```

---

## 4️⃣ Firebase Auth (SMS حقيقي)

### إعداد Firebase:
1. اذهب إلى [Firebase Console](https://console.firebase.google.com)
2. أنشئ مشروع جديد باسم `shalmoneh`
3. أضف تطبيق Android:
   - Package: `com.shalmoneh.app`
   - نزّل `google-services.json` → ضعه في `android/app/`
4. أضف تطبيق iOS:
   - Bundle ID: `com.shalmoneh.app`
   - نزّل `GoogleService-Info.plist` → ضعه في `ios/Runner/`
5. فعّل **Authentication** > **Phone**

### تثبيت الحزم:
```powershell
flutter pub add firebase_core firebase_auth
```

### تهيئة (main.dart):
```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: ShalmonehApp()));
}
```

---

## 5️⃣ بناء APK للنشر (Android)

```powershell
# بناء Release APK
flutter build apk --release

# بناء App Bundle (مطلوب لـ Play Store)
flutter build appbundle --release
```

**الملف:** `build/app/outputs/bundle/release/app-release.aab`

### رفع على Google Play:
1. اذهب إلى [Play Console](https://play.google.com/console)
2. أنشئ تطبيق جديد
3. **Store Listing:**
   - الاسم: `شلمونة | Shalmoneh`
   - الوصف: `تطبيق شلمونة الذكي — اطلب عصيرك المفضل واكسب نقاط!`
   - التصنيف: Food & Drink
4. ارفع `app-release.aab`
5. أكمل Content Rating + Privacy Policy
6. **Release** → Internal Testing أولاً → ثم Production

---

## 6️⃣ بناء IPA للنشر (iOS)

```powershell
# بناء iOS Release
flutter build ios --release
```

### رفع على App Store:
1. افتح `ios/Runner.xcworkspace` في Xcode
2. **Signing & Capabilities:**
   - Team: حساب Apple Developer
   - Bundle ID: `com.shalmoneh.app`
3. **Product** → Archive → Distribute App → App Store Connect
4. في [App Store Connect](https://appstoreconnect.apple.com):
   - أنشئ تطبيق جديد
   - ارفع Build من Xcode
   - أكمل App Information + Screenshots
   - Submit for Review

---

## 7️⃣ نشر Backend على السيرفر

### خيار 1: Railway (مجاني)
```powershell
# تثبيت Railway CLI
npm install -g @railway/cli

# من مجلد backend
cd backend
railway login
railway init
railway up
```

### خيار 2: VPS (DigitalOcean / AWS)
```bash
# على السيرفر
git clone <your-repo>
cd shalamonh/backend
dart pub get
dart compile exe bin/server.dart -o server
PORT=8080 ./server
```

### خيار 3: Docker
```dockerfile
FROM dart:stable AS build
WORKDIR /app
COPY backend/ .
RUN dart pub get
RUN dart compile exe bin/server.dart -o /bin/server

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /bin/server /bin/server
EXPOSE 8080
CMD ["/bin/server"]
```

---

## 📋 قائمة التحقق قبل النشر

- [ ] غيّر `_jwtSecret` في الـ Backend
- [ ] غيّر `_prodBaseUrl` في `api_client.dart` إلى URL السيرفر
- [ ] أزل `otp` من response في auth_controller (للإنتاج)
- [ ] أضف `google-services.json` و `GoogleService-Info.plist`
- [ ] أنشئ App Icon (1024x1024) بشعار شلمونة
- [ ] صوّر Screenshots للمتاجر
- [ ] اكتب Privacy Policy
- [ ] اختبر على أجهزة حقيقية
