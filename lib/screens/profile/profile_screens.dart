import 'package:asly/screens/my_styles/text_styles.dart';
import 'package:asly/controllers/root_ctr.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

class BodyBar extends StatelessWidget {
  const BodyBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (BuildContext context, int index) {
              return item();
            },
          ),
        ),
        InkWell(
          onTap: () {
            Get.toNamed("/addnew");
          },
          child: Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xff1B395B),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xff1B395B),
                  blurRadius: 1,
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(width: 1),
            ),
            child: Center(
              child: Text(
                "إضافة جهاز",
                style: TextStyles.myTextStyle(Colors.white, 20, true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget item() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Color(0xff1B395B), spreadRadius: 0.2, blurRadius: 1),
        ],
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Image.asset(
                  "assets/images/icon.png",
                  height: 100,
                  width: 60,
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 10,
                  children: [
                    Text(
                      "Samsung Galaxy s23",
                      style: TextStyles.myTextStyle(
                        const Color(0xff1B395B),
                        20,
                        true,
                      ),
                    ),
                    Text(
                      "imei: 123456789098765",
                      style: TextStyles.myTextStyle(
                        const Color(0xff1B395B),
                        16,
                        false,
                      ),
                    ),
                    Text(
                      "تاريخ التسجيل : 2024/05/15",
                      style: TextStyles.myTextStyle(
                        const Color(0xff1B395B),
                        16,
                        false,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 30,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "أمن",
                    style: TextStyles.myTextStyle(Colors.white, 16, true),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 10),

              Expanded(
                child: InkWell(
                  onTap: () => Get.toNamed("/ownership"),
                  child: Container(
                    height: 40,
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        width: 2,
                        color: Color(0xff1B395B).withAlpha(100),
                      ),
                    ),
                    child: Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_rounded, color: Colors.red),
                        Text(
                          "بلاغ سرقة",
                          style: TextStyles.myTextStyle(Colors.red, 16, true),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 30),

              Expanded(
                child: InkWell(
                  onTap: () => Get.toNamed("/ownership"),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        width: 2,
                        color: Color(0xff1B395B).withAlpha(100),
                      ),
                    ),
                    child: Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.move_down_sharp,
                          color: Color.fromARGB(255, 77, 139, 209),
                        ),
                        Text(
                          "نقل ملكية",
                          style: TextStyles.myTextStyle(
                            Color.fromARGB(255, 77, 139, 209),
                            16,
                            true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }
}
