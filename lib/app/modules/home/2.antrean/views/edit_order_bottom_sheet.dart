import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/menu_data.dart';

class EditOrderBottomSheet extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function(Map<String, dynamic>) onSave;

  const EditOrderBottomSheet({
    super.key,
    required this.item,
    required this.onSave,
  });

  @override
  State<EditOrderBottomSheet> createState() => _EditOrderBottomSheetState();
}

class _EditOrderBottomSheetState extends State<EditOrderBottomSheet> {
  late TextEditingController qtyController;
  late TextEditingController noteController;
  late String selectedMenu;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    qtyController = TextEditingController(text: (item['qty'] ?? 0).toString());
    noteController = TextEditingController(text: item['note'] ?? '');
    selectedMenu = item['nama'] ?? '';
  }

  @override
  void dispose() {
    qtyController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 255, 235, 213), Color.fromARGB(255, 190, 190, 190)],
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
              "Edit Pesanan",
              style: GoogleFonts.jockeyOne(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Input Qty
          TextField(
            controller: qtyController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.format_list_numbered, color: Colors.blue),
              labelText: "Jumlah Pesanan",
              labelStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
              hintText: "Masukkan jumlah",
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.blue.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                qtyController.text = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Input Catatan
          TextField(
            controller: noteController,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.note_alt_outlined, color: Colors.orange),
              labelText: "Catatan",
              labelStyle: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
              hintText: "Tambahkan catatan pesanan...",
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.orange.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.orange, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                noteController.text = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Menu tambahan / topping
          const Text(
            "Tambahkan Menu",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 10),
          DropdownButton<String>(
            value: selectedMenu.isEmpty ? null : selectedMenu,
            onChanged: (String? newValue) {
              setState(() {
                selectedMenu = newValue ?? '';
              });
            },
            items: [
              ...menuMakanan.map((item) => DropdownMenuItem<String>(
                    value: item['nama'] as String,
                    child: Text(item['nama'] as String),
                  )),
              ...menuMinuman.map((item) => DropdownMenuItem<String>(
                    value: item['nama'] as String,
                    child: Text(item['nama'] as String),
                  )),
            ],
            isExpanded: true,
            hint: const Text("Pilih Menu Makanan atau Minuman"),
            style: const TextStyle(fontSize: 18, color: Colors.black),
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            underline: Container(height: 1, color: Colors.grey[300]),
          ),
          const SizedBox(height: 20),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  final newQty = int.tryParse(qtyController.text) ?? (widget.item['qty'] ?? 0);
                  final newNote = noteController.text.trim();
                  final oldQty = widget.item['qty'] ?? 0;
                  final oldTotal = widget.item['total'] ?? 0;

                  int? newTotal;
                  if (newQty != oldQty && oldQty != 0) {
                    final unitPrice = oldTotal ~/ oldQty;
                    newTotal = unitPrice * newQty;
                  } else {
                    newTotal = oldTotal;
                  }

                  final updatedItem = Map<String, dynamic>.from(widget.item)
                    ..['qty'] = newQty
                    ..['note'] = newNote
                    ..['nama'] = selectedMenu.isNotEmpty ? selectedMenu : widget.item['nama']
                    ..['total'] = newTotal;

                  widget.onSave(updatedItem);
                  Navigator.of(context).pop();
                },
                child: const Text("Simpan", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}