import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/menu_data.dart';

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
              subtotal += 2000 * qty;
            } else {
              subtotal += (optQty * 1500) ;
            }
          } else {
            subtotal += optHarga * optQty ;
          }
        }
      }
    }
    return subtotal;
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
    final double maxHeight = MediaQuery.of(context).size.height * 0.82;
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
                                "Rp $perItemTotal",
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
                            // Opsi tambahan (hanya makanan)
                            if (isItemMakanan[index]) ...[
                              const SizedBox(height: 10),
                              const Text(
                                "Request",
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Column(
                                children: tambahanPerItem[index].map((opt) {
                                  final String nama = opt['nama'] as String;
                                  final int harga = opt['harga'] as int;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
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
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Divider setelah list
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
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

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
