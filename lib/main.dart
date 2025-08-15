// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_rotes.dart';

void main() {
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
