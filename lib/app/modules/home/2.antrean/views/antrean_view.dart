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
import '../widgets/animatedfeb.dart';

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

    return Scaffold(
      body: Column(
        children: [
          HeaderWidget(screenHeight: screenHeight),
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
                    final statusOk = item['status'] == "true" || item['status'] == "selesai_masak";

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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    Positioned(
                      bottom: 36,
                      right: -40,
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: AnimatedFab(
                          icon: Icons.delete,
                          onPressed: () => _deleteAllAntrean(context),
                        ),
                      ),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
    ConfirmationDialogs.showAutoDismiss(context, Icons.check_circle, Colors.green, "Pesanan Telah Diantar");
  }

  Future<void> _handleSelesaiBayar(int noId) async {
    await DatabaseHelper.instance.SelesaiBayar(noId, true);
    ConfirmationDialogs.showAutoDismiss(context, Icons.check_circle, Colors.red, "Pesanan Telah Dibayar");
  }

  Future<void> _deleteAllAntrean(BuildContext context) async {
    final confirm = await ConfirmationDialogs.showDeleteAll(context);
    if (confirm == true) {
      await DatabaseHelper.instance.SelesaiBayarSemua();
      await _loadPesanan();
    }
  }
}