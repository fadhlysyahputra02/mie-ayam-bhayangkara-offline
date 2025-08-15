import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../data/local/database_helper.dart';

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

  Widget _buildHeader(double screenHeight) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 6,
      color: const Color(0xFFFFEBCD),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SizedBox(
        height: screenHeight * 0.25,
        child: Center(
          child: Text(
            "Mie Ayam \nBhayangkaraa",
            textAlign: TextAlign.center,
            style: GoogleFonts.jockeyOne(
              fontSize: screenHeight * 0.05,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _loadPesanan() {
    _pesananFuture = DatabaseHelper.instance.getPesanan();
  }

  String formatTimestamp(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy, HH:mm:ss').format(date);
    } catch (e) {
      return isoString;
    }
  }

  Future<void> _deletePesanan(int noId) async {
    await DatabaseHelper.instance.deletePesanan(noId);
    setState(() {
      _loadPesanan();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Pesanan dihapus ❌")));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(screenHeight),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _pesananFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Belum ada pesanan"));
                }

                final pesananList = snapshot.data!;

                // Group pesanan berdasarkan no_id
                final Map<int, List<Map<String, dynamic>>> groupedPesanan = {};
                for (var item in pesananList) {
                  final noId = item['no_id'] ?? 0;
                  groupedPesanan.putIfAbsent(noId, () => []).add(item);
                }

                return ListView(
                  padding: const EdgeInsets.all(8),
                  children: groupedPesanan.entries.map((entry) {
                    final noId = entry.key;
                    final items = entry.value;

                    // Hitung total per grup
                    final totalGroup = items.fold<int>(
                      0,
                      (sum, item) =>
                          sum + ((item['total'] ?? 0) as num).toInt(),
                    );

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header grup
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "ID: $noId",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "Total: Rp ${NumberFormat('#,###').format(totalGroup)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                            "Konfirmasi Hapus Group",
                                          ),
                                          content: const Text(
                                            "Apakah Anda yakin ingin menghapus group ini?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(false),
                                              child: const Text("Batal"),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(true),
                                              child: const Text(
                                                "Hapus",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        // Hapus pesanan berdasarkan noId (group)
                                        await DatabaseHelper.instance
                                            .deletePesanan(noId);

                                        // Reload data
                                        setState(() {
                                          _loadPesanan();
                                        });

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Group dihapus ❌"),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // List item per grup
                            ...items.map((item) {
                              final nama = item['nama'] ?? '';
                              final qty = item['qty'] ?? 0;
                              final total = item['total'] ?? 0;
                              final note = item['note'] ?? '';
                              final ciriPembeli = item['ciri_pembeli'] ?? '';
                              final createdAt = item['created_at'] ?? '';
                              final timestamp = item['timestamp'] ?? 0;
                              final status = item['status'] ?? '';

                              final readableTime = formatTimestamp(createdAt);
                              final readableTimestamp =
                                  DateFormat('dd/MM/yyyy HH:mm:ss').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      timestamp,
                                    ),
                                  );

                              return Column(
                                children: [
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    title: Text(
                                      "$nama x$qty  - Rp $total",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (note.isNotEmpty)
                                          Text("Catatan: $note"),
                                        if (ciriPembeli.isNotEmpty)
                                          Text("Ciri Pembeli: $ciriPembeli"),
                                        Text(
                                          "Waktu: $readableTime",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          "Timestamp: $readableTimestamp",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          "Status: $status",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                  ),
                                  const Divider(thickness: 1),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
