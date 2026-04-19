import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shalmoneh_app/app.dart';
import 'firebase_options.dart';

/// نقطة الدخول الرئيسية للتطبيق
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── تهيئة Firebase (يخدم Phone Auth + Push Notifications) ───
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ─── إعدادات النظام ───
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ─── شريط الحالة شفاف ───
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: ShalmonehApp(),
    ),
  );
}
