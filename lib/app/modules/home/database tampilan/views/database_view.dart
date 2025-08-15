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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pesanan dihapus ❌")),
    );
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

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: pesananList.length,
                itemBuilder: (context, index) {
                  final item = pesananList[index];
                  final nama = item['nama'] ?? '';
                  final qty = item['qty'] ?? 0;
                  final total = item['total'] ?? 0;
                  final note = item['note'] ?? '';
                  final ciriPembeli = item['ciri_pembeli'] ?? '';
                  final createdAt = item['created_at'] ?? '';
                  final noId = item['no_id'] ?? 0;
                  final timestamp = item['timestamp'] ?? 0;
                  final readableTime = formatTimestamp(createdAt);
                  final status = item['status'] ?? '';
                  final readableTimestamp = DateFormat('dd/MM/yyyy HH:mm:ss')
                      .format(DateTime.fromMillisecondsSinceEpoch(timestamp));

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ID: $noId - $nama x$qty  -  Rp $total",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              if (note.isNotEmpty)
                                Text(
                                  "Catatan: $note",
                                  style: const TextStyle(
                                      fontSize: 14, fontStyle: FontStyle.italic),
                                ),
                              if (ciriPembeli.isNotEmpty)
                                Text(
                                  "Ciri Pembeli: $ciriPembeli",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              Text(
                                "Waktu (ISO): $readableTime",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                "Timestamp: $readableTimestamp",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                "Status: $status",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Konfirmasi Hapus"),
                                  content: const Text(
                                      "Apakah Anda yakin ingin menghapus pesanan ini?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("Batal"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text(
                                        "Hapus",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                _deletePesanan(noId);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}

}
