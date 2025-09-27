// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../../data/db/database_helper.dart';

// enum FilterType { semua, sekarang, kemarin }

// class FilterResult {
//   final num totalHarga;
//   final int totalQtyMakanan;

//   FilterResult(this.totalHarga, this.totalQtyMakanan);
// }

// class RiwayatController {
//   late Future<List<Map<String, dynamic>>> pesananFuture;
//   DateTime selectedDate = DateTime.now();
//   FilterType selectedFilterType = FilterType.sekarang;

//   void loadPesanan() {
//     pesananFuture = DatabaseHelper.instance.getPesanan();
//     selectedDate = getAnchorDate(DateTime.now());
//     selectedFilterType = FilterType.sekarang;
//   }

//   DateTime getAnchorDate(DateTime now) {
//     final cutoff = DateTime(now.year, now.month, now.day, 18);
//     if (now.isBefore(cutoff)) return cutoff.subtract(const Duration(days: 1));
//     return cutoff;
//   }

//   List<DateTime> getDateButtons() {
//     final anchorDate = getAnchorDate(DateTime.now());
//     return List.generate(6, (index) => anchorDate.subtract(Duration(days: index)));
//   }

//   String getLabelForButton(int index, DateTime date) {
//     if (index == 0) return "Sekarang";
//     if (index == 1) return "Kemarin";
//     return DateFormat('dd/MM').format(date);
//   }

//   bool isSelectedDate(DateTime date) {
//     return DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(selectedDate);
//   }

//   void setSelectedDate(int index, DateTime date) {
//     selectedDate = date;
//     selectedFilterType = (index == 0)
//         ? FilterType.sekarang
//         : (index == 1)
//             ? FilterType.kemarin
//             : FilterType.semua;
//   }

//   FilterResult getFilteredPesanan(List<Map<String, dynamic>> data) {
//     final cutoffToday = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 18);
//     DateTime start, end;

//     if (selectedFilterType == FilterType.sekarang) {
//       start = cutoffToday;
//       end = cutoffToday.add(const Duration(days: 1));
//     } else if (selectedFilterType == FilterType.kemarin) {
//       start = cutoffToday.subtract(const Duration(days: 1));
//       end = cutoffToday;
//     } else {
//       start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0);
//       end = start.add(const Duration(days: 1));
//     }

//     final filtered = data.where((item) {
//       final createdAt = DateTime.tryParse(item['created_at'] ?? '');
//       if (createdAt == null) return false;
//       return !createdAt.isBefore(start) && createdAt.isBefore(end);
//     }).toList();

//     final totalHarga = filtered.fold<num>(0, (sum, item) => sum + (item['total'] ?? 0));
//     final totalQtyMakanan = filtered.where((item) => item['kategori'] == 'makanan').fold<int>(0, (sum, item) => sum + (item['qty'] as int));

//     return FilterResult(totalHarga, totalQtyMakanan);
//   }

//   Map<int, List<Map<String, dynamic>>> groupPesanan(List<Map<String, dynamic>> data) {
//     final Map<int, List<Map<String, dynamic>>> grouped = {};
//     final filtered = getFilteredPesanan(data); // Optional untuk total? Bisa juga pisah
//     for (var item in data) {
//       final noId = item['no_id'] ?? 0;
//       final createdAt = DateTime.tryParse(item['created_at'] ?? '');
//       if (createdAt == null) continue;

//       final cutoffToday = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 18);
//       DateTime start, end;
//       if (selectedFilterType == FilterType.sekarang) {
//         start = cutoffToday;
//         end = cutoffToday.add(const Duration(days: 1));
//       } else if (selectedFilterType == FilterType.kemarin) {
//         start = cutoffToday.subtract(const Duration(days: 1));
//         end = cutoffToday;
//       } else {
//         start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0);
//         end = start.add(const Duration(days: 1));
//       }

//       if (!createdAt.isBefore(start) && createdAt.isBefore(end)) {
//         grouped.putIfAbsent(noId, () => []).add(item);
//       }
//     }

//     return grouped;
//   }
// }
