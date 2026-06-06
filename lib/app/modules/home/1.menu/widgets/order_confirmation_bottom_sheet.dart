import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/menu_data.dart';
import 'color_shortcut_button.dart';
import 'note_choice.dart';

class OrderConfirmationBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> pesanan;
  final Function(List<Map<String, dynamic>>, String) onConfirm;

  const OrderConfirmationBottomSheet({
    super.key,
    required this.pesanan,
    required this.onConfirm,
  });

  @override
  State<OrderConfirmationBottomSheet> createState() =>
      _OrderConfirmationBottomSheetState();
}

class _OrderConfirmationBottomSheetState
    extends State<OrderConfirmationBottomSheet> {
  late List<TextEditingController> itemNoteControllers;
  late TextEditingController pembeliNoteController;
  late List<List<Map<String, dynamic>>> tambahanPerItem;
  late List<bool> isItemMakanan;

  @override
  void initState() {
    super.initState();
    itemNoteControllers = widget.pesanan
        .map((_) => TextEditingController())
        .toList();
    pembeliNoteController = TextEditingController();
    tambahanPerItem = List.generate(widget.pesanan.length, (i) {
      return List<Map<String, dynamic>>.from(
        tambahan.map((e) => Map<String, dynamic>.from(e)),
      );
    });
    isItemMakanan = widget.pesanan
        .map((e) => e['kategori'] == 'makanan')
        .toList();
  }

  @override
  void dispose() {
    for (var c in itemNoteControllers) c.dispose();
    pembeliNoteController.dispose();
    super.dispose();
  }

  // Helper hitung total per item
  int totalItem(int index) {
    final base = widget.pesanan[index]['harga'] as int;
    final qty = widget.pesanan[index]['qty'] as int;
    int subtotal = base * qty;

    if (isItemMakanan[index]) {
      for (final opt in tambahanPerItem[index]) {
        final int optQty = opt['qty'] as int;
        if (optQty > 0) {
          final String optNama = opt['nama'] as String;
          int optHarga = opt['harga'] as int;

          if (optNama == "Tambah Ceker") {
            if (optQty == 1) {
              subtotal += 2000;
            } else {
              subtotal += optQty * 1500;
            }
          } else {
            subtotal += optHarga * optQty;
          }
        }
      }
    } else {
      // Jika minuman teh, terapkan diskon pada subtotal teh per item.
      final nama = (widget.pesanan[index]['nama'] as String).toLowerCase();
      if (nama.contains('teh')) {
        subtotal -= _tehDiscountForItem(index);
      }
    }

    return subtotal;
  }

  int _comboMieQty() {
    int qty = 0;
    for (final item in widget.pesanan) {
      final nama = (item['nama'] as String).toLowerCase();
      if ((nama == 'mie ayam' || nama == 'mie pangsit') &&
          !nama.contains('bungkus')) {
        qty += item['qty'] as int;
      }
    }
    return qty;
  }

  int _comboTehQty() {
    int qty = 0;
    for (final item in widget.pesanan) {
      final nama = (item['nama'] as String).toLowerCase();
      if (nama.contains('teh')) {
        qty += item['qty'] as int;
      }
    }
    return qty;
  }

  int _discountedTehQty() {
    final mieQty = _comboMieQty();
    final tehQty = _comboTehQty();
    final pairCount = mieQty < tehQty ? mieQty : tehQty;
    if (pairCount == 0) return 0;
    if (pairCount == 1) return 1;
    return pairCount % 2 == 0 ? pairCount : pairCount - 1;
  }

  int _tehDiscountForItem(int index) {
    final namaItem = (widget.pesanan[index]['nama'] as String).toLowerCase();
    if (!namaItem.contains('teh')) return 0;

    int remainingDiscountedTeh = _discountedTehQty();
    for (int i = 0; i < widget.pesanan.length; i++) {
      final nama = (widget.pesanan[i]['nama'] as String).toLowerCase();
      if (!nama.contains('teh')) continue;

      final itemQty = widget.pesanan[i]['qty'] as int;
      final discountedQty = itemQty <= remainingDiscountedTeh
          ? itemQty
          : remainingDiscountedTeh;

      if (i == index) {
        return discountedQty * 500;
      }

      remainingDiscountedTeh -= discountedQty;
      if (remainingDiscountedTeh <= 0) break;
    }
    return 0;
  }

  int hitungTotalSemua() {
    int sum = 0;
    for (int i = 0; i < widget.pesanan.length; i++) {
      sum += totalItem(i);
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.of(context).size.height * 0.92;
    final totalSemua = hitungTotalSemua();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 235, 213),
                Color.fromARGB(255, 190, 190, 190),
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              // Drag handle
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

              // List item pesanan
              Expanded(
                child: ListView.builder(
                  itemCount: widget.pesanan.length,
                  itemBuilder: (context, index) {
                    final item = widget.pesanan[index];
                    final perItemTotal = totalItem(index);

                    return Card(
                      color: Colors.white,
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color.fromARGB(
                                    255,
                                    255,
                                    207,
                                    157,
                                  ), // Cream (atas)
                                  Colors.white, // Putih (bawah)
                                ],
                              ),
                            ),

                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              title: Text(
                                item['nama'],
                                style: GoogleFonts.jockeyOne(fontSize: 20),
                              ),
                              subtitle: Text(
                                "Jumlah: ${item['qty']}",
                                style: GoogleFonts.roboto(fontSize: 16),
                              ),
                              trailing: Text(
                                "Rp $perItemTotal",
                                style: GoogleFonts.jockeyOne(
                                  fontSize: 18,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 2,
                                right: 2,
                                bottom: 7,
                              ),
                              child: TextField(
                                controller: itemNoteControllers[index],
                                decoration: InputDecoration(
                                  filled: true,
                                  labelStyle: TextStyle(
                                    color: const Color.fromARGB(
                                      146,
                                      120,
                                      120,
                                      120,
                                    ),
                                  ),
                                  fillColor: const Color.fromARGB(
                                    39,
                                    109,
                                    109,
                                    109,
                                  ),
                                  labelText: "Masukkan catatan...",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Opsi tambahan (hanya makanan)
                          if (isItemMakanan[index]) ...[
                            Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: Column(
                                children: tambahanPerItem[index].map((opt) {
                                  final String nama = opt['nama'] as String;
                                  final int harga = opt['harga'] as int;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 1.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "$nama ${harga != 0 ? (harga > 0 ? '(+Rp $harga)' : '(-Rp ${-harga})') : ''}",
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                                size: 30,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  if ((opt['qty'] as int) > 0) {
                                                    opt['qty'] =
                                                        (opt['qty'] as int) - 1;
                                                  }
                                                });
                                              },
                                            ),
                                            Text("${opt['qty']}"),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.add_circle_outline,
                                                size: 30,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  opt['qty'] =
                                                      (opt['qty'] as int) + 1;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Divider setelah list
              const Divider(
                height: 20,
                thickness: 3,
                color: Color.fromARGB(255, 91, 91, 91),
                radius: BorderRadiusGeometry.all(Radius.circular(20)),
              ),
              // Catatan pembeli
              TextField(
                controller: pembeliNoteController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(63, 92, 92, 92),
                  labelText: "Ciri pembeli...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.backspace),
                    onPressed: () {
                      setState(() {
                        pembeliNoteController.clear();
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8),
              // ✅ Row Shortcut Buttons
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grup kiri: jenis pakaian (single select)
                  Expanded(
                    child: NoteChoiceGroup(
                      options: [
                        "laki-laki",
                        "Perempuan",
                        "Baju",
                        "Jaket",
                        "Topi",
                        "Kerudung",
                        "Kemeja",
                      ],
                      controller: pembeliNoteController,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Grup kanan: warna (pakai bulatan warna)
                  Expanded(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ColorShortcutButton(
                          label: "Hitam",
                          color: Colors.black,
                          controller: pembeliNoteController,
                        ),
                        ColorShortcutButton(
                          label: "Merah",
                          color: Colors.red,
                          controller: pembeliNoteController,
                        ),
                        ColorShortcutButton(
                          label: "Putih",
                          color: Colors.white,
                          controller: pembeliNoteController,
                        ),
                        ColorShortcutButton(
                          label: "Kuning",
                          color: Colors.yellow,
                          controller: pembeliNoteController,
                        ),
                        ColorShortcutButton(
                          label: "Biru",
                          color: Colors.blue,
                          controller: pembeliNoteController,
                        ),
                        ColorShortcutButton(
                          label: "Hijau",
                          color: Colors.green,
                          controller: pembeliNoteController,
                        ),
                        ColorShortcutButton(
                          label: "Coklat",
                          color: Colors.brown,
                          controller: pembeliNoteController,
                        ),
                        ColorShortcutButton(
                          label: "Cream",
                          color: const Color.fromARGB(255, 235, 243, 172),
                          controller: pembeliNoteController,
                        ),
                        ColorShortcutButton(
                          label: "Pink",
                          color: const Color.fromARGB(255, 255, 50, 119),
                          controller: pembeliNoteController,
                        ),
                        ColorShortcutButton(
                          label: "abu-abu",
                          color: const Color.fromARGB(255, 132, 114, 119),
                          controller: pembeliNoteController,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total keseluruhan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Rp $totalSemua",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
              ),

              // Tombol Konfirmasi
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
                  onPressed: () {
                    // Kumpulkan data final pesanan
                    final List<Map<String, dynamic>> finalPesanan = [];
                    for (int i = 0; i < widget.pesanan.length; i++) {
                      // Gabungkan tambahan yang dipilih (hanya jika qty > 0)
                      String extraNote = tambahanPerItem[i]
                          .where((opt) => (opt['qty'] as int) > 0)
                          .map((opt) => "${opt['nama']} x${opt['qty']}")
                          .join(", ");

                      // Gabung note item + extra
                      final gabunganNote = [
                        itemNoteControllers[i].text.trim(),
                        if (extraNote.isNotEmpty) extraNote,
                      ].where((s) => s.isNotEmpty).join(" | ");

                      finalPesanan.add({
                        'nama': widget.pesanan[i]['nama'] as String,
                        'qty': widget.pesanan[i]['qty'] as int,
                        'total': totalItem(i),
                        'note': gabunganNote,
                      });
                    }

                    final pembeliNote = pembeliNoteController.text.trim();

                    // Panggil callback untuk konfirmasi (insert ke DB di main file)
                    widget.onConfirm(finalPesanan, pembeliNote);

                    // Tutup bottom sheet
                    Navigator.of(context).pop();
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
  }
}
