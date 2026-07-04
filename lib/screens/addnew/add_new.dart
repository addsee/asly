// ignore_for_file: avoid_print

import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:asly/controllers/home_ctr.dart';
import 'package:asly/screens/my_styles/text_styles.dart';
import 'package:asly/widgets/top_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AddNew extends StatelessWidget {
  AddNew({super.key});
  final HomeCtr homeCtr = Get.find<HomeCtr>();
  final AddCtr addCtr = Get.put(AddCtr());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FC),
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              showBackButton: true,
              title: 'add_new_device'.tr,
              leadingIcon: Icons.add_circle_outline_rounded,
              onTap: () {
                if (homeCtr.step.value == 0) {
                  Get.back();
                } else {
                  homeCtr.stepForword(homeCtr.step.value - 1);
                }
              },
            ),
            const SizedBox(height: 10),
            Obx(() => StepIndicator(currentStep: homeCtr.step.value + 1)),
            const SizedBox(height: 10),
            Expanded(
              child: PageView(
                controller: homeCtr.stepCtr,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (value) => homeCtr.stepForword(value),
                children: [
                  StepOneContent(homeCtr: homeCtr, addCtr: addCtr),
                  StepTwoContent(homeCtr: homeCtr, addCtr: addCtr),
                  StepThreeContent(homeCtr: homeCtr, addCtr: addCtr),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- مؤشر الخطوات ----
class StepIndicator extends StatelessWidget {
  final int currentStep;
  const StepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          _buildStepCircle(1, currentStep, 'IMEI'),
          Expanded(child: _buildStepLine(1, currentStep)),
          _buildStepCircle(2, currentStep, 'owner'.tr),
          Expanded(child: _buildStepLine(2, currentStep)),
          _buildStepCircle(3, currentStep, 'confirm'.tr),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildStepLine(int stepNumber, int currentStep) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: currentStep > stepNumber
            ? const LinearGradient(
                colors: [Color(0xffC39E3F), Color(0xffD4AF50)],
              )
            : LinearGradient(
                colors: [Colors.grey.shade300, Colors.grey.shade200],
              ),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

Widget _buildStepCircle(int stepNumber, int currentStep, String label) {
  final isActive = currentStep >= stepNumber;
  final isCurrent = currentStep == stepNumber;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        width: isCurrent ? 45 : 40,
        height: isCurrent ? 45 : 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xffC39E3F), Color(0xffD4AF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade300],
                ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xffC39E3F).withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: isActive && stepNumber < currentStep
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
              : Text(
                  '$stepNumber',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isCurrent ? 18 : 16,
                  ),
                ),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        label,
        style: TextStyle(
          color: isActive ? const Color(0xff1B395B) : Colors.grey,
          fontSize: 12,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ],
  );
}

// ---- الخطوة الأولى: مسح IMEI ----
class StepOneContent extends StatelessWidget {
  final HomeCtr homeCtr;
  final AddCtr addCtr;

  const StepOneContent({
    super.key,
    required this.homeCtr,
    required this.addCtr,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildStepTitle(
            icon: Icons.qr_code_scanner_rounded,
            stepNumber: 'step_1'.tr,
            title: 'scan_imei_title'.tr,
          ),
          const SizedBox(height: 25),
          // Camera Container
          Obx(
            () => Container(
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xff1B395B).withValues(alpha: 0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff1B395B).withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: homeCtr.isCameraActive.value
                    ? _buildCameraView()
                    : _buildCameraPlaceholder(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildImeiInput(),
          const SizedBox(height: 30),
          _buildNextButton(
            label: 'next_step'.tr,
            icon: Icons.arrow_forward_rounded,
            onTap: () {
              if (addCtr.imeiController.text.isNotEmpty) {
                homeCtr.stepForword(1);
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
          ),
          const SizedBox(height: 15),
          _buildStepInfo(
            icon: Icons.info_outline_rounded,
            text: 'step_2_desc'.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        MobileScanner(
          controller: homeCtr.cameraCtr,
          onDetect: (barcodeCapture) {
            final String? code = barcodeCapture.barcodes.first.rawValue;
            if (code != null) {
              addCtr.imeiController.text = code;
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
        Center(
          child: Container(
            height: 150,
            width: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 2,
              ),
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
                _cameraControlButton(
                  icon: Icons.flash_on_rounded,
                  onPressed: () => homeCtr.cameraCtr.toggleTorch(),
                ),
                _cameraControlButton(
                  icon: Icons.flip_camera_android_rounded,
                  onPressed: () => homeCtr.cameraCtr.switchCamera(),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                      activeTrackColor: const Color(0xffC39E3F),
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                      thumbColor: const Color(0xffC39E3F),
                      overlayColor: const Color(
                        0xffC39E3F,
                      ).withValues(alpha: 0.2),
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
                _cameraControlButton(
                  icon: Icons.close_rounded,
                  onPressed: () => homeCtr.toggleCamera(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPlaceholder() {
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

  Widget _buildImeiInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(15),
        ],
        textAlign: TextAlign.center,
        controller: addCtr.imeiController,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          color: Color(0xff1B395B),
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

  Widget _cameraControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
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

// ---- الخطوة الثانية: معلومات المالك ----
class StepTwoContent extends StatelessWidget {
  final HomeCtr homeCtr;
  final AddCtr addCtr;

  const StepTwoContent({
    super.key,
    required this.homeCtr,
    required this.addCtr,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildStepTitle(
            icon: Icons.person_outline_rounded,
            stepNumber: 'step_2'.tr,
            title: 'new_owner_title'.tr,
          ),
          const SizedBox(height: 25),
          // عرض IMEI المسجل
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // عرض IMEI
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xff1B395B).withValues(alpha: 0.05),
                        const Color(0xff1B395B).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone_android_rounded,
                        size: 40,
                        color: const Color(0xff1B395B).withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'imei_registered'.tr,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              addCtr.imeiController.text.isEmpty
                                  ? 'empty_imei'.tr
                                  : addCtr.imeiController.text,
                              style: TextStyles.myTextStyle(
                                const Color(0xff1B395B),
                                18,
                                true,
                              )?.copyWith(letterSpacing: 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                _buildInputField(
                  label: 'device_brand_label'.tr,
                  hint: 'device_brand_hint'.tr,
                  icon: Icons.phone_android_rounded,
                  controller: addCtr.deviceNameController,
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  label: 'owner_name_label'.tr,
                  hint: 'owner_name_hint'.tr,
                  icon: Icons.person_outline_rounded,
                  controller: addCtr.nameController,
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  label: 'phone_label'.tr,
                  hint: 'phone_hint'.tr,
                  icon: Icons.phone_outlined,
                  controller: addCtr.phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  label: 'email_label'.tr,
                  hint: 'email_hint'.tr,
                  icon: Icons.email_outlined,
                  controller: addCtr.emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  label: 'purchase_date_label'.tr,
                  hint: 'purchase_date_hint'.tr,
                  icon: Icons.calendar_today_rounded,
                  controller: addCtr.purchaseDateController,
                  readOnly: true,
                  suffixIcon: Icons.arrow_drop_down_rounded,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2010),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xff1B395B),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      addCtr.purchaseDateController.text =
                          '${pickedDate.year}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day.toString().padLeft(2, '0')}';
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildNextButton(
            label: 'next_step'.tr,
            icon: Icons.arrow_forward_rounded,
            onTap: () {
              if (addCtr.nameController.text.isNotEmpty &&
                  addCtr.phoneController.text.isNotEmpty) {
                homeCtr.stepForword(2);
              } else {
                Get.snackbar(
                  'warning'.tr,
                  'enter_owner_info_warning'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.shade50,
                  colorText: Colors.red.shade800,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                  icon: const Icon(Icons.warning_rounded, color: Colors.red),
                );
              }
            },
          ),
          const SizedBox(height: 15),
          _buildStepInfo(
            icon: Icons.info_outline_rounded,
            text: 'step_3_desc'.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    IconData? suffixIcon,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xff1B395B),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            style: const TextStyle(fontSize: 16, color: Color(0xff1B395B)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(
                icon,
                color: const Color(0xff1B395B).withValues(alpha: 0.5),
                size: 20,
              ),
              suffixIcon: suffixIcon != null
                  ? Icon(
                      suffixIcon,
                      color: const Color(0xff1B395B).withValues(alpha: 0.5),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---- الخطوة الثالثة: تأكيد وإرسال ----
class StepThreeContent extends StatelessWidget {
  final HomeCtr homeCtr;
  final AddCtr addCtr;

  const StepThreeContent({
    super.key,
    required this.homeCtr,
    required this.addCtr,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildStepTitle(
            icon: Icons.check_circle_outline_rounded,
            stepNumber: 'step_3'.tr,
            title: 'confirm_transfer_title'.tr,
          ),
          const SizedBox(height: 25),
          // ملخص البيانات
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'summary_title'.tr,
                  style: const TextStyle(
                    color: Color(0xff1B395B),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSummaryItem(
                  icon: Icons.sim_card_rounded,
                  title: 'IMEI',
                  value: addCtr.imeiController.text.isEmpty
                      ? '--'
                      : addCtr.imeiController.text,
                ),
                const Divider(height: 25),
                _buildSummaryItem(
                  icon: Icons.phone_android_rounded,
                  title: 'device_type'.tr,
                  value: addCtr.deviceNameController.text.isEmpty
                      ? '--'
                      : addCtr.deviceNameController.text,
                ),
                const Divider(height: 25),
                _buildSummaryItem(
                  icon: Icons.person_outline_rounded,
                  title: 'owner'.tr,
                  value: addCtr.nameController.text.isEmpty
                      ? '--'
                      : addCtr.nameController.text,
                ),
                const Divider(height: 25),
                _buildSummaryItem(
                  icon: Icons.phone_outlined,
                  title: 'phone_label'.tr,
                  value: addCtr.phoneController.text.isEmpty
                      ? '--'
                      : addCtr.phoneController.text,
                ),
                const Divider(height: 25),
                _buildSummaryItem(
                  icon: Icons.email_outlined,
                  title: 'email_label'.tr,
                  value: addCtr.emailController.text.isEmpty
                      ? '--'
                      : addCtr.emailController.text,
                ),
                const Divider(height: 25),
                _buildSummaryItem(
                  icon: Icons.calendar_today_rounded,
                  title: 'purchase_date'.tr,
                  value: addCtr.purchaseDateController.text.isEmpty
                      ? '--'
                      : addCtr.purchaseDateController.text,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // الموافقة على الشروط
          _buildTermsCheckbox(),
          const SizedBox(height: 30),
          // زر الإرسال
          _buildSubmitButton(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xffC39E3F).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xffC39E3F).withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: () => addCtr.isTermsAccepted.toggle(),
        borderRadius: BorderRadius.circular(15),
        child: Row(
          children: [
            const Icon(
              Icons.verified_user_rounded,
              color: Color(0xffC39E3F),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'terms_agree'.tr,
                style: const TextStyle(
                  color: Color(0xff1B395B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: addCtr.isTermsAccepted.value
                    ? const Color(0xffC39E3F)
                    : Colors.transparent,
                border: Border.all(color: const Color(0xffC39E3F), width: 2),
              ),
              child: addCtr.isTermsAccepted.value
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: addCtr.isTermsAccepted.value
                ? [const Color(0xff1B395B), const Color(0xff2C5282)]
                : [Colors.grey.shade400, Colors.grey.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: addCtr.isTermsAccepted.value
              ? [
                  BoxShadow(
                    color: const Color(0xff1B395B).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: addCtr.isTermsAccepted.value
                ? () => addCtr.submitToFirestore(context)
                : () {
                    Get.snackbar(
                      'warning'.tr,
                      'terms_warning'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.shade50,
                      colorText: Colors.red.shade800,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                      icon: const Icon(
                        Icons.warning_rounded,
                        color: Colors.red,
                      ),
                    );
                  },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (addCtr.isSubmitting.value)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.cloud_upload_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Text(
                    addCtr.isSubmitting.value
                        ? 'uploading'.tr
                        : 'upload_device'.tr,
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
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xff1B395B).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xff1B395B).withValues(alpha: 0.7),
            size: 20,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyles.myTextStyle(const Color(0xff1B395B), 16, true),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// ---- Shared Widgets ----
Widget _buildStepTitle({
  required IconData icon,
  required String stepNumber,
  required String title,
}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xff1B395B), Color(0xff2C5282)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: const Color(0xff1B395B).withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stepNumber,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: TextStyles.myTextStyle(Colors.white, 20, true),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildNextButton({
  required String label,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return Container(
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Text(
                label,
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

Widget _buildStepInfo({required IconData icon, required String text}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xffC39E3F).withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xffC39E3F).withValues(alpha: 0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xffC39E3F), size: 18),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xff1B395B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

// ---- AddCtr: Controller مع رفع إلى Firestore ----
class AddCtr extends GetxController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final purchaseDateController = TextEditingController();
  final imeiController = TextEditingController();
  final deviceNameController = TextEditingController();

  var isTermsAccepted = false.obs;
  var isSubmitting = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// رفع بيانات الهاتف إلى Firestore collection 'allphones'
  Future<void> submitToFirestore(BuildContext context) async {
    try {
      isSubmitting.value = true;

      final user = _auth.currentUser;
      final String ownerId = user?.uid ?? 'anonymous';

      final phoneData = {
        'imei': imeiController.text.trim(),
        'deviceName': deviceNameController.text.trim(),
        'brand': deviceNameController.text.trim(),
        'ownerName': nameController.text.trim(),
        'ownerPhone': phoneController.text.trim(),
        'ownerEmail': emailController.text.trim(),
        'purchaseDate': purchaseDateController.text.trim(),
        'ownerId': ownerId,
        'registeredAt': FieldValue.serverTimestamp(),
        'status': 'active',
      };

      await _firestore.collection('allphones').add(phoneData);

      // تنظيف الحقول
      _clearAll();

      if (context.mounted) {
        _showSuccessDialog(context);
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        '${'upload_device'.tr}: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _clearAll() {
    imeiController.clear();
    deviceNameController.clear();
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    purchaseDateController.clear();
    isTermsAccepted.value = false;
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xff128A3F), Color(0xff1AA550)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff128A3F).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                'upload_success'.tr,
                style: TextStyles.myTextStyle(
                  const Color(0xff1B395B),
                  24,
                  true,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'upload_success_desc'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xff1B395B), Color(0xff2C5282)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff1B395B).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Get.back();
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Center(
                        child: Text(
                          'back_to_my_phones'.tr,
                          style: TextStyles.myTextStyle(Colors.white, 18, true),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    purchaseDateController.dispose();
    imeiController.dispose();
    deviceNameController.dispose();
    super.onClose();
  }
}
