// lib/app/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:kasir_mie_ayamku/app/modules/home/antrean/views/antrean_view.dart';
import 'package:kasir_mie_ayamku/app/modules/home/database%20tampilan/views/database_view.dart';
import 'package:kasir_mie_ayamku/app/modules/home/menu/binding/menu_binding.dart';
import 'package:kasir_mie_ayamku/app/modules/home/menu/views/menu_view.dart';
import 'package:kasir_mie_ayamku/app/modules/home/navbar/bindings/navbar_binding.dart';
import 'package:kasir_mie_ayamku/app/modules/home/navbar/views/navbar_view.dart';
import 'package:kasir_mie_ayamku/app/modules/home/riwayat/binding/riwayat_binding.dart';
import 'package:kasir_mie_ayamku/app/modules/home/riwayat/views/riwayat_view.dart';
import 'package:kasir_mie_ayamku/app/routes/app_rotes.dart';

import '../modules/home/antrean/binding/antrean_binding.dart';

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
