import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/db/database_helper.dart';
import '../../../widgets/header_widget.dart';
import '../widgets/database_card.dart';

class DatabaseView extends StatefulWidget {
  const DatabaseView({super.key});

  @override
  State<DatabaseView> createState() => _DatabaseViewState();
}

class _DatabaseViewState extends State<DatabaseView> {
  late Future<List<Map<String, dynamic>>> _pesananFuture;

  @override
  void initState() {
    super.initState();
    _loadPesanan();
  }

  void _loadPesanan() {
    _pesananFuture = DatabaseHelper.instance.getPesanan();
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
                final parentContext = context;

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "Belum ada data",
                      style: GoogleFonts.jockeyOne(fontSize: 18),
                    ),
                  );
                }

                final pesananList = snapshot.data!;
                final Map<int, List<Map<String, dynamic>>> groupedPesanan = {};
                for (var item in pesananList) {
                  final noId = item['no_id'] ?? 0;
                  groupedPesanan.putIfAbsent(noId, () => []).add(item);
                }

                return Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () async => setState(() => _loadPesanan()),
                      child: ListView(
                        padding: const EdgeInsets.all(8),
                        children: groupedPesanan.entries.map((entry) {
                          return DatabaseCard(
                            noId: entry.key,
                            items: entry.value,
                            onRefresh: () => setState(() => _loadPesanan()),
                          );
                        }).toList(),
                      ),
                    ),
                    // Floating Action Button Hapus Semua
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        backgroundColor: Colors.red,
                        onPressed: () async {
                          final confirm = await _confirmDeleteAll(context);
                          if (confirm == true) {
                            await DatabaseHelper.instance.deleteAllPesanan();
                            setState(() => _loadPesanan());
                            _showDeletedDialog(parentContext);
                          }
                        },
                        child: const Icon(Icons.delete, color: Colors.white),
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

  Future<bool?> _confirmDeleteAll(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFFFF8F0),
        title: const Text("Konfirmasi", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          "Apakah Anda yakin ingin menghapus SEMUA DATA?",
          style: GoogleFonts.jockeyOne(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            label: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeletedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 700), () {
          Navigator.of(context).pop(true);
        });
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete, color: Colors.red, size: 32),
                SizedBox(width: 12),
                Text(
                  "Pesanan berhasil dihapus",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
