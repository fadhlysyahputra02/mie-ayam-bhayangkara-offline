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
            "Mie Ayam \nBhayangkara",
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
                final parentContext = context;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Belum ada pesanan", style: GoogleFonts.jockeyOne(fontSize: 18),));
                }

                final pesananList = snapshot.data!;

                // Group pesanan berdasarkan no_id
                final Map<int, List<Map<String, dynamic>>> groupedPesanan = {};
                for (var item in pesananList) {
                  final noId = item['no_id'] ?? 0;
                  groupedPesanan.putIfAbsent(noId, () => []).add(item);
                }

                return Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.all(8),
                      children: groupedPesanan.entries.map((entry) {
                        final noId = entry.key;
                        final items = entry.value;
                        final parentContext = context;

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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Card (full width, tanpa padding card)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
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
                                    Row(
                                      children: [
                                        // Tombol Edit Timestamp
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () async {
                                            final selectedDate =
                                                await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(2100),
                                                );

                                            if (selectedDate != null) {
                                              final selectedTime =
                                                  await showTimePicker(
                                                    context: context,
                                                    initialTime:
                                                        TimeOfDay.now(),
                                                  );

                                              if (selectedTime != null) {
                                                final newTimestamp = DateTime(
                                                  selectedDate.year,
                                                  selectedDate.month,
                                                  selectedDate.day,
                                                  selectedTime.hour,
                                                  selectedTime.minute,
                                                ).millisecondsSinceEpoch;

                                                // Update timestamp di database
                                                await DatabaseHelper.instance
                                                    .updateTimestamp(
                                                      noId,
                                                      newTimestamp,
                                                    );

                                                // Reload data
                                                setState(() {
                                                  _loadPesanan();
                                                });

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Timestamp berhasil diupdate",
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                        // Tombol Hapus
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                backgroundColor: const Color(
                                                  0xFFFFF8F0,
                                                ),
                                                title: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                      size: 28,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Text(
                                                      "Konfirmasi",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                content: const Text(
                                                  "Hapus Data Ini?",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                actionsPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                actions: [
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.grey[700],
                                                    ),
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                    child: const Text("Batal"),
                                                  ),
                                                  ElevatedButton.icon(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.green,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                    ),
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(true),
                                                    icon: const Icon(
                                                      Icons.check,
                                                      size: 18,
                                                      color: Colors.white,
                                                    ),
                                                    label: const Text(
                                                      "Ya",
                                                      style: TextStyle(
                                                        color: Colors.white,
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

                                              ScaffoldMessenger.of(context);
                                              await showDialog(
                                                context: parentContext,
                                                barrierDismissible: false,
                                                builder: (context) {
                                                  Future.delayed(
                                                    const Duration(
                                                      milliseconds: 700,
                                                    ),
                                                    () {
                                                      Navigator.of(
                                                        context,
                                                      ).pop(true);
                                                    },
                                                  );
                                                  return Dialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            16,
                                                          ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: const [
                                                          Icon(
                                                            Icons.delete,
                                                            color:
                                                                Color.fromARGB(
                                                                  255,
                                                                  208,
                                                                  47,
                                                                  47,
                                                                ),
                                                            size: 32,
                                                          ),
                                                          SizedBox(width: 12),
                                                          Text(
                                                            "Pesanan berhasil dihapus",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Konten card dengan padding
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    ...items.map((item) {
                                      final nama = item['nama'] ?? '';
                                      final qty = item['qty'] ?? 0;
                                      final total = item['total'] ?? 0;
                                      final note = item['note'] ?? '';
                                      final ciriPembeli =
                                          item['ciri_pembeli'] ?? '';
                                      final createdAt =
                                          item['created_at'] ?? '';
                                      final timestamp = item['timestamp'] ?? 0;
                                      final status = item['status'] ?? '';

                                      final readableTime = formatTimestamp(
                                        createdAt,
                                      );
                                      final readableTimestamp =
                                          DateFormat(
                                            'dd/MM/yyyy HH:mm:ss',
                                          ).format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                              timestamp,
                                            ),
                                          );

                                      return Column(
                                        children: [
                                          ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
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
                                                  Text(
                                                    "Ciri Pembeli: $ciriPembeli",
                                                  ),
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
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    // === BUTTON DELETE DI POJOK KANAN BAWAH ===
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        backgroundColor: Colors.red,
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: const Color(0xFFFFF8F0),
                              title: Row(
                                children: const [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Konfirmasi",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              content: Text(
                                "Apakah Anda yakin ingin menghapus\nSEMUA DATA?",
                                style: GoogleFonts.jockeyOne(fontSize: 16),
                              ),
                              actionsPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey[700],
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text("Batal"),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  icon: const Icon(
                                    Icons.delete_forever,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Hapus",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            // Hapus pesanan berdasarkan noId (group)
                            await DatabaseHelper.instance.deleteAllPesanan();

                            // Reload data
                            setState(() {
                              _loadPesanan();
                            });

                            // Tampilkan notifikasi dialog
                            await showDialog(
                              context: parentContext,
                              barrierDismissible: false,
                              builder: (context) {
                                Future.delayed(
                                  const Duration(
                                    milliseconds: 700,
                                  ), // auto close setelah 0.7 detik
                                  () => Navigator.of(context).pop(true),
                                );
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          Icons.delete,
                                          color: Color.fromARGB(
                                            255,
                                            208,
                                            47,
                                            47,
                                          ),
                                          size: 32,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          "Pesanan berhasil dihapus",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
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
}
