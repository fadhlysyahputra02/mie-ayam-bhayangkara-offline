import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/menu_data.dart';

class AddItemBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const AddItemBottomSheet({super.key, required this.onSave});

  @override
  State<AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends State<AddItemBottomSheet> {
  String? selectedMenu;
  int qty = 1;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle kecil di atas
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

          // Judul
          Center(
            child: Text(
              "Tambah Item Baru",
              style: GoogleFonts.jockeyOne(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Dropdown pilih menu
          DropdownButton<String>(
            value: selectedMenu,
            onChanged: (value) {
              setState(() {
                selectedMenu = value;
              });
            },
            items: [
              ...menuMakanan.map(
                (item) => DropdownMenuItem<String>(
                  value: item['nama'],
                  child: Text("${item['nama']} - Rp ${item['harga']}"),
                ),
              ),
              ...menuMinuman.map(
                (item) => DropdownMenuItem<String>(
                  value: item['nama'],
                  child: Text("${item['nama']} - Rp ${item['harga']}"),
                ),
              ),
            ],
            isExpanded: true,
            hint: const Text("Pilih Menu Makanan atau Minuman"),
            style: const TextStyle(fontSize: 18, color: Colors.black),
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            underline: Container(height: 1, color: Colors.grey[300]),
          ),

          const SizedBox(height: 20),

          // Qty selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: qty > 1 ? () => setState(() => qty--) : null,
                icon: const Icon(Icons.remove_circle),
                color: Colors.red,
                iconSize: 32,
              ),
              Text(qty.toString(), style: const TextStyle(fontSize: 24)),
              IconButton(
                onPressed: () => setState(() => qty++),
                icon: const Icon(Icons.add_circle),
                color: Colors.green,
                iconSize: 32,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Buttons
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
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: selectedMenu == null
                    ? null
                    : () {
                        final selectedMap = [
                          ...menuMakanan,
                          ...menuMinuman,
                        ].firstWhere((e) => e['nama'] == selectedMenu);

                        final int harga = selectedMap['harga'];
                        final total = harga * qty;

                        widget.onSave({
                          "nama": selectedMenu!,
                          "qty": qty,
                          "harga": harga,
                          "total": total,
                          "note": "",
                          "isNew": true,
                        });

                        Navigator.of(context).pop();
                      },
                child: const Text(
                  "Simpan",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
