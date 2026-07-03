import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeCtr extends GetxController {
  var step = 0.obs;
  final TextEditingController codeCtr = TextEditingController();
  final PageController stepCtr = PageController(initialPage: 0, keepPage: true);
  final MobileScannerController cameraCtr = MobileScannerController(
    autoStart: false,
  );
  var isCameraActive = false.obs;
  var zoomFactor = 0.0.obs;

  @override
  void dispose() {
    codeCtr.dispose();
    cameraCtr.dispose();
    super.dispose();
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
          debugPrint("خطأ في تشغيل الكاميرا: $e");
        }
      });
    }
  }
}
