// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import '../../../../data/local/database_helper.dart';

// class RiwayatView extends StatefulWidget {
//   const RiwayatView({super.key});

//   @override
//   State<RiwayatView> createState() => _RiwayatViewState();
// }

// class _RiwayatViewState extends State<RiwayatView> {
//   late Future<List<Map<String, dynamic>>> _pesananFuture;
//   DateTime? _selectedDate; // Tambah variabel ini

//   @override
//   void initState() {
//     super.initState();
//     _selectedDate = DateTime.now(); // default ke hari ini
//     _loadPesanan();
//   }

//   void _loadPesanan() {
//     _pesananFuture = DatabaseHelper.instance.getPesanan();
//   }

//   List<Map<String, dynamic>> _filterBySelectedDate(List<Map<String, dynamic>> data) {
//     if (_selectedDate == null) return data;
//     return data.where((item) {
//       try {
//         final itemDate = DateTime.parse(item['timestamp']);
//         return itemDate.year == _selectedDate!.year &&
//             itemDate.month == _selectedDate!.month &&
//             itemDate.day == _selectedDate!.day;
//       } catch (_) {
//         return false;
//       }
//     }).toList();
//   }

//   Map<String, List<Map<String, dynamic>>> _groupByDate(List<Map<String, dynamic>> data) {
//     final Map<String, List<Map<String, dynamic>>> grouped = {};
//     for (var item in data) {
//       final dateKey = DateFormat('dd MMM yyyy').format(DateTime.parse(item['timestamp']));
//       grouped.putIfAbsent(dateKey, () => []).add(item);
//     }
//     return grouped;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final now = DateTime.now();

//     final List<DateTime> dateButtons = List.generate(
//       6,
//       (index) => now.subtract(Duration(days: index)),
//     );

//     return Scaffold(
//       body: Column(
//         children: [
//           _buildHeader(screenHeight),
//           const SizedBox(height: 16),
//           SizedBox(
//             height: 40,
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               itemCount: dateButtons.length,
//               separatorBuilder: (context, index) => const SizedBox(width: 8),
//               itemBuilder: (context, index) {
//                 final date = dateButtons[index];
//                 String label;

//                 if (index == 0) {
//                   label = "Sekarang";
//                 } else if (index == 1) {
//                   label = "Kemarin";
//                 } else {
//                   label = DateFormat('dd/MM').format(date);
//                 }

//                 return ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _selectedDate != null &&
//                             _selectedDate!.year == date.year &&
//                             _selectedDate!.month == date.month &&
//                             _selectedDate!.day == date.day
//                         ? Colors.red // tombol aktif
//                         : Colors.orange,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _selectedDate = date; // ubah tanggal yang dipilih
//                     });
//                   },
//                   child: Text(label),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 5),
//           const Divider(),
//           Expanded(
//             child: FutureBuilder<List<Map<String, dynamic>>>(
//               future: _pesananFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(child: Text("Tidak ada data"));
//                 }

//                 // Filter sesuai tanggal dipilih
//                 final filtered = _filterBySelectedDate(snapshot.data!);
//                 if (filtered.isEmpty) {
//                   return const Center(child: Text("Tidak ada pesanan di tanggal ini"));
//                 }

//                 // Group data
//                 final grouped = _groupByDate(filtered);

//                 return ListView(
//                   children: grouped.entries.map((entry) {
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             entry.key,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                         ...entry.value.map((pesanan) {
//                           return ListTile(
//                             title: Text(pesanan['nama']),
//                             subtitle: Text(pesanan['timestamp']),
//                             trailing: IconButton(
//                               icon: const Icon(Icons.delete, color: Colors.red),
//                               onPressed: () => _deletePesanan(pesanan['no_id']),
//                             ),
//                           );
//                         }).toList(),
//                       ],
//                     );
//                   }).toList(),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildHeader(double screenHeight) {
//     return Card(
//       margin: EdgeInsets.zero,
//       elevation: 6,
//       color: const Color(0xFFFFEBCD),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(24),
//           bottomRight: Radius.circular(24),
//         ),
//       ),
//       child: SizedBox(
//         height: screenHeight * 0.25,
//         child: Center(
//           child: Text(
//             "Mie Ayam \nBhayangkara",
//             textAlign: TextAlign.center,
//             style: GoogleFonts.jockeyOne(
//               fontSize: screenHeight * 0.05,
//               color: Colors.black87,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _deletePesanan(int noId) async {
//     await DatabaseHelper.instance.deletePesanan(noId);
//     setState(() {
//       _loadPesanan();
//     });
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text("Pesanan dihapus ❌")));
//   }

// }
