// import 'package:flutter/material.dart';
// import '../../../../data/local/database_helper.dart';
// import '../../../../data/menu_data.dart';

// class MenuController extends ChangeNotifier {
//   List<int> qtyMakanan = [];
//   List<int> qtyMinuman = [];

//   MenuController() {
//     qtyMakanan = List.filled(menuMakanan.length, 0);
//     qtyMinuman = List.filled(menuMinuman.length, 0);
//   }

//   void addMakanan(int index) {
//     qtyMakanan[index]++;
//     notifyListeners();
//   }

//   void removeMakanan(int index) {
//     if (qtyMakanan[index] > 0) {
//       qtyMakanan[index]--;
//       notifyListeners();
//     }
//   }

//   void addMinuman(int index) {
//     qtyMinuman[index]++;
//     notifyListeners();
//   }

//   void removeMinuman(int index) {
//     if (qtyMinuman[index] > 0) {
//       qtyMinuman[index]--;
//       notifyListeners();
//     }
//   }

//   Future<int> buatPesanan() async {
//     int totalHarga = 0;

//     // Bersihkan pesanan lama
//     await DatabaseHelper.instance.clearPesanan();

//     // Simpan menu makanan
//     for (int i = 0; i < menuMakanan.length; i++) {
//       if (qtyMakanan[i] > 0) {
//         int harga = menuMakanan[i]['harga'] * qtyMakanan[i];
//         await DatabaseHelper.instance.insertPesanan(
//           menuMakanan[i]['nama'],
//           qtyMakanan[i],
//           harga,
//         );
//         totalHarga += harga;
//       }
//     }

//     // Simpan menu minuman
//     for (int i = 0; i < menuMinuman.length; i++) {
//       if (qtyMinuman[i] > 0) {
//         int harga = menuMinuman[i]['harga'] * qtyMinuman[i];
//         await DatabaseHelper.instance.insertPesanan(
//           menuMinuman[i]['nama'],
//           qtyMinuman[i],
//           harga,
//         );
//         totalHarga += harga;
//       }
//     }

//     return totalHarga;
//   }
// }
