import 'package:asly/controllers/home_ctr.dart';
import 'package:asly/screens/home/home_screens.dart';
import 'package:asly/screens/profile/profile_screens.dart';
import 'package:asly/controllers/root_ctr.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RootScreen extends StatelessWidget {
  RootScreen({super.key});
  final RootCtr rootCtr = Get.put(RootCtr());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomBar(),
      body: Obx(
        () => PageView(
          physics: AlwaysScrollableScrollPhysics(),
          onPageChanged: (value) {
            rootCtr.bottomNav(value);
            final homeCtr = Get.find<HomeCtr>();
            if (homeCtr.isCameraActive.value) {
              homeCtr.toggleCamera();
            }
          },
          controller: rootCtr.pageController.value,
          children: [ProfileScreens(), HomeScreens()],
        ),
      ),
    );
  }

  Widget bottomBar() {
    return Obx(
      () => BottomNavigationBar(
        onTap: (value) => rootCtr.bottomNav(value),
        currentIndex: rootCtr.currentScreen.value,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_android_outlined),
            label: "تلفوناتي",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئسية"),
        ],
      ),
    );
  }
}
