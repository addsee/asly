import 'package:asly/app/app_pages.dart';
import 'package:asly/app/app_routes.dart';
import 'package:asly/app/translations.dart';
import 'package:asly/controllers/auth_ctr.dart';
import 'package:asly/controllers/home_ctr.dart';
import 'package:asly/controllers/lang_ctr.dart';
import 'package:asly/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة الفايربيز
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // تهيئة الـ controllers الأساسية
  Get.put(AuthCtr(), permanent: true);
  Get.put(LangCtr(), permanent: true);
  Get.put(HomeCtr(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'أصلي - Asly',
      initialRoute: AppRoutes.root,
      getPages: AppPages.pages,
      translations: AppTranslations(),
      locale: const Locale('ar'), // اللغة الافتراضية
      fallbackLocale: const Locale('ar'),
      theme: ThemeData(
        fontFamily: 'Cairo',
        useMaterial3: true,
      ),
    );
  }
}
