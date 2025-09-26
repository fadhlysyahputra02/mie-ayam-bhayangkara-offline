// lib/app/modules/navbar/controllers/navbar_controller.dart
import 'package:get/get.dart';

class NavbarController extends GetxController {
  var selectedIndex = 0.obs;

  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }
}
