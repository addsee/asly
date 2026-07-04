import 'package:asly/controllers/lang_ctr.dart';
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
    return const Scaffold(
      backgroundColor: Color(0xFFF3F8FC),
      body: SafeArea(child: _HomeBody()),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final HomeCtr homeCtr = Get.find<HomeCtr>();
    final LangCtr langCtr = Get.find<LangCtr>();

    return Obx(() {
      final isAr = langCtr.isArabic.value;
      return Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          children: [
            _buildTopBar(langCtr, isAr),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _CameraCard(homeCtr: homeCtr),
                    const SizedBox(height: 20),
                    _SerialInputField(homeCtr: homeCtr),
                    const SizedBox(height: 20),
                    _SearchResult(homeCtr: homeCtr),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            _CheckButton(homeCtr: homeCtr),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  Widget _buildTopBar(LangCtr langCtr, bool isAr) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 3, right: 5, left: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          colors: [const Color(0xff1B395B), Color.fromRGBO(27, 57, 91, 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1B395B).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      child: Row(
        children: [
          // العنوان في المنتصف مع زر اللغة بجانبه
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_android_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'my_devices_title'.tr,
                    style: TextStyles.myTextStyle(
                      Colors.white,
                      22,
                      true,
                    )?.copyWith(letterSpacing: 1.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                // زر تبديل اللغة بجوار العنوان
                GestureDetector(
                  onTap: langCtr.toggleLanguage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.25),
                          Colors.white.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.language_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isAr ? 'EN' : 'عر',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---- بطاقة الكاميرا ----
class _CameraCard extends StatelessWidget {
  final HomeCtr homeCtr;
  const _CameraCard({required this.homeCtr});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        height: 220,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff1B395B).withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: homeCtr.isCameraActive.value
              ? _buildActiveCamera()
              : _buildInactiveCamera(),
        ),
      ),
    );
  }

  Widget _buildActiveCamera() {
    return Stack(
      children: [
        MobileScanner(
          controller: homeCtr.cameraCtr,
          onDetect: (barcodeCapture) {
            final String? code = barcodeCapture.barcodes.first.rawValue;
            if (code != null) {
              homeCtr.codeCtr.text = code;
              homeCtr.toggleCamera();
            }
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.1),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.4),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _cameraBtn(
                  Icons.flash_on_rounded,
                  () => homeCtr.cameraCtr.toggleTorch(),
                ),
                _cameraBtn(
                  Icons.flip_camera_android_rounded,
                  () => homeCtr.cameraCtr.switchCamera(),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                      activeTrackColor: Colors.amber,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                      thumbColor: Colors.amber,
                      overlayColor: Colors.amber.withValues(alpha: 0.2),
                    ),
                    child: Obx(
                      () => Slider(
                        value: homeCtr.zoomFactor.value,
                        onChanged: (v) {
                          homeCtr.zoomFactor.value = v;
                          homeCtr.cameraCtr.setZoomScale(v);
                        },
                      ),
                    ),
                  ),
                ),
                _cameraBtn(Icons.close_rounded, () => homeCtr.toggleCamera()),
              ],
            ),
          ),
        ),
        Center(
          child: Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInactiveCamera() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xff1B395B),
            const Color(0xff1B395B).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                elevation: 0,
              ),
              onPressed: homeCtr.toggleCamera,
              icon: const Icon(Icons.camera_alt_rounded),
              label: Text(
                'activate_camera'.tr,
                style: TextStyles.myTextStyle(Colors.white, 18, true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cameraBtn(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 22),
        onPressed: onPressed,
        splashRadius: 20,
      ),
    );
  }
}

// ---- حقل الإدخال ----
class _SerialInputField extends StatelessWidget {
  final HomeCtr homeCtr;
  const _SerialInputField({required this.homeCtr});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff6D758F).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        controller: homeCtr.codeCtr,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        decoration: InputDecoration(
          hintText: 'serial_imei_hint'.tr,
          hintStyle: TextStyle(
            color: const Color(0xff6D758F).withValues(alpha: 0.5),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.qr_code_rounded,
            color: const Color(0xff1B395B).withValues(alpha: 0.6),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.camera_alt_rounded,
              color: const Color(0xff1B395B).withValues(alpha: 0.6),
            ),
            onPressed: () {
              if (!homeCtr.isCameraActive.value) homeCtr.toggleCamera();
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}

// ---- نتيجة البحث ----
class _SearchResult extends StatelessWidget {
  final HomeCtr homeCtr;
  const _SearchResult({required this.homeCtr});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (homeCtr.isSearching.value) {
        return const Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Color(0xff1B395B)),
        );
      }

      if (homeCtr.searchError.value.isNotEmpty) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.red.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  homeCtr.searchError.value,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 15),
                ),
              ),
            ],
          ),
        );
      }

      if (homeCtr.searchResult.value != null) {
        return _DeviceResultCard(data: homeCtr.searchResult.value!);
      }

      return const SizedBox.shrink();
    });
  }
}

class _DeviceResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DeviceResultCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xff128A3F).withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xff128A3F).withValues(alpha: 0.1),
                      const Color(0xff128A3F).withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size: 40,
                  color: Color(0xff128A3F),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['brand'] ??
                          data['deviceName'] ??
                          'verified_device'.tr,
                      style: const TextStyle(
                        color: Color(0xff1B395B),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff128A3F).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '✓ ${'device_verified'.tr}',
                        style: const TextStyle(
                          color: Color(0xff128A3F),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 12),
          if (data['imei'] != null)
            _infoRow(
              Icons.sim_card_rounded,
              'imei'.tr,
              data['imei'].toString(),
            ),
          if (data['ownerName'] != null) ...[
            const SizedBox(height: 10),
            _infoRow(
              Icons.person_rounded,
              'owner'.tr,
              data['ownerName'].toString(),
            ),
          ],
          if (data['purchaseDate'] != null) ...[
            const SizedBox(height: 10),
            _infoRow(
              Icons.calendar_today_rounded,
              'purchase_date'.tr,
              data['purchaseDate'].toString(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xff1B395B), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xff1B395B),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ---- زر الفحص ----
class _CheckButton extends StatelessWidget {
  final HomeCtr homeCtr;
  const _CheckButton({required this.homeCtr});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xff1B395B), Color(0xff2C5282)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1B395B).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final text = homeCtr.codeCtr.text.trim();
            if (text.isNotEmpty) {
              homeCtr.checkDeviceFromFirestore(text);
            } else {
              Get.snackbar(
                'warning'.tr,
                'enter_serial_warning'.tr,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.shade50,
                colorText: Colors.red.shade800,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
                icon: const Icon(Icons.warning_rounded, color: Colors.red),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Text(
                  'check_device'.tr,
                  style: TextStyles.myTextStyle(
                    Colors.white,
                    20,
                    true,
                  )?.copyWith(letterSpacing: 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
