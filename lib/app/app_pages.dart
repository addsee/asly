import 'package:asly/app/app_routes.dart';
import 'package:asly/screens/addnew/view/add_new.dart';
import 'package:asly/screens/home/view/home_screens.dart';
import 'package:asly/screens/ownership/view/ownership_screen.dart';
import 'package:asly/screens/root/view/root_screen.dart';
import 'package:get/get.dart';

class AppPages {
  static var pages = [
    GetPage(name: AppRoutes.root, page: () => RootScreen()),
    GetPage(name: AppRoutes.home, page: () => HomeScreens()),
    GetPage(name: AppRoutes.ownership, page: () => OwnershipScreen()),
    GetPage(name: AppRoutes.addnew, page: () => AddNew()),
  ];
}
