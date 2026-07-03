import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RootCtr extends GetxController {
  Rx<PageController> pageController = PageController(initialPage: 1).obs;
  var currentScreen = 1.obs;
  void bottomNav(int value) {
    currentScreen.value = value;
    pageController.value.animateToPage(
      value,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }
}
