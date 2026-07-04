// ignore_for_file: avoid_print

import 'package:asly/controllers/home_ctr.dart';
import 'package:asly/screens/home/home_screens.dart';
import 'package:asly/screens/profile/profile_screens.dart';
import 'package:asly/controllers/root_ctr.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class RootScreen extends StatelessWidget {
  RootScreen({super.key});
  final RootCtr rootCtr = Get.put(RootCtr());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ModernBottomBar(rootCtr: rootCtr),
      body: PageView(
        physics: const BouncingScrollPhysics(),
        onPageChanged: (value) {
          rootCtr.bottomNav(value);
          // إيقاف الكاميرا عند تغيير الصفحة
          try {
            final homeCtr = Get.find<HomeCtr>();
            if (homeCtr.isCameraActive.value) {
              homeCtr.toggleCamera();
            }
          } catch (_) {}
        },
        controller: rootCtr.pageController.value,
        children: [ProfileScreens(), const HomeScreens()],
      ),
    );
  }
}

class ModernBottomBar extends StatelessWidget {
  final RootCtr rootCtr;
  const ModernBottomBar({super.key, required this.rootCtr});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xff1B395B).withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.phone_android_rounded,
                  label: 'my_phones'.tr,
                  isSelected: rootCtr.currentScreen.value == 0,
                  onTap: () => rootCtr.bottomNav(0),
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.home_rounded,
                  label: 'home'.tr,
                  isSelected: rootCtr.currentScreen.value == 1,
                  onTap: () => rootCtr.bottomNav(1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: isSelected ? 1 : 0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 25 : 15,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        const Color(0xff1B395B),
                        const Color(0xff1B395B).withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xff1B395B).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey.shade400,
                  size: isSelected ? 24 : 22,
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: isSelected
                      ? Row(
                          children: [
                            const SizedBox(width: 8),
                            Text(
                              label,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void setupNotifications() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // طلب إذن الإشعارات لأندرويد 13+
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('تم منح إذن الإشعارات');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('تم منح إذن مؤقت للإشعارات');
  } else {
    print('لم يتم منح إذن الإشعارات');
  }

  // طباعة توكن الجهاز الخاص بالإشعارات
  String? token = await messaging.getToken();
  if (token != null) {
    print("FCM Token: $token");
  }

  // الاستماع لتحديث التوكن
  messaging.onTokenRefresh.listen((newToken) {
    print("تم تحديث FCM Token: $newToken");
  });

  // الاستماع للإشعارات أثناء فتح التطبيق (Foreground)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('وصل إشعار جديد: ${message.notification?.title}');
    print('محتوى الإشعار: ${message.notification?.body}');

    // عرض إشعار بشكل Snackbar أنيق
    if (message.notification != null) {
      Get.snackbar(
        message.notification!.title ?? 'إشعار جديد',
        message.notification!.body ?? '',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xff1B395B).withValues(alpha: 0.95),
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 15,
        icon: const Icon(
          Icons.notifications_active_rounded,
          color: Color(0xffC39E3F),
        ),
        duration: const Duration(seconds: 4),
        animationDuration: const Duration(milliseconds: 500),
        isDismissible: true,
        forwardAnimationCurve: Curves.easeOutBack,
        boxShadows: [
          BoxShadow(
            color: const Color(0xff1B395B).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      );
    }
  });

  // الاستماع عند النقر على الإشعار لفتح التطبيق
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('تم فتح التطبيق من الإشعار: ${message.notification?.title}');
    // يمكنك إضافة التنقل لصفحة معينة هنا
  });

  // معالجة الإشعارات عند فتح التطبيق من حالة مغلقة
  RemoteMessage? initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    print(
      'تم فتح التطبيق من إشعار سابق: ${initialMessage.notification?.title}',
    );
  }
}
