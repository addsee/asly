import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:asly/controllers/home_ctr.dart';
import 'package:asly/screens/my_styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AddNew extends StatelessWidget {
  AddNew({super.key});
  final HomeCtr homeCtr = Get.put(HomeCtr());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7FAFC), // خلفية مريحة للعين
      body: SafeArea(
        child: Column(
          children: [
            topBar(),
            Obx(() => stepIndicator(homeCtr.step.value + 1)),
            Expanded(
              child: PageView(
                controller: homeCtr.stepCtr,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (value) => homeCtr.stepForword(value),
                children: [stepOne(), stepTow(), stepThree()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget topBar() {
    return Container(
      color: const Color(0xff1B395B),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Spacer(),
          Text(
            "إضافة جهاز جديد",
            style: TextStyles.myTextStyle(Colors.white, 20, true),
          ),
          Spacer(),
          IconButton(
            onPressed: () {
              if (homeCtr.step.value == 0) {
                Get.back();
              } else {
                homeCtr.stepForword(homeCtr.step.value - 1);
              }
            },
            icon: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget stepOne() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Text(
            "الخطوة الأولى: مسح الرقم المتسلسل (IMEI)",
            style: TextStyles.myTextStyle(Color(0xff1B395B), 18, true),
          ),
        ),

        // حاوية الكاميرا المستجيبة للتغييرات
        Obx(
          () => Container(
            height: 280,
            width: double.infinity,
            margin: const EdgeInsets.all(15),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              border: Border.all(width: 3, color: const Color(0xff1B395B)),
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xff1B395B),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: homeCtr.isCameraActive.value
                ? Stack(
                    children: [
                      MobileScanner(
                        controller: homeCtr.cameraCtr,
                        onDetect: (barcodeCapture) {
                          final String? code =
                              barcodeCapture.barcodes.first.rawValue;
                          if (code != null) {
                            homeCtr.codeCtr.text = code;
                            homeCtr.toggleCamera();
                          }
                        },
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.flash_on,
                                color: Colors.white,
                              ),
                              onPressed: () => homeCtr.cameraCtr.toggleTorch(),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.switch_camera,
                                color: Colors.white,
                              ),
                              onPressed: () => homeCtr.cameraCtr.switchCamera(),
                            ),
                            Expanded(
                              child: Slider(
                                value: homeCtr.zoomFactor.value,
                                activeColor: const Color(0xffC39E3F),
                                onChanged: (value) {
                                  homeCtr.zoomFactor.value = value;
                                  homeCtr.cameraCtr.setZoomScale(value);
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () => homeCtr.toggleCamera(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1B395B),
                      ),
                      onPressed: homeCtr.toggleCamera,
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: Text(
                        "تشغيل الكاميرا",
                        style: TextStyles.myTextStyle(Colors.white, 16, false),
                      ),
                    ),
                  ),
          ),
        ),

        // حقل عرض الرقم المتسلسل
        Container(
          height: 55,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          padding: EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(color: Color(0xff6D758F), blurRadius: 1),
            ],
            border: Border.all(width: 0.5, color: const Color(0xff6D758F)),
          ),
          child: TextField(
            readOnly: true,
            onTap: () {
              if (!homeCtr.isCameraActive.value) {
                homeCtr
                    .toggleCamera(); // لو ضغط على الحقل والكاميرا مقفولة تفتح طوالي
              }
            },
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            controller: homeCtr.codeCtr,
            style: TextStyle(
              color: const Color(0xff1B395B),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintTextDirection: TextDirection.rtl,
              hintText: "الرقم المتسلسل (IMEI)",
              hintStyle: TextStyles.myTextStyle(
                const Color(0xff6D758F),
                16,
                false,
              ),
              border: InputBorder.none,
              prefixIcon: const Icon(
                Icons.qr_code_scanner,
                color: Color(0xff1B395B),
              ),
            ),
          ),
        ),

        const Spacer(),

        InkWell(
          onTap: () {
            homeCtr.stepForword(1);
          },
          child: Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xff1B395B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                "الخطوة التالية",
                style: TextStyles.myTextStyle(Colors.white, 18, true),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            "الخطوة الثانية: معلومات ملكية الهاتف",
            style: TextStyles.myTextStyle(Colors.black, 16, false),
          ),
        ),
      ],
    );
  }

  Widget stepTow() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Text(
            "الخطوة الثانية : مسح الرقم المتسلسل (IMEI)",
            style: TextStyles.myTextStyle(Color(0xff1B395B), 18, true),
          ),
        ),

        const Spacer(),

        InkWell(
          onTap: () {
            homeCtr.stepForword(2);
          },
          child: Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xff1B395B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                "الخطوة التالية",
                style: TextStyles.myTextStyle(Colors.white, 18, true),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            "الخطوة الثانية: معلومات ملكية الهاتف",
            style: TextStyles.myTextStyle(Colors.grey, 16, false),
          ),
        ),
      ],
    );
  }

  Widget stepThree() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Text(
            "الخطوة الثالثة : مسح الرقم المتسلسل ",
            style: TextStyles.myTextStyle(Color(0xff1B395B), 18, true),
          ),
        ),

        const Spacer(),

        InkWell(
          onTap: () {},
          child: Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xff1B395B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                "ارسال الي التحقق",
                style: TextStyles.myTextStyle(Colors.white, 18, true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget stepIndicator(int currentStep) {
    return Row(
      children: [
        SizedBox(width: 30),
        // دائرة الخطوة 1
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentStep >= 1
                ? const Color(0xffC39E3F)
                : Colors.grey[400],
          ),
          child: const Text(
            "1",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),

        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 60,
            height: 4,
            color: currentStep >= 2
                ? const Color(0xffC39E3F)
                : Colors.grey[300],
          ),
        ),

        // دائرة الخطوة 2
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentStep >= 2
                ? const Color(0xffC39E3F)
                : Colors.grey[400],
          ),
          child: const Text(
            "2",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        // الخط الواصل التفاعلي (Step Line)
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 60,
            height: 4,
            color: currentStep >= 3
                ? const Color(0xffC39E3F)
                : Colors.grey[300],
          ),
        ),

        // دائرة الخطوة 2
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentStep >= 3
                ? const Color(0xffC39E3F)
                : Colors.grey[400],
          ),
          child: const Text(
            "2",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 30),
      ],
    );
  }
}
