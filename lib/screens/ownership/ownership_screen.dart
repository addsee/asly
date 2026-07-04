import 'package:asly/controllers/home_ctr.dart';
import 'package:asly/screens/my_styles/text_styles.dart';
import 'package:asly/widgets/top_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OwnershipScreen extends StatelessWidget {
  OwnershipScreen({super.key});
  final HomeCtr homeCtr = Get.find<HomeCtr>();
  final OwnershipCtr ownershipCtr = Get.put(OwnershipCtr());

  @override
  Widget build(BuildContext context) {
    // تحميل بيانات الهاتف المختار إن وُجدت
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && ownershipCtr.selectedPhone.value == null) {
      ownershipCtr.selectPhone(args['docId'] as String, args['data'] as Map<String, dynamic>);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FC),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              TopBar(
                showBackButton: true,
                title: 'نقل الملكية',
                onTap: () {
                  if (homeCtr.step.value == 0) {
                    Get.back();
                  } else {
                    homeCtr.stepForword(homeCtr.step.value - 1);
                  }
                },
              ),
              const SizedBox(height: 10),
              Obx(() => _StepIndicator(currentStep: homeCtr.step.value + 1)),
              Expanded(
                child: PageView(
                  controller: homeCtr.stepCtr,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (value) => homeCtr.stepForword(value),
                  children: [
                    _StepOneContent(
                        homeCtr: homeCtr, ownershipCtr: ownershipCtr),
                    _StepTwoContent(
                        homeCtr: homeCtr, ownershipCtr: ownershipCtr),
                    _StepThreeContent(
                        homeCtr: homeCtr, ownershipCtr: ownershipCtr),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- مؤشر الخطوات ----
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

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
          _buildStepCircle(1, currentStep, 'الجهاز'),
          Expanded(child: _buildStepLine(1, currentStep)),
          _buildStepCircle(2, currentStep, 'المالك الجديد'),
          Expanded(child: _buildStepLine(2, currentStep)),
          _buildStepCircle(3, currentStep, 'تأكيد'),
          const SizedBox(width: 20),
        ],
      ),
    );
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
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
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

// ---- الخطوة الأولى: اختيار الجهاز من القائمة ----
class _StepOneContent extends StatelessWidget {
  final HomeCtr homeCtr;
  final OwnershipCtr ownershipCtr;

  const _StepOneContent(
      {required this.homeCtr, required this.ownershipCtr});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // عنوان الخطوة
          _buildStepTitle(
            icon: Icons.phone_android_rounded,
            stepNumber: 'الخطوة الأولى',
            title: 'اختر الجهاز المراد نقله',
          ),
          const SizedBox(height: 20),

          // إن كان قادماً من هواتفي بجهاز محدد
          Obx(() {
            if (ownershipCtr.selectedPhone.value != null) {
              return _SelectedPhoneCard(ownershipCtr: ownershipCtr);
            }
            // عرض قائمة الهواتف
            if (user == null) {
              return _buildNotLoggedIn();
            }
            return _PhonesListPicker(
              userId: user.uid,
              ownershipCtr: ownershipCtr,
            );
          }),

          const SizedBox(height: 30),
          // زر التالي
          Obx(
            () => _buildNextButton(
              label: 'الخطوة التالية',
              icon: Icons.arrow_forward_rounded,
              enabled: ownershipCtr.selectedPhone.value != null,
              onTap: () {
                if (ownershipCtr.selectedPhone.value != null) {
                  homeCtr.stepForword(1);
                } else {
                  Get.snackbar(
                    'تنبيه',
                    'الرجاء اختيار الجهاز المراد نقل ملكيته',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.shade50,
                    colorText: Colors.red.shade800,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                    icon:
                        const Icon(Icons.warning_rounded, color: Colors.red),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 15),
          _buildStepInfo(
            icon: Icons.info_outline_rounded,
            text: 'الخطوة الثانية: معلومات المالك الجديد',
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'يجب تسجيل الدخول لاختيار الجهاز',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedPhoneCard extends StatelessWidget {
  final OwnershipCtr ownershipCtr;
  const _SelectedPhoneCard({required this.ownershipCtr});

  @override
  Widget build(BuildContext context) {
    final data = ownershipCtr.selectedPhone.value!;
    final deviceName = data['deviceName'] ?? data['brand'] ?? 'جهاز';
    final imei = data['imei'] ?? '--';

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
            color: const Color(0xff1B395B).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.phone_android_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deviceName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'IMEI: $imei',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // زر تغيير الاختيار
              IconButton(
                onPressed: () => ownershipCtr.clearSelection(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                tooltip: 'تغيير الجهاز',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xffC39E3F),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'تم اختيار الجهاز بنجاح',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
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

class _PhonesListPicker extends StatelessWidget {
  final String userId;
  final OwnershipCtr ownershipCtr;

  const _PhonesListPicker(
      {required this.userId, required this.ownershipCtr});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('allphones')
          .where('ownerId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xff1B395B)),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'لا توجد هواتف مسجلة باسمك',
                style: TextStyle(
                  color: Color(0xff1B395B),
                  fontSize: 16,
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اختر الجهاز:',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ...docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final deviceName = data['deviceName'] ?? data['brand'] ?? 'جهاز';
              final imei = data['imei'] ?? '--';

              return Obx(
                () => GestureDetector(
                  onTap: () => ownershipCtr.selectPhone(doc.id, data),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ownershipCtr.selectedDocId.value == doc.id
                          ? const Color(0xff1B395B).withValues(alpha: 0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ownershipCtr.selectedDocId.value == doc.id
                            ? const Color(0xff1B395B)
                            : Colors.grey.shade200,
                        width:
                            ownershipCtr.selectedDocId.value == doc.id ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xff1B395B)
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.phone_android_rounded,
                            color: Color(0xff1B395B),
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                deviceName,
                                style: const TextStyle(
                                  color: Color(0xff1B395B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'IMEI: $imei',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (ownershipCtr.selectedDocId.value == doc.id)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xff1B395B),
                            size: 26,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

// ---- الخطوة الثانية: معلومات المالك الجديد ----
class _StepTwoContent extends StatelessWidget {
  final HomeCtr homeCtr;
  final OwnershipCtr ownershipCtr;

  const _StepTwoContent(
      {required this.homeCtr, required this.ownershipCtr});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildStepTitle(
            icon: Icons.person_outline_rounded,
            stepNumber: 'الخطوة الثانية',
            title: 'معلومات المالك الجديد',
          ),
          const SizedBox(height: 25),
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
                _buildInputField(
                  label: 'الاسم الكامل للمالك الجديد',
                  hint: 'أدخل الاسم الكامل',
                  icon: Icons.person_outline_rounded,
                  controller: ownershipCtr.newOwnerNameController,
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  label: 'رقم الهاتف',
                  hint: 'أدخل رقم الهاتف',
                  icon: Icons.phone_outlined,
                  controller: ownershipCtr.newOwnerPhoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  label: 'البريد الإلكتروني',
                  hint: 'أدخل البريد الإلكتروني',
                  icon: Icons.email_outlined,
                  controller: ownershipCtr.newOwnerEmailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  label: 'تاريخ النقل',
                  hint: 'اختر تاريخ نقل الملكية',
                  icon: Icons.calendar_today_rounded,
                  controller: ownershipCtr.transferDateController,
                  readOnly: true,
                  suffixIcon: Icons.arrow_drop_down_rounded,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2010),
                      lastDate: DateTime(2030),
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
                      ownershipCtr.transferDateController.text =
                          '${pickedDate.year}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day.toString().padLeft(2, '0')}';
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildNextButton(
            label: 'الخطوة التالية',
            icon: Icons.arrow_forward_rounded,
            enabled: true,
            onTap: () {
              if (ownershipCtr.newOwnerNameController.text.isNotEmpty &&
                  ownershipCtr.newOwnerPhoneController.text.isNotEmpty) {
                homeCtr.stepForword(2);
              } else {
                Get.snackbar(
                  'تنبيه',
                  'الرجاء إدخال الاسم ورقم الهاتف',
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
            text: 'الخطوة الثالثة: تأكيد نقل الملكية',
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
              hintStyle:
                  TextStyle(color: Colors.grey.shade400, fontSize: 14),
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

// ---- الخطوة الثالثة: تأكيد نقل الملكية ----
class _StepThreeContent extends StatelessWidget {
  final HomeCtr homeCtr;
  final OwnershipCtr ownershipCtr;

  const _StepThreeContent(
      {required this.homeCtr, required this.ownershipCtr});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildStepTitle(
            icon: Icons.check_circle_outline_rounded,
            stepNumber: 'الخطوة الثالثة',
            title: 'تأكيد نقل الملكية',
          ),
          const SizedBox(height: 25),
          // ملخص
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
                const Text(
                  'ملخص نقل الملكية',
                  style: TextStyle(
                    color: Color(0xff1B395B),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // بيانات الجهاز
                Obx(() {
                  final phone = ownershipCtr.selectedPhone.value;
                  if (phone == null) return const SizedBox.shrink();
                  return Column(
                    children: [
                      _buildSummarySection(
                        title: 'الجهاز',
                        color: const Color(0xff1B395B),
                        items: [
                          _SummaryItem(
                            icon: Icons.phone_android_rounded,
                            label: 'الجهاز',
                            value: phone['deviceName'] ??
                                phone['brand'] ??
                                'غير متوفر',
                          ),
                          _SummaryItem(
                            icon: Icons.sim_card_rounded,
                            label: 'IMEI',
                            value: phone['imei'] ?? 'غير متوفر',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),
                _buildSummarySection(
                  title: 'المالك الجديد',
                  color: const Color(0xff4D8BD1),
                  items: [
                    Obx(
                      () => _SummaryItem(
                        icon: Icons.person_rounded,
                        label: 'الاسم',
                        value: ownershipCtr.newOwnerNameController.text.isEmpty
                            ? 'غير متوفر'
                            : ownershipCtr.newOwnerNameController.text,
                      ),
                    ),
                    Obx(
                      () => _SummaryItem(
                        icon: Icons.phone_outlined,
                        label: 'رقم الهاتف',
                        value:
                            ownershipCtr.newOwnerPhoneController.text.isEmpty
                                ? 'غير متوفر'
                                : ownershipCtr.newOwnerPhoneController.text,
                      ),
                    ),
                    Obx(
                      () => _SummaryItem(
                        icon: Icons.email_outlined,
                        label: 'البريد',
                        value:
                            ownershipCtr.newOwnerEmailController.text.isEmpty
                                ? 'غير متوفر'
                                : ownershipCtr.newOwnerEmailController.text,
                      ),
                    ),
                    Obx(
                      () => _SummaryItem(
                        icon: Icons.calendar_today_rounded,
                        label: 'تاريخ النقل',
                        value: ownershipCtr.transferDateController.text.isEmpty
                            ? 'غير متوفر'
                            : ownershipCtr.transferDateController.text,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // تحذير
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'تأكد من صحة البيانات قبل الإرسال، لا يمكن التراجع عن نقل الملكية',
                    style: TextStyle(
                      color: Color(0xff1B395B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // زر إرسال
          Obx(() => _buildSubmitBtn(context)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummarySection({
    required String title,
    required Color color,
    required List<Widget> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSubmitBtn(BuildContext context) {
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
          onTap: ownershipCtr.isSubmitting.value
              ? null
              : () => ownershipCtr.transferOwnership(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (ownershipCtr.isSubmitting.value)
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
                      Icons.swap_horiz_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                const SizedBox(width: 12),
                Text(
                  ownershipCtr.isSubmitting.value
                      ? 'جارٍ النقل...'
                      : 'تأكيد نقل الملكية',
                  style: TextStyles.myTextStyle(Colors.white, 20, true)
                      ?.copyWith(letterSpacing: 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---- Widget مساعد ----
class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xff1B395B).withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xff1B395B),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
  bool enabled = true,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        colors: enabled
            ? [const Color(0xff1B395B), const Color(0xff2C5282)]
            : [Colors.grey.shade400, Colors.grey.shade300],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: enabled
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
                style: TextStyles.myTextStyle(Colors.white, 20, true)
                    ?.copyWith(letterSpacing: 1),
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
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xffC39E3F).withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(15),
      border:
          Border.all(color: const Color(0xffC39E3F).withValues(alpha: 0.2)),
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

// ---- OwnershipCtr ----
class OwnershipCtr extends GetxController {
  var selectedPhone = Rxn<Map<String, dynamic>>();
  var selectedDocId = ''.obs;
  var isSubmitting = false.obs;

  final newOwnerNameController = TextEditingController();
  final newOwnerPhoneController = TextEditingController();
  final newOwnerEmailController = TextEditingController();
  final transferDateController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void selectPhone(String docId, Map<String, dynamic> data) {
    selectedDocId.value = docId;
    selectedPhone.value = data;
  }

  void clearSelection() {
    selectedDocId.value = '';
    selectedPhone.value = null;
  }

  Future<void> transferOwnership(BuildContext context) async {
    if (selectedDocId.value.isEmpty) return;

    try {
      isSubmitting.value = true;
      final user = _auth.currentUser;

      // تحديث بيانات الجهاز في Firestore
      await _firestore.collection('allphones').doc(selectedDocId.value).update({
        'ownerName': newOwnerNameController.text.trim(),
        'ownerPhone': newOwnerPhoneController.text.trim(),
        'ownerEmail': newOwnerEmailController.text.trim(),
        'previousOwnerId': user?.uid ?? '',
        'ownerId': '', // إزالة ربط الجهاز بالحساب القديم
        'transferDate': transferDateController.text.trim(),
        'transferredAt': FieldValue.serverTimestamp(),
        'status': 'transferred',
      });

      // تسجيل سجل النقل
      await _firestore.collection('ownership_history').add({
        'phoneDocId': selectedDocId.value,
        'imei': selectedPhone.value?['imei'] ?? '',
        'fromOwnerId': user?.uid ?? '',
        'fromOwnerName': selectedPhone.value?['ownerName'] ?? '',
        'toOwnerName': newOwnerNameController.text.trim(),
        'toOwnerPhone': newOwnerPhoneController.text.trim(),
        'toOwnerEmail': newOwnerEmailController.text.trim(),
        'transferDate': transferDateController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _clearFields();

      if (context.mounted) {
        _showSuccessDialog(context);
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل نقل الملكية: $e',
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

  void _clearFields() {
    newOwnerNameController.clear();
    newOwnerPhoneController.clear();
    newOwnerEmailController.clear();
    transferDateController.clear();
    clearSelection();
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
                    colors: [Color(0xff4D8BD1), Color(0xff2C5282)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff4D8BD1).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                'تم نقل الملكية!',
                style: TextStyles.myTextStyle(
                  const Color(0xff1B395B),
                  24,
                  true,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'تم نقل ملكية الجهاز بنجاح\nوتسجيل العملية في سجل المعاملات',
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
                          'العودة لهواتفي',
                          style:
                              TextStyles.myTextStyle(Colors.white, 18, true),
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
    newOwnerNameController.dispose();
    newOwnerPhoneController.dispose();
    newOwnerEmailController.dispose();
    transferDateController.dispose();
    super.onClose();
  }
}
