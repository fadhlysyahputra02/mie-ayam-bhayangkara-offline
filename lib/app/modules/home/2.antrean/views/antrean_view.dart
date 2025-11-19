import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/db/database_helper.dart';
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
                  final rawNoId = item['no_id'];

                  // Skip item yang no_id-nya null / invalid (data lama)
                  if (rawNoId == null) continue;

                  // Pastikan int
                  final int key;
                  if (rawNoId is int) {
                    key = rawNoId;
                  } else {
                    key = int.tryParse(rawNoId.toString()) ?? 0;
                  }

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
                            onSelesaiBayar: (tambahan) =>
                                _handleSelesaiBayar(tambahan, noId),
                            onTambahMenu:
                                ({
                                  required String nama,
                                  required int qty,
                                  required int harga,
                                  required String kategori,
                                }) => _handleTambahMenu(
                                  noId: noId,
                                  nama: nama,
                                  qty: qty,
                                  harga: harga,
                                  kategori: kategori,
                                ),
                            onHapusItem: (item) async {
                              await DatabaseHelper.instance.deletePesananItem(
                                item['id'],
                              );
                              await _loadPesanan();
                              ConfirmationDialogs.showSuccess(
                                context,
                                "Item berhasil dihapus",
                              );
                            },
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

  Future<void> _handleSelesaiBayar(Map<String, int> tambahan, int noId) async {
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

    await DatabaseHelper.instance.SelesaiBayar(noId, true);

    ConfirmationDialogs.showAutoDismiss(
      context,
      Icons.check_circle,
      Colors.red,
      "Pesanan Telah Dibayar",
    );

    await _loadPesanan();
  }

  Future<void> _deleteAllAntrean(BuildContext context) async {
    final confirm = await ConfirmationDialogs.showDeleteAll(context);
    if (confirm == true) {
      await DatabaseHelper.instance.SelesaiBayarSemua();
      await _loadPesanan();
    }
  }

  Future<void> _handleTambahMenu({
    required int noId,
    required String nama,
    required int qty,
    required int harga,
    required String kategori,
  }) async {
    final snapshot = await _pesananFuture;
    String ciriPembeli = "-";

    if (snapshot != null) {
      final item = snapshot.firstWhere(
        (e) => e["no_id"] == noId,
        orElse: () => {},
      );
      if (item.isNotEmpty && item["ciri_pembeli"] != null) {
        ciriPembeli = item["ciri_pembeli"] as String;
      }
    }

    final total = harga * qty;

    await DatabaseHelper.instance.insertPesananDenganNoId(
      noId: noId, // ⬅️ pakai no_id lama
      nama: nama,
      qty: qty,
      total: total,
      note: "",
      kategori: kategori,
      ciriPembeli: ciriPembeli,
      status: "true",
    );

    await _loadPesanan();
  }
}
