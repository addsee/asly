import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeCtr extends GetxController {
  static HomeCtr get to => Get.find();

  // --- Camera & Scan ---
  var step = 0.obs;
  final TextEditingController codeCtr = TextEditingController();
  final PageController stepCtr = PageController(initialPage: 0, keepPage: true);
  final MobileScannerController cameraCtr = MobileScannerController(
    autoStart: false,
  );
  var isCameraActive = false.obs;
  var zoomFactor = 0.0.obs;

  // --- Home Scan Result ---
  var isSearching = false.obs;
  var searchResult = Rxn<Map<String, dynamic>>();
  var searchError = ''.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onClose() {
    codeCtr.dispose();
    cameraCtr.dispose();
    stepCtr.dispose();
    super.onClose();
  }

  void stepForword(int value) {
    step.value = value;
    stepCtr.animateToPage(
      value,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void toggleCamera() async {
    if (isCameraActive.value) {
      await cameraCtr.stop();
      isCameraActive.value = false;
    } else {
      isCameraActive.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await cameraCtr.start();
        } catch (e) {
          debugPrint('خطأ في تشغيل الكاميرا: $e');
        }
      });
    }
  }

  /// فحص الجهاز من Firestore allphones
  Future<void> checkDeviceFromFirestore(String serialOrImei) async {
    if (serialOrImei.isEmpty) return;
    try {
      isSearching.value = true;
      searchResult.value = null;
      searchError.value = '';

      // البحث في allphones بالـ IMEI أو الرقم التسلسلي
      final QuerySnapshot result = await _firestore
          .collection('allphones')
          .where('imei', isEqualTo: serialOrImei)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        searchResult.value = result.docs.first.data() as Map<String, dynamic>;
        searchResult.value!['docId'] = result.docs.first.id;
      } else {
        // جرب البحث بالرقم التسلسلي
        final QuerySnapshot result2 = await _firestore
            .collection('allphones')
            .where('serial', isEqualTo: serialOrImei)
            .limit(1)
            .get();
        if (result2.docs.isNotEmpty) {
          searchResult.value =
              result2.docs.first.data() as Map<String, dynamic>;
          searchResult.value!['docId'] = result2.docs.first.id;
        } else {
          searchError.value = 'لم يتم العثور على الجهاز في قاعدة البيانات';
        }
      }
    } catch (e) {
      searchError.value = 'حدث خطأ أثناء البحث';
      debugPrint('Search error: $e');
    } finally {
      isSearching.value = false;
    }
  }
}
