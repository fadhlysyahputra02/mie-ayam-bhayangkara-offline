import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'confirmation_dialogs.dart';

class OrderCard extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final int noId;
  final Function(Map<String, dynamic>) onEdit;
  final VoidCallback onSelesaiMasak;
  final VoidCallback onSelesaiBayar;

  const OrderCard({
    super.key,
    required this.items,
    required this.noId,
    required this.onEdit,
    required this.onSelesaiMasak,
    required this.onSelesaiBayar,
  });

  @override
  Widget build(BuildContext context) {
    final waktu = items.first['timestamp'];
    final ciriPembeli = items.first['ciri_pembeli'] ?? '-';
    final isSelesaiMasak = items.first['status'] == 'selesai_masak';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Dismissible(
        key: ValueKey(noId),
        direction: DismissDirection.horizontal,
        background: _buildBackground(
          Alignment.centerLeft,
          Colors.green,
          Icons.check,
        ),
        secondaryBackground: _buildBackground(
          Alignment.centerRight,
          Colors.red,
          Icons.delete,
        ),
        confirmDismiss: (direction) =>
            _confirmDismiss(context, direction, isSelesaiMasak),
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd) {
            onSelesaiMasak();
          } else if (direction == DismissDirection.endToStart) {
            onSelesaiBayar();
          }
        },
        child: Card(
          elevation: 4,
          color: isSelesaiMasak
              ? const Color.fromARGB(255, 173, 216, 230)
              : const Color.fromARGB(255, 255, 255, 255),
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Waktu & ID
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        isSelesaiMasak
                            ? "SUDAH DIANTAR"
                            : "Waktu Pesanan: ${DateFormat('HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(waktu, isUtc: false))}",
                        style: GoogleFonts.jockeyOne(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSelesaiMasak
                              ? Colors.black
                              : Colors.deepOrange,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Pesanan ID: $noId",
                        style: GoogleFonts.jockeyOne(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Ciri Pembeli: $ciriPembeli",
                  style: GoogleFonts.jockeyOne(
                    fontSize: 19,
                    color: Colors.black87,
                  ),
                ),
                const Divider(height: 16, thickness: 1),
                // Menu items
                ...items.map((item) => _buildMenuItem(item)).toList(),
                const Divider(height: 16, thickness: 1),
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total:",
                      style: GoogleFonts.jockeyOne(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 18),
                      child: Text(
                        "Rp ${items.fold<int>(0, (sum, item) => sum + (item['total'] as num).toInt())}",
                        style: GoogleFonts.jockeyOne(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(Alignment alignment, Color color, IconData icon) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: Colors.white, size: 32),
    );
  }

  Future<bool?> _confirmDismiss(
    BuildContext context,
    DismissDirection direction,
    bool isSelesaiMasak,
  ) async {
    String title, message;
    if (direction == DismissDirection.startToEnd) {
      title = "Konfirmasi";
      message = "Tandai pesanan ini sebagai 'SELESAI MASAK'?";
    } else {
      title = "Konfirmasi";
      message = "Tandai pesanan ini sebagai 'SELESAI BAYAR'?";
    }
    // Perbaikan: Gunakan named parameters untuk icon dan iconColor
    return ConfirmationDialogs.showConfirm(
      context,
      title,
      message,
      icon: Icons.restaurant_menu, // Tambahkan label 'icon:'
      iconColor: Colors.orange, // Tambahkan label 'iconColor:'
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
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
                    icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                    onPressed: () => onEdit(item),
                  ),
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
}
