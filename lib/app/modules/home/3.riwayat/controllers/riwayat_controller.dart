// // lib/app/modules/menu/controllers/menu_controller.dart
// import 'package:get/get.dart';
// import '../../../../data/local/database_helper.dart';

// class RiwayatController extends GetxController {
//   var menus = <Map<String, dynamic>>[].obs;
//   final dbHelper = DatabaseHelper.instance;

//   @override
//   void onInit() {
//     super.onInit();
//     loadMenus();
//   }

//   Future<void> loadMenus() async {
//     menus.value = await dbHelper.getMenus();
//   }

//   Future<void> addMenu(String nama, int harga) async {
//     await dbHelper.insertMenu({"nama": nama, "harga": harga});
//     loadMenus();
//   }

//   Future<void> deleteMenu(int id) async {
//     await dbHelper.deleteMenu(id);
//     loadMenus();
//   }
// }
