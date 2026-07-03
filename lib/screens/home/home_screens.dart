import 'package:asly/app/app_colors.dart';
import 'package:asly/screens/my_styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:asly/controllers/home_ctr.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';

class HomeScreens extends StatelessWidget {
  const HomeScreens({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FC),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              topBar(),
              Expanded(child: BodyBar()),
            ],
          ),
        ),
      ),
    );
  }

  Widget topBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      color: AppColors.main,
      padding: EdgeInsets.all(10),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "مرحبا بك في أصلي ",
            style: TextStyles.myTextStyle(Colors.white, 20, true),
          ),
        ],
      ),
    );
  }
}

class BodyBar extends StatelessWidget {
  const BodyBar({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeCtr homeCtr = Get.put(HomeCtr());
    return Column(
      children: [
        Obx(
          () => Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.all(10),
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
                                activeColor: Colors.amber,
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
        Container(
          height: 60,
          margin: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(color: Color(0xff6D758F), blurRadius: 1),
            ],
            border: Border.all(width: 0.5),
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 10, left: 20),
                  child: TextField(
                    onTap: () {
                      if (!homeCtr.isCameraActive.value) {
                        homeCtr.toggleCamera();
                      }
                    },
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    controller: homeCtr.codeCtr,
                    style: TextStyles.myTextStyle(
                      const Color(0xff6D758F),
                      20,
                      true,
                    ),
                    decoration: InputDecoration(
                      hintTextDirection: TextDirection.rtl,
                      hintText: "الرقم المتسلسل",
                      hintStyle: TextStyles.myTextStyle(
                        const Color(0xff6D758F),
                        18,
                        true,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Spacer(),
        InkWell(
          onTap: () {
            if (homeCtr.codeCtr.text.isNotEmpty) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize: 0.85,
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  expand: false,
                  builder: (context, scrollController) {
                    return showStatas(context);
                  },
                ),
              );
            } else {
              Get.snackbar(
                "اكتب الرقم التسلسلي",
                "الرجاء ادخال الرقم المتسلسل",
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
          child: Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xff1B395B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 1),
            ),
            child: Center(
              child: Text(
                "فحص الجهاز",
                style: TextStyles.myTextStyle(Colors.white, 20, true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget showStatas(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1000),
                color: const Color(0xff808184),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 10),
              Container(
                height: 100,
                width: 100,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xff128A3F),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff128A3F).withAlpha(120),
                      spreadRadius: 10,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.done_sharp, color: Colors.white, size: 50),
                ),
              ),
              Text(
                "الجهاز سليم وموثق",
                style: TextStyles.myTextStyle(
                  const Color(0xff128A3F),
                  25,
                  true,
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff128A3F).withAlpha(100)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.phone_android,
                      size: 80,
                      color: Colors.grey,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "Samsung Galaxy S23",
                            style: TextStyles.myTextStyle(
                              const Color(0xff514D4E),
                              20,
                              true,
                            ),
                          ),
                          Text(
                            "المالك : مهند سليمان",
                            style: TextStyles.myTextStyle(
                              const Color(0xff514D4E),
                              18,
                              true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                gab(),
                _buildImeiRow(),
                gab(),
                _buildImeiRow(),
              ],
            ),
          ),
          buttonOk(context),
        ],
      ),
    );
  }

  Widget _buildImeiRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Icon(Icons.sd_card, color: Color(0xff514D4E)),
        Text(
          "imei",
          style: TextStyles.myTextStyle(const Color(0xff514D4E), 18, true),
        ),
        Text(
          "123456789987655",
          style: TextStyles.myTextStyle(const Color(0xff514D4E), 18, false),
        ),
      ],
    );
  }

  Widget gab() {
    return Container(
      margin: const EdgeInsets.all(5),
      height: 1,
      color: const Color.fromARGB(92, 144, 142, 148),
    );
  }

  Widget buttonOk(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xff128A3F),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            "ممتاز",
            style: TextStyles.myTextStyle(Colors.white, 20, true),
          ),
        ),
      ),
    );
  }
}
