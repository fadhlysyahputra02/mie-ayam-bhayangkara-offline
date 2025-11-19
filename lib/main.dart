// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_rotes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id'); // inisialisasi bahasa Indonesia
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kasir Mie Ayam',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.NAVBAR,
      getPages: AppPages.routes,
    );
  }
}
