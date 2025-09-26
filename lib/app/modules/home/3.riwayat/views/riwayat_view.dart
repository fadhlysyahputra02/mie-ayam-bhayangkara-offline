import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../data/db/database_helper.dart';
import '../../../widgets/header_widget.dart';

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

    // Set selectedDate ke anchorDate supaya langsung "Sekarang"
    _selectedDate = _getAnchorDate(DateTime.now());
    _selectedFilterType = FilterType.sekarang;
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

  Map<int, List<Map<String, dynamic>>> _groupPesanan(
    List<Map<String, dynamic>> data,
  ) {
    final Map<int, List<Map<String, dynamic>>> grouped = {};

    final filtered = data.where((item) {
      final date = _parseDate(item['created_at']);
      if (date == null) return false;

      // cutoff "hari terpilih" jam 18:00
      final cutoffToday = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        18,
      );

      if (_selectedFilterType == FilterType.sekarang) {
        // Sekarang = [cutoffToday, cutoffToday+1day)
        final cutoffNextDay = cutoffToday.add(const Duration(days: 1));
        return !date.isBefore(cutoffToday) && date.isBefore(cutoffNextDay);
      } else if (_selectedFilterType == FilterType.kemarin) {
        // Kemarin = [cutoffToday-1day, cutoffToday)
        final cutoffPrevDay = cutoffToday.subtract(const Duration(days: 1));
        return !date.isBefore(cutoffPrevDay) && date.isBefore(cutoffToday);
      }

      return false;
    }).toList();

    // Group berdasarkan no_id
    for (var item in filtered) {
      final noId = item['no_id'] ?? 0;
      grouped.putIfAbsent(noId, () => []).add(item);
    }

    return grouped;
  }

  DateTime _getAnchorDate(DateTime now) {
    final cutoff = DateTime(now.year, now.month, now.day, 18);
    if (now.isBefore(cutoff)) {
      // Kalau sekarang masih < jam 18, berarti anchor = kemarin jam 18
      return cutoff.subtract(const Duration(days: 1));
    }
    return cutoff;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final anchorDate = _getAnchorDate(DateTime.now());

    final List<DateTime> dateButtons = List.generate(
      6,
      (index) => anchorDate.subtract(Duration(days: index)),
    );

    return Scaffold(
      body: Column(
        children: [
          HeaderWidget(screenHeight: screenHeight),
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
                    style: GoogleFonts.jockeyOne(fontSize: 14),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                      style: GoogleFonts.jockeyOne(fontSize: 18),
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
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    const Color.fromARGB(255, 198, 187, 169),
                    const Color.fromARGB(255, 183, 183, 183),
                  ],
                  //255, 151, 151, 151
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
                          color: Colors.white,
                        ),
                      ),
                      if (widget.items.isNotEmpty) // Cek kalau ada data
                        Text(
                          DateFormat('dd MMM yyyy').format(
                            DateTime.tryParse(
                                  widget.items.first['created_at'] ?? '',
                                ) ??
                                DateTime.now(),
                          ),
                          style: GoogleFonts.jockeyOne(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
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
                      final date = DateTime.tryParse(item['created_at'] ?? '');
                      final dateStr = date != null
                          ? DateFormat('dd MMM yyyy HH:mm').format(date)
                          : '-';
                      return ListTile(
                        title: Text(
                          item['nama'] ?? '',
                          style: GoogleFonts.jockeyOne(fontSize: 16),
                        ),
                        subtitle: Text(
                          dateStr,
                          style: GoogleFonts.jockeyOne(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Text(
                          "Rp ${NumberFormat('#,###').format(item['total'] ?? 0)}",
                          style: GoogleFonts.jockeyOne(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
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
