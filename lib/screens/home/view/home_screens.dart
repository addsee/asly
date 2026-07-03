import 'package:asly/app/app_colors.dart';
import 'package:asly/screens/home/view/widgets/body_bar.dart';
import 'package:asly/screens/my_styles/text_styles.dart';
import 'package:flutter/material.dart';

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
