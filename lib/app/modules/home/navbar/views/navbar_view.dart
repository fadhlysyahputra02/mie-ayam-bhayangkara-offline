// lib/app/modules/navbar/views/navbar_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kasir_mie_ayamku/app/modules/home/database%20tampilan/views/database_view.dart';
import '../../antrean/views/antrean_view.dart';
import '../../menu/views/menu_view.dart';
import '../../riwayat/views/riwayat_view.dart';
import '../controllers/navbar_controller.dart';

class NavbarView extends StatelessWidget {
  final NavbarController controller = Get.find();

  final List<Widget> pages = [
    MenuView(),
    AntreanPage(),
    RiwayatView(),
    DatabaseView()
  ];

  @override
  Widget build(BuildContext context) {
  return Obx(() => Scaffold(
        body: pages[controller.selectedIndex.value],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 214, 153), // oranye pastel
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, -2), // shadow di atas navbar
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFFFFEBCD),
            selectedItemColor: const Color.fromARGB(255, 80, 80, 80),
            unselectedItemColor: const Color.fromARGB(255, 80, 80, 80),
            selectedFontSize: 14,
            unselectedFontSize: 13,
            elevation: 0,
            iconSize: 24, // ukuran default icon
            currentIndex: controller.selectedIndex.value,
            onTap: controller.changeTabIndex,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 24),
                activeIcon: Icon(Icons.home, size: 30), // lebih besar saat aktif
                label: "Menu",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu_outlined, size: 24),
                activeIcon: Icon(Icons.restaurant_menu, size: 30),
                label: "Antrean",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined, size: 24),
                activeIcon: Icon(Icons.receipt_long, size: 30),
                label: "Riwayat",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.storage_outlined, size: 24),
                activeIcon: Icon(Icons.storage, size: 30),
                label: "Database",
              ),
            ],
          ),
        ),
      ));
}


}
