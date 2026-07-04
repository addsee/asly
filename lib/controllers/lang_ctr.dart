import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LangCtr extends GetxController {
  static LangCtr get to => Get.find();

  var isArabic = true.obs;

  @override
  void onInit() {
    super.onInit();
    // الحصول على اللغة الحالية للتطبيق من Get.locale
    final currentLocale = Get.locale ?? const Locale('ar');
    isArabic.value = currentLocale.languageCode == 'ar';
  }

  void toggleLanguage() {
    if (isArabic.value) {
      Get.updateLocale(const Locale('en'));
      isArabic.value = false;
    } else {
      Get.updateLocale(const Locale('ar'));
      isArabic.value = true;
    }
  }
}
