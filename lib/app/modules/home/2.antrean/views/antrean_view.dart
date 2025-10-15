import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/db/database_helper.dart';
import '../../../../data/menu_data.dart';
import 'confirmation_dialogs.dart';
import 'edit_order_bottom_sheet.dart';
import '../../../widgets/header_widget.dart';
import 'order_card.dart';
import '../controllers/antrean_controller.dart';
import '../widgets/draggablefab.dart';

class AntreanPage extends StatefulWidget {
  const AntreanPage({super.key});

  @override
  State<AntreanPage> createState() => _AntreanPageState();
}

class _AntreanPageState extends State<AntreanPage> {
  final antreanController = Get.put(AntreanController());
  Future<List<Map<String, dynamic>>>? _pesananFuture;

  @override
  void initState() {
    super.initState();
    _loadPesanan();
  }

  Future<void> _loadPesanan() {
    setState(() {
      _pesananFuture = DatabaseHelper.instance.getPesanan();
    });
    return _pesananFuture!;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final GlobalKey _headerKey = GlobalKey();
    double _headerHeight = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _headerKey.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        final newHeight = box.size.height;
        if (_headerHeight != newHeight) {
          setState(() {
            _headerHeight = newHeight;
          });
        }
      }
    });
    return Scaffold(
      body: Column(
        children: [
          HeaderWidget(key: _headerKey, screenHeight: screenHeight),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _pesananFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "Belum ada pesanan",
                      style: GoogleFonts.jockeyOne(fontSize: 18),
                    ),
                  );
                }

                final now = DateTime.now();
                final cutoffTime = DateTime(now.year, now.month, now.day, 22);

                final pesananList = List<Map<String, dynamic>>.from(
                  snapshot.data!.where((item) {
                    final itemTime = DateTime.fromMillisecondsSinceEpoch(
                      item['timestamp'] ?? 0,
                    );
                    final statusOk =
                        item['status'] == "true" ||
                        item['status'] == "selesai_masak";

                    if (now.isBefore(cutoffTime)) {
                      return statusOk;
                    } else {
                      return statusOk && itemTime.isAfter(cutoffTime);
                    }
                  }),
                );

                if (pesananList.isEmpty) {
                  return Center(
                    child: Text(
                      "Tidak ada antrean",
                      style: GoogleFonts.jockeyOne(fontSize: 18),
                    ),
                  );
                }

                pesananList.sort((a, b) {
                  final timeA = a['timestamp'] ?? 0;
                  final timeB = b['timestamp'] ?? 0;
                  return timeA.compareTo(timeB);
                });

                Map<int, List<Map<String, dynamic>>> groupedPesanan = {};
                for (var item in pesananList) {
                  int key = item['no_id'];
                  groupedPesanan.putIfAbsent(key, () => []).add(item);
                }

                return Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: _loadPesanan,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        children: groupedPesanan.entries.map((entry) {
                          final noId = entry.key;
                          final items = entry.value;
                          return OrderCard(
                            key: ValueKey(noId),
                            items: items,
                            noId: noId,
                            onEdit: (item) => _editPesanan(item),
                            onSelesaiMasak: () => _handleSelesaiMasak(noId),
                            onSelesaiBayar: () => _handleSelesaiBayar(noId),
                          );
                        }).toList(),
                      ),
                    ),
                    DraggableFab(
                      icon: Icons.delete,
                      minTop:
                          _headerHeight +
                          10, // supaya FAB mulai di bawah header
                      maxTop: MediaQuery.of(context).size.height - 120,
                      onPressed: () => _deleteAllAntrean(context),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _editPesanan(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EditOrderBottomSheet(
        item: item,
        onSave: (updatedItem) async {
          await DatabaseHelper.instance.updatePesanan(
            updatedItem['id'],
            nama: updatedItem['nama'],
            qty: updatedItem['qty'],
            note: updatedItem['note'],
            total: updatedItem['total'],
          );
          await _loadPesanan();
          ConfirmationDialogs.showSuccess(context, "Item Berhasil Di-update");
        },
      ),
    );
  }

  Future<void> _handleSelesaiMasak(int noId) async {
    await DatabaseHelper.instance.SelesaiMasak(noId, true);
    await _loadPesanan();
    ConfirmationDialogs.showAutoDismiss(
      context,
      Icons.check_circle,
      Colors.green,
      "Pesanan Telah Diantar",
    );
  }

  Future<void> _handleSelesaiBayar(int noId) async {
    int krupukQty = 0;
    int klubGelasQty = 0;

    final tambahan = await showDialog<Map<String, int>>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFFFF8F0),
        title: Row(
          children: const [
            Icon(Icons.restaurant_menu, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text(
              "Tambahan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQtyRow("Krupuk", krupukQty, (delta) {
              krupukQty = (krupukQty + delta).clamp(0, 100);
              (context as Element).markNeedsBuild(); // agar rebuild UI
            }),
            const SizedBox(height: 8),
            _buildQtyRow("Klub Gelas", klubGelasQty, (delta) {
              klubGelasQty = (klubGelasQty + delta).clamp(0, 100);
              (context as Element).markNeedsBuild();
            }),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text("Batal"),
          ),
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
              "Tambahkan",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (tambahan != null) {
      if ((tambahan["krupuk"] ?? 0) > 0) {
        await DatabaseHelper.instance.tambahItemTambahan(
          noId: noId,
          nama: "Krupuk",
          qty: tambahan["krupuk"]!,
        );
      }
      if ((tambahan["klubGelas"] ?? 0) > 0) {
        await DatabaseHelper.instance.tambahItemTambahan(
          noId: noId,
          nama: "Klub Gelas",
          qty: tambahan["klubGelas"]!,
        );
      }
    }

    await DatabaseHelper.instance.SelesaiBayar(noId, true);

    ConfirmationDialogs.showAutoDismiss(
      context,
      Icons.check_circle,
      Colors.red,
      "Pesanan Telah Dibayar",
    );

    await _loadPesanan();
  }

  // Tetap pakai helper untuk row qty
  Widget _buildQtyRow(
    String nama,
    int qty,
    void Function(int delta) onChanged,
  ) {
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

  Future<void> _deleteAllAntrean(BuildContext context) async {
    final confirm = await ConfirmationDialogs.showDeleteAll(context);
    if (confirm == true) {
      await DatabaseHelper.instance.SelesaiBayarSemua();
      await _loadPesanan();
    }
  }
}
