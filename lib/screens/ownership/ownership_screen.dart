import 'package:asly/controllers/home_ctr.dart';
import 'package:asly/screens/my_styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OwnershipScreen extends StatelessWidget {
  OwnershipScreen({super.key});
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
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Spacer(),
          Text(
            "إضافة جهاز جديد",
            style: TextStyles.myTextStyle(Colors.white, 24, true),
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
