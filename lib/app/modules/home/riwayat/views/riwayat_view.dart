import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../data/local/database_helper.dart';

class RiwayatView extends StatefulWidget {
  const RiwayatView({super.key});

  @override
  State<RiwayatView> createState() => _RiwayatViewState();
}

enum FilterType { semua, sekarang, kemarin }

class _RiwayatViewState extends State<RiwayatView> {
  late Future<List<Map<String, dynamic>>> _pesananFuture;
  DateTime _selectedDate = DateTime.now();
  FilterType _selectedFilterType = FilterType.sekarang;

  @override
  void initState() {
    super.initState();
    _loadPesanan();
  }

  void _loadPesanan() {
    _pesananFuture = DatabaseHelper.instance.getPesanan();
  }

  DateTime? _parseDate(String? dateString) {
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
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

  Map<int, List<Map<String, dynamic>>> _groupPesanan(
    List<Map<String, dynamic>> data,
  ) {
    final Map<int, List<Map<String, dynamic>>> grouped = {};

    final filtered = data.where((item) {
      final date = _parseDate(item['created_at']);
      if (date == null) return false;

      final startCutoff = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        22,
      ).subtract(const Duration(days: 1)); // start: hari sebelumnya jam 22
      final endCutoff = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        22,
      ); // end: hari ini jam 22

      if (_selectedFilterType == FilterType.sekarang) {
        return date.isAfter(startCutoff) && date.isBefore(endCutoff);
      } else if (_selectedFilterType == FilterType.kemarin) {
        final yesterdayStart = startCutoff.subtract(const Duration(days: 1));
        final yesterdayEnd = endCutoff.subtract(const Duration(days: 1));
        return date.isAfter(yesterdayStart) && date.isBefore(yesterdayEnd);
      }

      return false;
    }).toList();

    // Group berdasarkan no_id
    for (var item in filtered) {
      final noId = item['no_id'] ?? 0;
      if (!grouped.containsKey(noId)) {
        grouped[noId] = [];
      }
      grouped[noId]!.add(item);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final now = DateTime.now();

    final List<DateTime> dateButtons = List.generate(
      6,
      (index) => now.subtract(Duration(days: index)),
    );

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(screenHeight),
          const SizedBox(height: 16),

          /// Tombol filter tanggal
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: dateButtons.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final date = dateButtons[index];
                String label;
                if (index == 0) {
                  label = "Sekarang";
                } else if (index == 1) {
                  label = "Kemarin";
                } else {
                  label = DateFormat('dd/MM').format(date);
                }

                final isSelected =
                    DateFormat('yyyy-MM-dd').format(date) ==
                    DateFormat('yyyy-MM-dd').format(_selectedDate);

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.orange : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Text(
                    label,
                    style: GoogleFonts.jockeyOne(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          /// Total pesanan di tanggal terpilih
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _pesananFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final groupedData = _groupPesanan(snapshot.data!);
                num totalSemua = 0;
                groupedData.values.forEach((list) {
                  totalSemua += list.fold<num>(
                    0,
                    (sum, item) => sum + (item['total'] ?? 0),
                  );
                });

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Total hari ini: Rp ${NumberFormat('#,###').format(totalSemua)}",
                      style: GoogleFonts.jockeyOne(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),

          const Divider(height: 1),
          // List Pesanan
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _pesananFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Tidak ada data", style: GoogleFonts.jockeyOne(fontSize: 18),));
                }

                final groupedData = _groupPesanan(snapshot.data!);

                if (groupedData.isEmpty) {
                  return Center(
                    child: Text(
                      "Tidak ada pesanan pada tanggal ini",
                      style: GoogleFonts.jockeyOne(color: Colors.black),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(8),
                  children: groupedData.entries.map((entry) {
                    final totalHari = entry.value.fold<num>(
                      0,
                      (sum, item) => sum + (item['total'] ?? 0),
                    );

                    return PesananCard(
                      noId: entry.key,
                      totalHari: totalHari,
                      items: entry.value,
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

class PesananCard extends StatefulWidget {
  final int noId;
  final num totalHari;
  final List<Map<String, dynamic>> items;

  const PesananCard({
    Key? key,
    required this.noId,
    required this.totalHari,
    required this.items,
  }) : super(key: key);

  @override
  State<PesananCard> createState() => _PesananCardState();
}

class _PesananCardState extends State<PesananCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Ambil tanggal dari item pertama
    final firstDate = widget.items.isNotEmpty
        ? DateTime.tryParse(widget.items.first['created_at']?.toString() ?? '')
        : null;

    final dateStr = firstDate != null
        ? DateFormat('dd MMM yyyy').format(firstDate)
        : '-';

    final timeStr = firstDate != null
        ? DateFormat('HH:mm').format(firstDate)
        : '-';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(12),
          bottom: Radius.circular(
            _isExpanded ? 12 : 0,
          ), // <- kalau tertutup lurus
        ),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 255, 235, 213),
                    Color.fromARGB(255, 190, 190, 190),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Kolom kiri: No ID + Tanggal
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "No ID: ${widget.noId}",
                        style: GoogleFonts.jockeyOne(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 120, 120, 120),
                        ),
                      ),
                      if (widget.items.isNotEmpty) // Cek kalau ada data
                        Row(
                          children: [
                            Text(
                              DateFormat('dd MMM yyyy').format(
                                // Pastikan ambil string dari database
                                DateTime.tryParse(
                                      (widget.items.first['timestamp'] ?? '')
                                          .toString(),
                                    ) ??
                                    DateTime.now(),
                              ),
                              style: GoogleFonts.jockeyOne(
                                fontSize: 14,
                                color: const Color.fromARGB(255, 120, 120, 120),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              timeStr,
                              style: GoogleFonts.jockeyOne(
                                fontSize: 14,
                                color: const Color.fromARGB(255, 120, 120, 120),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // Kolom kanan: Total + Icon Expand
                  Row(
                    children: [
                      Text(
                        "Rp ${NumberFormat('#,###').format(widget.totalHari)}",
                        style: GoogleFonts.jockeyOne(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Animasi buka-tutup
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Column(
                    children: widget.items.map((item) {
                      final catatan = DateTime.tryParse(item['note'] ?? '');

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['nama'] ?? '',
                                        style: GoogleFonts.jockeyOne(
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        (item['note'] ?? '')
                                                .toString()
                                                .isNotEmpty
                                            ? item['note'].toString()
                                            : "-",
                                        style: GoogleFonts.jockeyOne(
                                          fontSize: 14,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "Rp ${NumberFormat('#,###').format(item['total'] ?? 0)}",
                                  style: GoogleFonts.jockeyOne(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            thickness: 1,
                            color: Colors.grey.shade300,
                            indent: 12,
                            endIndent: 12,
                          ),
                        ],
                      );
                    }).toList(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
