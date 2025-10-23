import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../data/db/database_helper.dart';
import '../../../widgets/header_widget.dart';
import '../widgets/pesanan_card.dart';

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
    } catch (_) {
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

      // Filter status selesai_bayar
      if ((item['status'] ?? '') != 'selesai_masak' &&
          (item['status'] ?? '') != 'selesai_bayar')
        return false;

      final cutoffToday = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        18,
      );

      if (_selectedFilterType == FilterType.sekarang) {
        final cutoffNextDay = cutoffToday.add(const Duration(days: 1));
        return !date.isBefore(cutoffToday) && date.isBefore(cutoffNextDay);
      } else if (_selectedFilterType == FilterType.kemarin) {
        final cutoffPrevDay = cutoffToday.subtract(const Duration(days: 1));
        return !date.isBefore(cutoffPrevDay) && date.isBefore(cutoffToday);
      }
      return true;
    }).toList();

    for (var item in filtered) {
      final noId = item['no_id'] ?? 0;
      grouped.putIfAbsent(noId, () => []).add(item);
    }
    return grouped;
  }

  DateTime _getAnchorDate(DateTime now) {
    final cutoff = DateTime(now.year, now.month, now.day, 18);
    if (now.isBefore(cutoff)) return cutoff.subtract(const Duration(days: 1));
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
          SizedBox(height: 5),

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
                String label = (index == 0)
                    ? "Sekarang"
                    : (index == 1)
                    ? "Kemarin"
                    : DateFormat('dd/MM').format(date);
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
                    setState(() => _selectedDate = date);
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

          /// Total pesanan
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _pesananFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Tentukan cutoff berdasarkan _selectedDate
                final cutoffToday = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  18,
                );
                DateTime start, end;

                if (_selectedFilterType == FilterType.sekarang) {
                  start = cutoffToday;
                  end = cutoffToday.add(const Duration(days: 1));
                } else if (_selectedFilterType == FilterType.kemarin) {
                  start = cutoffToday.subtract(const Duration(days: 1));
                  end = cutoffToday;
                } else {
                  // Filter untuk tanggal lainnya (4 hari sebelumnya)
                  start = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    0,
                    0,
                  );
                  end = start.add(const Duration(days: 1));
                }

                final allData = snapshot.data!;

                // 💰 Filter untuk total uang: hanya status "selesai_bayar"
                final pesananBayar = allData.where((item) {
                  final createdAt = DateTime.tryParse(item['created_at'] ?? '');
                  if (createdAt == null) return false;
                  return (item['status'] ?? '') == 'selesai_bayar' &&
                      !createdAt.isBefore(start) &&
                      createdAt.isBefore(end);
                }).toList();

                num totalSemua = pesananBayar.fold<num>(
                  0,
                  (sum, item) => sum + (item['total'] ?? 0),
                );

                // 🍜 Filter untuk total porsi mie: hanya status "selesai_masak"
                final pesananMasak = allData.where((item) {
                  final createdAt = DateTime.tryParse(item['created_at'] ?? '');
                  if (createdAt == null) return false;

                  final status = item['status'] ?? '';

                  // ✅ Termasuk selesai_masak DAN selesai_bayar
                  return (status == 'selesai_masak' ||
                          status == 'selesai_bayar') &&
                      !createdAt.isBefore(start) &&
                      createdAt.isBefore(end);
                }).toList();

                int totalQtyMakanan = pesananMasak
                    .where((item) => item['kategori'] == 'makanan')
                    .fold<int>(0, (sum, item) => sum + (item['qty'] as int));

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 💰 Total uang hari ini
                      Text(
                        "Total hari ini: Rp ${NumberFormat('#,###').format(totalSemua)}",
                        style: GoogleFonts.jockeyOne(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // 🍜 Total porsi mie
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.orange.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.fastfood,
                              size: 18,
                              color: Color.fromARGB(255, 135, 135, 135),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "$totalQtyMakanan porsi mie",
                              style: GoogleFonts.jockeyOne(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 135, 135, 135),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),

          const Divider(height: 1),

          /// List Pesanan
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _pesananFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return Center(
                    child: Text(
                      "Tidak ada data",
                      style: GoogleFonts.jockeyOne(fontSize: 18),
                    ),
                  );

                // Filter status "selesai_bayar"
                final selesaiMasakData = snapshot.data!
                    .where(
                      (item) =>
                          item['status'] == 'selesai_masak' ||
                          item['status'] == 'selesai_bayar',
                    )
                    .toList();

                final groupedData = _groupPesanan(selesaiMasakData);

                // Urutkan descending berdasarkan created_at terakhir di tiap group
                final sortedEntries = groupedData.entries.toList()
                  ..sort((a, b) {
                    final aLatest = a.value.last['created_at'] ?? '';
                    final bLatest = b.value.last['created_at'] ?? '';
                    return bLatest.compareTo(
                      aLatest,
                    ); // descending: terbaru paling atas
                  });

                if (sortedEntries.isEmpty)
                  return Center(
                    child: Text(
                      "Tidak ada pesanan selesai bayar pada tanggal ini",
                      style: GoogleFonts.jockeyOne(fontSize: 18),
                    ),
                  );

                return ListView(
                  padding: const EdgeInsets.all(8),
                  children: sortedEntries
                      .map(
                        (entry) => PesananCard(
                          noId: entry.key,
                          totalHari: entry.value.fold<num>(
                            0,
                            (sum, item) => sum + (item['total'] ?? 0),
                          ),
                          items: entry.value,
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
