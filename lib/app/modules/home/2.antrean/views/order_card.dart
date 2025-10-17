import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'confirmation_dialogs.dart';

class OrderCard extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final int noId;
  final Function(Map<String, dynamic>) onEdit;
  final VoidCallback onSelesaiMasak;
  final void Function(Map<String, int>) onSelesaiBayar;

  const OrderCard({
    super.key,
    required this.items,
    required this.noId,
    required this.onEdit,
    required this.onSelesaiMasak,
    required this.onSelesaiBayar,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  Map<String, int>? _pendingTambahan;

  @override
  Widget build(BuildContext context) {
    final waktu = widget.items.first['timestamp'];
    final ciriPembeli = widget.items.first['ciri_pembeli'] ?? '-';
    final isSelesaiMasak = widget.items.first['status'] == 'selesai_masak';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Dismissible(
        key: ValueKey(widget.noId),
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
            widget.onSelesaiMasak();
          } else if (direction == DismissDirection.endToStart &&
              _pendingTambahan != null) {
            widget.onSelesaiBayar(_pendingTambahan!);
            _pendingTambahan = null;
          }
        },
        child: Card(
          elevation: 4,
          color: isSelesaiMasak
              ? const Color.fromARGB(255, 173, 216, 230)
              : Colors.white,
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
                        "Pesanan ID: ${widget.noId}",
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
                ...widget.items.map((item) => _buildMenuItem(item)).toList(),
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
                        "Rp ${widget.items.fold<int>(0, (sum, item) => sum + (item['total'] as num).toInt())}",
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

  Future<bool> _confirmDismiss(
    BuildContext context,
    DismissDirection direction,
    bool isSelesaiMasak,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      // Swipe kanan → selesai masak
      final result = await ConfirmationDialogs.showConfirm(
        context,
        "Konfirmasi",
        "Tandai pesanan ini sebagai 'SELESAI MASAK'?",
        icon: Icons.restaurant_menu,
        iconColor: Colors.orange,
      );
      return result ?? false;
    } else if (direction == DismissDirection.endToStart) {
      // Swipe kiri → konfirmasi bayar
      int krupukQty = 0;
      int klubGelasQty = 0;

      final result = await showDialog<Map<String, int>>(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: const Color(0xFFFFF8F0),
            title: Row(
              children: const [
                Icon(Icons.restaurant_menu, color: Colors.orange, size: 28),
                SizedBox(width: 8),
                Text(
                  "Konfirmasi Bayar",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildQtyRow(
                  "Krupuk",
                  krupukQty,
                  (delta) => setState(
                    () => krupukQty = (krupukQty + delta).clamp(0, 100),
                  ),
                ),
                const SizedBox(height: 8),
                _buildQtyRow(
                  "Klub Gelas",
                  klubGelasQty,
                  (delta) => setState(
                    () => klubGelasQty = (klubGelasQty + delta).clamp(0, 100),
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(
                  context,
                ).pop({"krupuk": krupukQty, "klubGelas": klubGelasQty}),
                icon: const Icon(Icons.check, size: 18, color: Colors.white),
                label: const Text(
                  "Konfirmasi Bayar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );

      if (result != null) {
        _pendingTambahan = result;
        return true;
      }

      return false;
    }

    return false;
  }

  Widget _buildQtyRow(String nama, int qty, void Function(int) onChanged) {
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
                    onPressed: () => widget.onEdit(item),
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
