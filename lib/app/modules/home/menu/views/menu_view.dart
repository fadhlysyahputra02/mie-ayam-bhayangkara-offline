import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/local/database_helper.dart';
import '../../../../data/menu_data.dart';
import 'quantity_button.dart';
import 'package:get/get.dart';

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
          // Card Minuman
          _buildMenuCard(
            title: "Menu Minuman",
            menuList: menuMinuman,
            qtyList: qtyMinuman,
            color: Colors.white,
            titleColor: Colors.black,
            topOffset: screenHeight * 0.48,
            screenHeight: screenHeight,
            bgColor: const Color(0xFFFFEBD5),
          ),

          // Card Makanan
          _buildMenuCard(
            title: "Menu Makanan",
            menuList: menuMakanan,
            qtyList: qtyMakanan,
            color: const Color(0xFFFFEBD5),
            titleColor: Colors.black,
            topOffset: screenHeight * 0.255,
            screenHeight: screenHeight,
            bgColor: Colors.white,
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(screenHeight),
          ),

          // Tombol "Buat Pesanan"
          _buildBuatPesananButton(screenHeight),
        ],
      ),
    );
  }

  /// Widget Card Menu
  Widget _buildMenuCard({
    required String title,
    required List<Map<String, dynamic>> menuList,
    required List<int> qtyList,
    required Color color,
    required Color titleColor,
    required double topOffset,
    required double screenHeight,
    required Color bgColor,
  }) {
    return Positioned(
      top: title == "Menu Minuman" ? 0 : 0,
      left: 0,
      right: 0,
      child: Card(
        color: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
        child: SizedBox(
          height: title == "Menu Minuman"
              ? screenHeight * 0.83
              : screenHeight * 0.47,
          child: Column(
            children: [
              SizedBox(height: topOffset),
              Text(
                title,
                style: GoogleFonts.jockeyOne(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: menuList.length,
                  itemBuilder: (context, index) {
                    final item = menuList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['nama'],
                            style: GoogleFonts.jockeyOne(fontSize: 20),
                          ),
                          QuantityButton(
                            quantity: qtyList[index],
                            onAdd: () => setState(() => qtyList[index]++),
                            onRemove: () => setState(() {
                              if (qtyList[index] > 0) qtyList[index]--;
                            }),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header
  Widget _buildHeader(double screenHeight) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      color: const Color.fromARGB(255, 255, 235, 213),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SizedBox(
        height: screenHeight * 0.25,
        child: Align(
          alignment: Alignment.center,
          child: Text(
            "Mie Ayam \nBhayangkara",
            textAlign: TextAlign.center,
            style: GoogleFonts.jockeyOne(
              fontSize: screenHeight * 0.05,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// Tombol Buat Pesanan
  Widget _buildBuatPesananButton(double screenHeight) {
    return Positioned(
      bottom: screenHeight * 0.02,
      left: 16,
      right: 16,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _simpanPesanan,
        child: Text(
          "Buat Pesanan",
          style: GoogleFonts.jockeyOne(fontSize: 25, color: Colors.white),
        ),
      ),
    );
  }

  /// Simpan Pesanan ke Database
  Future<void> _simpanPesanan() async {
    final parentContext = context;

    List<Map<String, dynamic>> pesanan = [];

    // Ambil dari menu makanan
    for (int i = 0; i < menuMakanan.length; i++) {
      if (qtyMakanan[i] > 0) {
        pesanan.add({
          'nama': menuMakanan[i]['nama'],
          'qty': qtyMakanan[i],
          'harga': menuMakanan[i]['harga'],
          'note': '',
        });
      }
    }

    // Ambil dari menu minuman
    for (int i = 0; i < menuMinuman.length; i++) {
      if (qtyMinuman[i] > 0) {
        pesanan.add({
          'nama': menuMinuman[i]['nama'],
          'qty': qtyMinuman[i],
          'harga': menuMinuman[i]['harga'],
          'note': '',
        });
      }
    }

    if (pesanan.isEmpty) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        const SnackBar(content: Text("Pilih menu terlebih dahulu")),
      );
      return;
    }

    // Controller untuk catatan
    final pembeliNoteController = TextEditingController();
    final itemNoteControllers = pesanan
        .map((_) => TextEditingController())
        .toList();

    int totalHarga = pesanan.fold<int>(
      0,
      (sum, item) => sum + ((item['harga'] as int) * (item['qty'] as int)),
    );

    await showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final double maxHeight = MediaQuery.of(context).size.height * 0.75;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Container(
              constraints: BoxConstraints(maxHeight: maxHeight),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 255, 235, 213),
                    Color.fromARGB(255, 190, 190, 190),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  Container(
                    height: 5,
                    width: 50,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const Text(
                    "Pesanan Anda",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),

                  // List pesanan
                  Expanded(
                    child: ListView.builder(
                      itemCount: pesanan.length,
                      itemBuilder: (context, index) {
                        final item = pesanan[index];
                        return Card(
                          color: Colors.white,
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    item['nama'],
                                    style: GoogleFonts.jockeyOne(fontSize: 20),
                                  ),
                                  subtitle: Text("Jumlah: ${item['qty']}"),
                                  trailing: Text(
                                    "Rp ${item['harga'] * item['qty']}",
                                    style: GoogleFonts.jockeyOne(
                                      fontSize: 18,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: itemNoteControllers[index],
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color.fromARGB(
                                      255,
                                      255,
                                      235,
                                      213,
                                    ),
                                    labelText: "Catatan untuk item ini",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(),

                  // Catatan pembeli
                  TextField(
                    controller: pembeliNoteController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: "Catatan ciri pembeli",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Rp $totalHarga",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        // Ambil waktu sekarang
                        DateTime now = DateTime.now();

                        // Buat no_id dari jam, menit, detik
                        int noId = int.parse(
                          '${now.hour.toString().padLeft(2, '0')}' +
                              '${now.minute.toString().padLeft(2, '0')}' +
                              '${now.second.toString().padLeft(2, '0')}',
                        );
                        int timestamp = DateTime.now().millisecondsSinceEpoch;

                        for (var i = 0; i < pesanan.length; i++) {
                          await DatabaseHelper.instance.insertPesanan(
                            pesanan[i]['nama'],
                            pesanan[i]['qty'],
                            pesanan[i]['harga'] * pesanan[i]['qty'],
                            itemNoteControllers[i].text,
                            pembeliNoteController.text,
                            status: 'true',
                          );
                        }

                        // Reset qty
                        setState(() {
                          qtyMakanan = List<int>.filled(qtyMakanan.length, 0);
                          qtyMinuman = List<int>.filled(qtyMinuman.length, 0);
                        });

                        Navigator.pop(context); // Tutup bottom sheet dulu

                        // Tampilkan modal sukses
                        await showDialog(
                          context: parentContext,
                          barrierDismissible: false,
                          builder: (context) {
                            Future.delayed(
                              const Duration(milliseconds: 700),
                              () {
                                Navigator.of(context).pop(true);
                              },
                            );
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 32,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Pesanan berhasil disimpan",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );

                        // Dispose controller setelah semua UI hilang
                        for (var c in itemNoteControllers) {
                          c.dispose();
                        }
                        pembeliNoteController.dispose();
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.green, Colors.lightGreen],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "Konfirmasi Pesanan",
                            style: GoogleFonts.jockeyOne(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
