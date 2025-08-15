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

  Map<int, List<Map<String, dynamic>>> _groupPesanan(List<Map<String, dynamic>> data) {
    // Filter berdasarkan tombol yang dipilih
    final filtered = data.where((item) {
      final date = _parseDate(item['created_at']);
      if (date == null) return false;

      // Hari yang sama dengan _selectedDate
      final isSameDate = date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day;

      if (!isSameDate) return false;

      if (_selectedFilterType == FilterType.sekarang) {
        return date.hour >= 18; // jam >= 18:00
      } else if (_selectedFilterType == FilterType.kemarin) {
        return date.hour < 18; // jam < 18:00
      }
      return true;
    }).toList();

    // Group berdasarkan no_id
    final Map<int, List<Map<String, dynamic>>> grouped = {};
    for (var item in filtered) {
      final noId = item['no_id'] ?? 0;
      if (!grouped.containsKey(noId)) {
        grouped[noId] = [];
      }
      grouped[noId]!.add(item);
    }
    return grouped;
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

                final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
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
                  child: Text(label, style: const TextStyle(fontSize: 14)),
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
                  totalSemua += list.fold<num>(0, (sum, item) => sum + (item['total'] ?? 0));
                });

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Total hari ini: Rp ${NumberFormat('#,###').format(totalSemua)}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  return const Center(child: Text("Tidak ada data"));
                }

                final groupedData = _groupPesanan(snapshot.data!);

                if (groupedData.isEmpty) {
                  return const Center(child: Text("Tidak ada pesanan pada tanggal ini"));
                }

                return ListView(
                  children: groupedData.entries.map((entry) {
                    final totalHari = entry.value.fold<num>(
                      0,
                      (sum, item) => sum + (item['total'] ?? 0),
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.orange.shade100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "No ID: ${entry.key}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Total: Rp ${NumberFormat('#,###').format(totalHari)}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        ...entry.value.map((item) {
                          final date = _parseDate(item['created_at']);
                          final dateStr = date != null
                              ? DateFormat('dd MMM yyyy HH:mm').format(date)
                              : '-';
                          return ListTile(
                            title: Text(item['nama'] ?? ''),
                            subtitle: Text(dateStr),
                            trailing: Text("Rp ${item['total'] ?? 0}"),
                          );
                        }),
                      ],
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
