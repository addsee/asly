// lib/screens/profile_screens.dart
import 'package:asly/controllers/auth_ctr.dart';
import 'package:asly/controllers/root_ctr.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ==================== الشاشة الرئيسية ====================
class ProfileScreens extends StatelessWidget {
  ProfileScreens({super.key});
  final RootCtr rootCtr = Get.find<RootCtr>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FC),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [Expanded(child: _ProfileBody(rootCtr: rootCtr))],
          ),
        ),
      ),
    );
  }
}

// ==================== المحتوى الرئيسي ====================
class _ProfileBody extends StatelessWidget {
  final RootCtr rootCtr;
  const _ProfileBody({required this.rootCtr});

  @override
  Widget build(BuildContext context) {
    final AuthCtr authCtr = Get.find<AuthCtr>();
    return Obx(() {
      final user = authCtr.currentUser.value;
      if (user == null) return const _LoginPrompt();
      return _AuthenticatedView(user: user, rootCtr: rootCtr);
    });
  }
}

// ==================== شاشة تسجيل الدخول ====================
class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildLogoIcon(),
          const SizedBox(height: 32),
          _buildTitleText(),
          const SizedBox(height: 12),
          _buildDescriptionText(),
          const SizedBox(height: 48),
          const _GoogleSignInButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLogoIcon() {
    return Container(
      height: 130,
      width: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xff1B395B), Color(0xff2C5282)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1B395B).withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.phone_android_rounded,
        color: Colors.white,
        size: 65,
      ),
    );
  }

  Widget _buildTitleText() {
    return Text(
      'login_to_view_phones'.tr,
      style: const TextStyle(
        color: Color(0xff1B395B),
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescriptionText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'login_desc'.tr,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 16,
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ==================== زر تسجيل الدخول بقوقل ====================
class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton();

  @override
  Widget build(BuildContext context) {
    final AuthCtr authCtr = Get.find<AuthCtr>();
    return Obx(() {
      final isLoading = authCtr.isLoading.value;
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : authCtr.signInWithGoogle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xff1B395B),
                      ),
                    )
                  else ...[
                    _buildGoogleIcon(),
                    const SizedBox(width: 14),
                    Text(
                      'login_google'.tr,
                      style: const TextStyle(
                        color: Color(0xff1B395B),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
        ],
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Color(0xff4285F4),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ==================== واجهة المستخدم المسجل ====================
class _AuthenticatedView extends StatelessWidget {
  final User user;
  final RootCtr rootCtr;
  const _AuthenticatedView({required this.user, required this.rootCtr});

  @override
  Widget build(BuildContext context) {
    final AuthCtr authCtr = Get.find<AuthCtr>();
    return Column(
      children: [
        _UserInfoCard(user: user, onLogout: authCtr.signOut),
        Expanded(child: _PhonesListSection(user: user)),
        const _AddDeviceButton(),
      ],
    );
  }
}

// ==================== بطاقة معلومات المستخدم ====================
class _UserInfoCard extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;
  const _UserInfoCard({required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff1B395B), Color(0xff2C5282)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1B395B).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // معلومات المستخدم
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 14),
                Expanded(child: _buildUserInfo()),
              ],
            ),
          ),
          // زر السحب لتسجيل الخروج
          _SlideToLogoutButton(onLogout: onLogout),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final initial = (user.displayName?.isNotEmpty == true)
        ? user.displayName![0].toUpperCase()
        : (user.email?.isNotEmpty == true)
        ? user.email![0].toUpperCase()
        : '?';
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.displayName ?? 'user'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          user.email ?? '',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ==================== زر السحب لتسجيل الخروج ====================
class _SlideToLogoutButton extends StatefulWidget {
  final VoidCallback onLogout;
  const _SlideToLogoutButton({required this.onLogout});

  @override
  State<_SlideToLogoutButton> createState() => _SlideToLogoutButtonState();
}

class _SlideToLogoutButtonState extends State<_SlideToLogoutButton>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  bool _isCompleted = false;

  late AnimationController _vibrateController;

  @override
  void initState() {
    super.initState();
    _vibrateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );
    _vibrateController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _vibrateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // العرض المتاح للسحب = عرض الحاوية - عرض الزر
        final maxDrag = constraints.maxWidth - 80;
        // حساب نسبة التقدم
        final progress = maxDrag > 0
            ? (_dragPosition / maxDrag).clamp(0.0, 1.0)
            : 0.0;

        // الألوان بناءً على نسبة التقدم
        final bgColor = Color.lerp(
          Colors.white.withValues(alpha: 0.15),
          Colors.red.withValues(alpha: 0.3),
          progress,
        )!;

        final borderColor = Color.lerp(
          Colors.white.withValues(alpha: 0.2),
          Colors.red.withValues(alpha: 0.6),
          progress,
        )!;

        final textColor = Color.lerp(
          Colors.white.withValues(alpha: 0.8),
          Colors.red.shade100,
          progress,
        )!;

        final iconColor = Color.lerp(
          const Color(0xff1B395B),
          Colors.red,
          progress,
        )!;

        return Container(
          height: 55,
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: progress > 0.7 ? 2 : 1.5,
            ),
          ),
          child: Stack(
            children: [
              // النص في الخلفية
              Center(
                child: AnimatedOpacity(
                  opacity: progress > 0.7 ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: progress > 0.4
                      ? _buildWarningText(textColor)
                      : _buildNormalText(textColor),
                ),
              ),
              // الزر القابل للسحب - باستخدام Positioned عشان يتحرك بحرية
              Positioned(
                left: progress > 0.99 ? maxDrag : _dragPosition,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (!_isCompleted) {
                      setState(() {
                        _dragPosition += details.delta.dx;
                        if (_dragPosition < 0) _dragPosition = 0;
                        if (_dragPosition > maxDrag) _dragPosition = maxDrag;
                      });

                      // تفعيل الاهتزاز عند الاقتراب من النهاية
                      if (progress > 0.8 && !_vibrateController.isAnimating) {
                        _vibrateController.repeat(reverse: true);
                      } else if (progress <= 0.8 &&
                          _vibrateController.isAnimating) {
                        _vibrateController.stop();
                        _vibrateController.reset();
                      }
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    if (_vibrateController.isAnimating) {
                      _vibrateController.stop();
                      _vibrateController.reset();
                    }
                    if (progress >= 0.95) {
                      // اكتمل السحب
                      setState(() {
                        _isCompleted = true;
                        _dragPosition = maxDrag;
                      });
                      // تنفيذ تسجيل الخروج بعد تأخير بسيط
                      Future.delayed(const Duration(milliseconds: 400), () {
                        widget.onLogout();
                      });
                    } else {
                      // إعادة الزر لمكانه
                      setState(() {
                        _dragPosition = 0;
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 55,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: progress > 0.7
                            ? [Colors.red.shade300, Colors.red.shade500]
                            : progress > 0.4
                            ? [Colors.orange.shade200, Colors.orange.shade400]
                            : [
                                Colors.white,
                                Colors.white.withValues(alpha: 0.9),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: progress > 0.7
                              ? Colors.red.withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.2),
                          blurRadius: progress > 0.7 ? 12 : 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 24,
                              key: ValueKey('check'),
                            )
                          : progress > 0.7
                          ? const Icon(
                              Icons.warning_rounded,
                              color: Colors.white,
                              size: 24,
                              key: ValueKey('warning'),
                            )
                          : Icon(
                              Icons.logout_rounded,
                              color: iconColor,
                              size: 24,
                              key: ValueKey('logout'),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNormalText(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      key: const ValueKey('normal'),
      children: [
        Icon(Icons.swipe_rounded, color: textColor, size: 20),
        const SizedBox(width: 8),
        Text(
          'slide_to_logout'.tr,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWarningText(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      key: const ValueKey('warning'),
      children: [
        Icon(Icons.warning_amber_rounded, color: Colors.red.shade200, size: 20),
        const SizedBox(width: 8),
        Text(
          'release_to_logout'.tr,
          style: TextStyle(
            color: Colors.red.shade200,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ==================== قسم قائمة الهواتف ====================
class _PhonesListSection extends StatelessWidget {
  final User user;
  const _PhonesListSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('allphones')
          .where('ownerId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // حالة التحميل
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xff1B395B)),
          );
        }

        // حالة الخطأ
        if (snapshot.hasError) {
          print("------------> snapshot.error ${snapshot.error}");
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'search_error_occurred'.tr,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        // حالة عدم وجود بيانات
        if (docs.isEmpty) {
          return const _EmptyPhonesPlaceholder();
        }

        // عرض القائمة
        return ListView.builder(
          padding: const EdgeInsets.only(top: 12, bottom: 10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _ModernDeviceItem(
              data: data,
              docId: docs[index].id,
              index: index,
            );
          },
        );
      },
    );
  }
}

// ==================== حالة عدم وجود هواتف ====================
class _EmptyPhonesPlaceholder extends StatelessWidget {
  const _EmptyPhonesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xff1B395B).withValues(alpha: 0.05),
              border: Border.all(
                color: const Color(0xff1B395B).withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.phone_android_outlined,
              size: 70,
              color: const Color(0xff1B395B).withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'no_phones_yet'.tr,
            style: const TextStyle(
              color: Color(0xff1B395B),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'add_phone_desc'.tr,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ==================== زر إضافة جهاز ====================
class _AddDeviceButton extends StatelessWidget {
  const _AddDeviceButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(right: 50, left: 50, bottom: 10),
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
          onTap: () => Get.toNamed('/addnew'),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle_outline_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'add_new_device'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== بطاقة الجهاز ====================
class _ModernDeviceItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final int index;

  const _ModernDeviceItem({
    required this.data,
    required this.docId,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final deviceName = data['deviceName'] ?? data['brand'] ?? 'device'.tr;
    final imei = data['imei'] ?? '--';
    final ownerName = data['ownerName'] ?? '';
    final purchaseDate = data['purchaseDate'] ?? '--';
    final status = data['status'] ?? 'active';

    return _AnimatedListItem(
      index: index,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xff1B395B).withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff1B395B).withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            _DeviceHeader(
              deviceName: deviceName,
              status: status,
              imei: imei,
              ownerName: ownerName,
              purchaseDate: purchaseDate,
            ),
            const SizedBox(height: 16),
            const _DividerWithGradient(),
            const SizedBox(height: 16),
            _DeviceActions(docId: docId, data: data),
          ],
        ),
      ),
    );
  }
}

// ==================== أنيميشن العناصر ====================
class _AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedListItem({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOutBack,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value.clamp(0.0, 1.0),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: child,
    );
  }
}

// ==================== رأس بطاقة الجهاز ====================
class _DeviceHeader extends StatelessWidget {
  final String deviceName;
  final String status;
  final String imei;
  final String ownerName;
  final String purchaseDate;

  const _DeviceHeader({
    required this.deviceName,
    required this.status,
    required this.imei,
    required this.ownerName,
    required this.purchaseDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDeviceIcon(),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleRow(),
              const SizedBox(height: 12),
              _buildInfoChip(Icons.sim_card_rounded, 'IMEI: $imei'),
              if (ownerName.isNotEmpty) ...[
                const SizedBox(height: 7),
                _buildInfoChip(Icons.person_rounded, ownerName),
              ],
              const SizedBox(height: 7),
              _buildInfoChip(
                Icons.calendar_today_rounded,
                '${'purchase_date'.tr}: $purchaseDate',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceIcon() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xff1B395B).withValues(alpha: 0.05),
            const Color(0xff1B395B).withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xff1B395B).withValues(alpha: 0.1),
        ),
      ),
      child: const Icon(
        Icons.phone_android_rounded,
        size: 38,
        color: Color(0xff1B395B),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            deviceName,
            style: const TextStyle(
              color: Color(0xff1B395B),
              fontSize: 19,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        _StatusBadge(status: status),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xff1B395B).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: const Color(0xff1B395B).withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xff1B395B), fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== شارة الحالة ====================
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isStolen = status == 'stolen';
    final colors = isStolen
        ? [Colors.red, Colors.red.shade700]
        : [const Color(0xff128A3F), const Color(0xff1AA550)];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isStolen ? Colors.red : const Color(0xff128A3F)).withValues(
              alpha: 0.3,
            ),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isStolen ? Icons.warning_rounded : Icons.shield_rounded,
            color: Colors.white,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            isStolen ? 'stolen'.tr : 'secure'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== فاصل بتدرج ====================
class _DividerWithGradient extends StatelessWidget {
  const _DividerWithGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xff1B395B).withValues(alpha: 0.12),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ==================== أزرار الإجراءات ====================
class _DeviceActions extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  const _DeviceActions({required this.docId, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.warning_rounded,
            label: 'report_stolen'.tr,
            color: Colors.red,
            onTap: () => _showStolenDialog(context),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _ActionButton(
            icon: Icons.swap_horiz_rounded,
            label: 'transfer_ownership'.tr,
            color: const Color(0xff4D8BD1),
            onTap: () => Get.toNamed(
              '/ownership',
              arguments: {'docId': docId, 'data': data},
            ),
          ),
        ),
      ],
    );
  }

  void _showStolenDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text('stolen_report_title'.tr),
          ],
        ),
        content: Text(
          'stolen_report_confirm'.tr,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('allphones')
                    .doc(docId)
                    .update({'status': 'stolen'});
                Get.back();
                Get.snackbar(
                  'done'.tr,
                  'stolen_report_success'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.shade50,
                  colorText: Colors.red.shade800,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                  duration: const Duration(seconds: 3),
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.red,
                  ),
                );
              } catch (e) {
                Get.back();
                Get.snackbar(
                  'error'.tr,
                  'operation_failed'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.shade50,
                  colorText: Colors.red.shade800,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              }
            },
            child: Text(
              'confirm'.tr,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== زر إجراء ====================
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
