// lib/controllers/auth_ctr.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthCtr extends GetxController {
  // ==================== Singleton Pattern ====================
  static AuthCtr get to => Get.find();

  // ==================== Services ====================
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== Reactive States ====================
  final currentUser = Rxn<User>();
  final isLoading = false.obs;
  final isOtpSent = false.obs;
  final verificationIdState = ''.obs;

  // ==================== Controllers ====================
  final emailController = TextEditingController();
  final otpController = TextEditingController();

  // ==================== Computed Properties ====================
  bool get isLoggedIn => currentUser.value != null;

  // ==================== Lifecycle Methods ====================
  @override
  void onInit() {
    super.onInit();
    currentUser.bindStream(_auth.userChanges());
  }

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    super.onClose();
  }

  // ==================== Authentication Methods ====================

  /// تسجيل الدخول باستخدام حساب جوجل
  Future<void> signInWithGoogle() async {
    try {
      // 1. تفعيل حالة التحميل
      isLoading.value = true;

      // 2. محاولة تسجيل الدخول
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // 3. إذا ألغى المستخدم العملية
      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      // 4. الحصول على بيانات المصادقة
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 5. إنشاء اعتماد جوجل
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 6. تسجيل الدخول في Firebase
      final userCred = await _auth.signInWithCredential(credential);

      // 7. حفظ بيانات المستخدم في Firestore
      await _saveUserToFirestore(userCred.user);

      // 🔴 المشكلة كانت هنا: تمت إزالة Get.back()
      // لا داعي لإغلاق أي شاشة، فالمستخدم موجود بالفعل في ProfileScreens

      // 8. إظهار رسالة نجاح
      Get.snackbar(
        'welcome'.tr,
        'login_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xff128A3F),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      // 9. معالجة الأخطاء
      debugPrint('Google Sign-In Error: $e');
      Get.snackbar(
        'error'.tr,
        'login_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } finally {
      // 10. إيقاف حالة التحميل في جميع الحالات
      isLoading.value = false;
    }
  }

  /// تسجيل الخروج من التطبيق
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();

      Get.snackbar(
        'done'.tr,
        'logout_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xff1B395B),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('Sign Out Error: $e');
    }
  }

  // ==================== Private Helper Methods ====================

  /// حفظ أو تحديث بيانات المستخدم في Firestore
  Future<void> _saveUserToFirestore(User? user) async {
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('User saved successfully: ${user.uid}');
    } catch (e) {
      debugPrint('Error saving user to Firestore: $e');
      // لا نعطل سير العمل إذا فشل حفظ البيانات
    }
  }
}
