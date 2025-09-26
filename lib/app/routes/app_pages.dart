// lib/app/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:kasir_mie_ayamku/app/modules/home/2.antrean/views/antrean_view.dart';
import 'package:kasir_mie_ayamku/app/modules/home/4.database%20tampilan/views/database_view.dart';
import 'package:kasir_mie_ayamku/app/modules/home/1.menu/binding/menu_binding.dart';
import 'package:kasir_mie_ayamku/app/modules/home/1.menu/views/menu_view.dart';
import 'package:kasir_mie_ayamku/app/modules/home/0.navbar/bindings/navbar_binding.dart';
import 'package:kasir_mie_ayamku/app/modules/home/0.navbar/views/navbar_view.dart';
import 'package:kasir_mie_ayamku/app/modules/home/3.riwayat/binding/riwayat_binding.dart';
import 'package:kasir_mie_ayamku/app/modules/home/3.riwayat/views/riwayat_view.dart';
import 'package:kasir_mie_ayamku/app/routes/app_rotes.dart';

import '../modules/home/2.antrean/binding/antrean_binding.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.NAVBAR,
      page: () => NavbarView(),
      binding: NavbarBinding(),
    ),
    GetPage(
      name: AppRoutes.MENU,
      page: () => MenuView(),
      //binding: MenuBinding(),
    ),
    GetPage(
      name: AppRoutes.ANTREAN,
      page: () => AntreanPage(),
      //binding: AntreanBinding(),
    ),
    GetPage(
      name: AppRoutes.RIWAYAT,
      page: () => RiwayatView(),
      //binding: RiwayatBinding(),
    ),

    GetPage(
      name: AppRoutes.DATABASE,
      page: () => DatabaseView(),
      //binding: RiwayatBinding(),
    ),
    
  ];
}
