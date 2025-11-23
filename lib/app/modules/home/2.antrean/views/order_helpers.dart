import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget untuk menampilkan row jumlah (qty)
Widget buildQtyRow(String nama, int qty, void Function(int) onChanged) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        nama,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () => onChanged(-1),
          ),
          Text("$qty", style: const TextStyle(fontSize: 16)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => onChanged(1),
          ),
        ],
      ),
    ],
  );
}

/// Widget untuk menampilkan menu item
Widget buildMenuItem({
  required Map<String, dynamic> item,
  required void Function(Map<String, dynamic>) onEdit,
  required void Function(Map<String, dynamic>) onHapusItem,
  required BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                "${item['nama']}",
                style: GoogleFonts.jockeyOne(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                "x${item['qty']}",
                textAlign: TextAlign.center,
                style: GoogleFonts.jockeyOne(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(height: 24, width: 1, color: Colors.grey[400]),
            Expanded(
              flex: 2,
              child: Text(
                "Rp ${item['total']}",
                textAlign: TextAlign.center,
                style: GoogleFonts.jockeyOne(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(height: 24, width: 1, color: Colors.grey[400]),
            if (item['status'] != 'selesai_masak')
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 32,
                    width: 32,
                    margin: const EdgeInsets.only(left: 6),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 59, 190, 63),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () => onEdit(item),
                    ),
                  ),
                  // Container(
                  //   height: 32,
                  //   width: 32,
                  //   margin: const EdgeInsets.only(left: 6),
                  //   decoration: const BoxDecoration(
                  //     color: Colors.red,
                  //     shape: BoxShape.circle,
                  //   ),
                  //   child: IconButton(
                  //     padding: EdgeInsets.zero,
                  //     icon: const Icon(
                  //       Icons.delete,
                  //       color: Colors.white,
                  //       size: 18,
                  //     ),
                  //     onPressed: () async {
                  //       final confirm = await ConfirmationDialogs.showConfirm(
                  //         context,
                  //         "Hapus Menu",
                  //         "Yakin ingin menghapus menu ini dari pesanan?",
                  //         icon: Icons.delete,
                  //         iconColor: Colors.red,
                  //       );
                  //       if (confirm == true) {
                  //         onHapusItem(item);
                  //       }
                  //     },
                  //   ),
                  // ),
                ],
              ),
          ],
        ),
        if ((item['note'] ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              "Catatan: ${item['note']}",
              style: GoogleFonts.jockeyOne(
                fontSize: 19,
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
            ),
          ),
      ],
    ),
  );
}
