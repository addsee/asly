import 'package:asly/screens/my_styles/text_styles.dart';
import 'package:asly/screens/profile/view/widgets/body_bar.dart';
import 'package:asly/screens/root/controllers/root_ctr.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

class ProfileScreens extends StatelessWidget {
  final RootCtr rootCtr = Get.put(RootCtr());
  ProfileScreens({super.key});
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
      color: const Color(0xff1B395B),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              rootCtr.bottomNav(1);
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          ),
          Spacer(),
          Text(
            "هواتفي المسجله",
            style: TextStyles.myTextStyle(Colors.white, 24, true),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
