import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/db/database_helper.dart';
import '../../../../data/menu_data.dart';
import '../../../../widgets/header_widget.dart';
import 'package:get/get.dart';

import '../widgets/buat_pesanan_button.dart';
import '../widgets/menu_card.dart';
import '../widgets/order_confirmation_bottom_sheet.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  List<int> qtyMakanan = [];
  List<int> qtyMinuman = [];

  @override
  void initState() {
    super.initState();
    qtyMakanan = List.filled(menuMakanan.length, 0);
    qtyMinuman = List.filled(menuMinuman.length, 0);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          // Card Makanan (di atas)
          MenuCard(
            title: "Menu Makanan",
            menuList: menuMakanan,
            qtyList: qtyMakanan,
            color: const Color(0xFFFFEBD5),
            titleColor: Colors.black,
            topOffset: screenHeight * 0.255,
            screenHeight: screenHeight * 0.47,
            bgColor: Colors.white,
            onQuantityChanged: (index, newQty) => setState(() => qtyMakanan[index] = newQty),
          ),

          // Card Minuman (di bawah)
          MenuCard(
            title: "Menu Minuman",
            menuList: menuMinuman,
            qtyList: qtyMinuman,
            color: Colors.white,
            titleColor: Colors.black,
            topOffset: screenHeight * 0.48,
            screenHeight: screenHeight * 0.83,
            bgColor: const Color(0xFFFFEBD5),
            onQuantityChanged: (index, newQty) => setState(() => qtyMinuman[index] = newQty),
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HeaderWidget(screenHeight: screenHeight),
          ),

          // Tombol Buat Pesanan
          BuatPesananButton(
            screenHeight: screenHeight,
            onPressed: () => _simpanPesanan(),
          ),
        ],
      ),
    );
  }

  /// Simpan Pesanan ke Database (pemanggil bottom sheet)
  Future<void> _simpanPesanan() async {
    // Kumpulkan item yang qty > 0
    final List<Map<String, dynamic>> pesanan = [];

    // Makanan
    for (int i = 0; i < menuMakanan.length; i++) {
      if (qtyMakanan[i] > 0) {
        pesanan.add({
          'nama': menuMakanan[i]['nama'],
          'qty': qtyMakanan[i],
          'harga': menuMakanan[i]['harga'],
          'kategori': 'makanan',
        });
      }
    }

    // Minuman
    for (int i = 0; i < menuMinuman.length; i++) {
      if (qtyMinuman[i] > 0) {
        pesanan.add({
          'nama': menuMinuman[i]['nama'],
          'qty': qtyMinuman[i],
          'harga': menuMinuman[i]['harga'],
          'kategori': 'minuman',
        });
      }
    }

    if (pesanan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih menu terlebih dahulu")),
      );
      return;
    }

    // Tampilkan bottom sheet konfirmasi
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderConfirmationBottomSheet(
        pesanan: pesanan,
        onConfirm: (finalPesanan, pembeliNote) async {
          // Insert ke DB
          for (var item in finalPesanan) {
            await DatabaseHelper.instance.insertPesanan(
              item['nama'] as String,
              item['qty'] as int,
              item['total'] as int,
              item['note'] as String,
              pembeliNote,
              status: 'true',
            );
          }

          // Reset qty UI
          setState(() {
            qtyMakanan = List.filled(qtyMakanan.length, 0);
            qtyMinuman = List.filled(qtyMinuman.length, 0);
          });

          Navigator.pop(context); // Tutup bottom sheet

          // Tampilkan dialog sukses (gunakan dari confirmation_dialogs jika ada)
          if (context.mounted) {
            _showSuccessDialog();
          }
        },
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 700), () => Navigator.of(context).pop());
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text(
                  "Pesanan berhasil disimpan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}