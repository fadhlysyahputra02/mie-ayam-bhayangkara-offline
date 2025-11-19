import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/menu_data.dart';

class AddMenuBottomSheet extends StatefulWidget {
  final Function({
    required String nama,
    required int qty,
    required int harga,
    required String kategori,
  })
  onTambahMenu;

  const AddMenuBottomSheet({super.key, required this.onTambahMenu});

  @override
  State<AddMenuBottomSheet> createState() => _AddMenuBottomSheetState();
}

class _AddMenuBottomSheetState extends State<AddMenuBottomSheet> {
  String? selectedNama;
  String? selectedKategori;
  int qty = 1;
  int harga = 0;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> semuaMenu = [
      ...menuMakanan.map(
        (e) => {"nama": e["nama"], "harga": e["harga"], "kategori": "makanan"},
      ),
      ...menuMinuman.map(
        (e) => {"nama": e["nama"], "harga": e["harga"], "kategori": "minuman"},
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 255, 235, 213),
            Color.fromARGB(255, 190, 190, 190),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                "Tambah Menu",
                style: GoogleFonts.jockeyOne(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedNama,
              decoration: InputDecoration(
                labelText: "Pilih Menu",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              items: semuaMenu
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e["nama"] as String,
                      child: Text(
                        "${e["nama"]} (Rp ${e["harga"]}) - ${e["kategori"]}",
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedNama = value;
                  final data = semuaMenu.firstWhere((e) => e["nama"] == value);
                  harga = data["harga"] as int;
                  selectedKategori = data["kategori"] as String;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Qty:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        setState(() {
                          if (qty > 1) qty--;
                        });
                      },
                    ),
                    Text("$qty", style: const TextStyle(fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        setState(() {
                          qty++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: (selectedNama == null || selectedKategori == null)
                      ? null
                      : () {
                          widget.onTambahMenu(
                            nama: selectedNama!,
                            qty: qty,
                            harga: harga,
                            kategori: selectedKategori!,
                          );
                          Navigator.of(context).pop();
                        },
                  child: const Text(
                    "Tambah",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
