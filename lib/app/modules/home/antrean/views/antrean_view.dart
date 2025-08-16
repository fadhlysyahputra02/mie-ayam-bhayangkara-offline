import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/local/database_helper.dart';
import '../controllers/antrean_controller.dart';
import 'package:intl/intl.dart';

import '../widgets/animatedfeb.dart';

class AntreanPage extends StatefulWidget {
  const AntreanPage({super.key});

  @override
  State<AntreanPage> createState() => _AntreanPageState();
}

class _AntreanPageState extends State<AntreanPage> {
  late Future<List<Map<String, dynamic>>> _pesananFuture;
  final antreanController = Get.put(AntreanController());

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
    final parentContext = context;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(screenHeight),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseHelper.instance.getPesanan(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "Belum ada pesanan",
                      style: GoogleFonts.jockeyOne(fontSize: 18),
                    ),
                  );
                }

                final now = DateTime.now();

                // Batas awal hari ini jam 22:00
                final cutoffTime = DateTime(now.year, now.month, now.day, 22);

                // Filter data sesuai status
                final pesananList = List<Map<String, dynamic>>.from(
                  snapshot.data!.where((item) {
                    final itemTime = DateTime.fromMillisecondsSinceEpoch(
                      item['timestamp'] ?? 0,
                    );
                    final statusOk =
                        item['status'] == "true" ||
                        item['status'] == "selesai_masak";

                    if (now.isBefore(cutoffTime)) {
                      // Sebelum jam 22: tampilkan semua data dengan status ok
                      return statusOk;
                    } else {
                      // Setelah jam 22: hanya tampilkan data >= jam 22
                      return statusOk && itemTime.isAfter(cutoffTime);
                    }
                  }),
                );

                // ⬇️ Tambahkan pengecekan lagi di sini
                if (pesananList.isEmpty) {
                  return Center(
                    child: Text(
                      "Tidak ada antrean",
                      style: GoogleFonts.jockeyOne(fontSize: 18),
                    ),
                  );
                }

                // Urutkan dari lama ke baru
                pesananList.sort((a, b) {
                  final timeA = a['timestamp'] ?? 0;
                  final timeB = b['timestamp'] ?? 0;
                  return timeA.compareTo(timeB);
                });

                // Grouping berdasarkan no_id
                Map<int, List<Map<String, dynamic>>> groupedPesanan = {};
                for (var item in pesananList) {
                  int key = item['no_id'];
                  groupedPesanan.putIfAbsent(key, () => []).add(item);
                }

                return Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      children: groupedPesanan.entries.map((entry) {
                        final noId = entry.key;
                        final items = entry.value;
                        final waktu = items.first['timestamp'];

                        final ciriPembeli = items.first['ciri_pembeli'] ?? '-';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Stack(
                            children: [
                              // 🔴 & 🟢 Background
                              Positioned.fill(
                                child: Row(
                                  children: [
                                    // 🟢 Swipe kanan → Bayar
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          color: Colors.green,
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // 🔴 Swipe kiri → Hapus
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          color: Colors.red,
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ⚪ Card Putih
                              Dismissible(
                                key: ValueKey(noId),
                                direction: DismissDirection.horizontal,
                                background: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                secondaryBackground: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        backgroundColor: const Color(
                                          0xFFFFF8F0,
                                        ),
                                        title: Row(
                                          children: [
                                            const Icon(
                                              Icons.restaurant_menu,
                                              color: Colors.orange,
                                              size: 28,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              "Konfirmasi",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                        content: const Text(
                                          "Tandai pesanan ini sebagai \n'SELESAI MASAK'?",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        actionsPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                        actions: [
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.grey[700],
                                            ),
                                            onPressed: () => Navigator.of(
                                              context,
                                            ).pop(false),
                                            child: const Text("Batal"),
                                          ),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
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

                                    return confirm ?? false;
                                  } else {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        backgroundColor: const Color(
                                          0xFFFFF8F0,
                                        ),
                                        title: Row(
                                          children: [
                                            const Icon(
                                              Icons.restaurant_menu,
                                              color: Colors.orange,
                                              size: 28,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              "Konfirmasi",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                        content: const Text(
                                          "Tandai pesanan ini sebagai \n'SELESAI BAYAR'?",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        actionsPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                        actions: [
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.grey[700],
                                            ),
                                            onPressed: () => Navigator.of(
                                              context,
                                            ).pop(false),
                                            child: const Text("Batal"),
                                          ),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
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

                                    return confirm ?? false;
                                  }
                                },
                                onDismissed: (direction) async {
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    await DatabaseHelper.instance.SelesaiMasak(
                                      noId,
                                      true,
                                    );
                                    setState(() {});
                                    await showDialog(
                                      context: parentContext,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        Future.delayed(
                                          const Duration(milliseconds: 700),
                                          () {
                                            Navigator.of(context).pop(true);
                                          },
                                        );
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 32,
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  "Pesanan Telah Diantar",
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
                                  } else if (direction ==
                                      DismissDirection.endToStart) {
                                    await DatabaseHelper.instance.SelesaiBayar(
                                      noId,
                                      true,
                                    );
                                    await showDialog(
                                      context: parentContext,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        Future.delayed(
                                          const Duration(milliseconds: 700),
                                          () {
                                            Navigator.of(context).pop(true);
                                          },
                                        );
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.red,
                                                  size: 32,
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  "Pesanan Telah Dibayar",
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
                                child: Card(
                                  elevation: 4,
                                  color: items.first['status'] == 'true'
                                      ? const Color.fromARGB(255, 255, 255, 255)
                                      : const Color.fromARGB(
                                          255,
                                          173,
                                          216,
                                          230,
                                        ),

                                  margin: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Waktu & ID
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Center(
                                              child: Text(
                                                items.first['status'] ==
                                                        'selesai_masak'
                                                    ? "SUDAH DIANTAR"
                                                    : "Waktu Pesanan: ${DateFormat('HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(waktu, isUtc: false))}",
                                                style: GoogleFonts.jockeyOne(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      items.first['status'] ==
                                                          'selesai_masak'
                                                      ? Colors
                                                            .black // Hitam kalau sudah diantar
                                                      : Colors
                                                            .deepOrange, // Warna lama kalau belum
                                                ),
                                              ),
                                            ),

                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                "Pesanan ID: $noId",
                                                style: GoogleFonts.jockeyOne(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Ciri Pembeli: $ciriPembeli",
                                          style: GoogleFonts.jockeyOne(
                                            fontSize: 19,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const Divider(height: 16, thickness: 1),
                                        ...items.map((item) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    // Nama Menu
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                        "${item['nama']}",
                                                        style:
                                                            GoogleFonts.jockeyOne(
                                                              fontSize: 19,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                      ),
                                                    ),

                                                    // Qty
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        "x${item['qty']}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.jockeyOne(
                                                              fontSize: 19,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                      ),
                                                    ),

                                                    // Garis pemisah
                                                    Container(
                                                      height: 24,
                                                      width: 1,
                                                      color: Colors.grey[400],
                                                    ),

                                                    // Total harga
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        "Rp ${item['total']}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.jockeyOne(
                                                              fontSize: 19,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                      ),
                                                    ),

                                                    // Garis pemisah
                                                    Container(
                                                      height: 24,
                                                      width: 1,
                                                      color: Colors.grey[400],
                                                    ),

                                                    // Icon edit (muncul jika belum selesai masak)
                                                    if (item['status'] !=
                                                        'selesai_masak')
                                                      Container(
                                                        height: 32,
                                                        width: 32,
                                                        margin:
                                                            const EdgeInsets.only(
                                                              left: 6,
                                                            ),
                                                        decoration:
                                                            const BoxDecoration(
                                                              color:
                                                                  Color.fromARGB(
                                                                    255,
                                                                    59,
                                                                    190,
                                                                    63,
                                                                  ),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                        child: IconButton(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          icon: const Icon(
                                                            Icons.edit,
                                                            color: Colors.white,
                                                            size: 18,
                                                          ),
                                                          onPressed: () =>
                                                              _editPesanan(
                                                                item,
                                                              ),
                                                        ),
                                                      ),
                                                  ],
                                                ),

                                                // Catatan jika ada
                                                if ((item['note'] ?? '')
                                                    .isNotEmpty)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 2,
                                                        ),
                                                    child: Text(
                                                      "Catatan: ${item['note']}",
                                                      style:
                                                          GoogleFonts.jockeyOne(
                                                            fontSize: 19,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            color: Colors
                                                                .grey[700],
                                                          ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          );
                                        }).toList(),

                                        const Divider(height: 16, thickness: 1),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Total:",
                                              style: GoogleFonts.jockeyOne(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                right: 18,
                                              ),
                                              child: Text(
                                                "Rp ${items.fold<int>(0, (sum, item) => sum + (item['total'] as num).toInt())}",
                                                style: GoogleFonts.jockeyOne(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green[700],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    Positioned(
                      bottom: 36,
                      right: -40, // setengah lingkaran keluar layar
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: AnimatedFab(
                          icon: Icons.delete,
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
                                "Apakah Anda yakin ingin menghapus\nSEMUA ANTREAN",
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
                              await DatabaseHelper.instance.SelesaiBayarSemua();
                              setState(() {
                                _loadPesanan();
                              });
                            }
                          },
                        ),
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

  void _editPesanan(Map<String, dynamic> item) {
    final int id = item['id'];
    final String nama = item['nama'] ?? '';
    final int qty = (item['qty'] ?? 0) as int;
    final int total = (item['total'] ?? 0) as int;
    final String note = item['note'] ?? '';
    final parentContext = context;
    final qtyController = TextEditingController(text: qty.toString());
    final noteController = TextEditingController(text: note);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // supaya gradient kelihatan
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 235, 213),
                Color.fromARGB(255, 190, 190, 190),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle kecil di atas
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Judul
              Center(
                child: Text(
                  "Edit Pesanan",
                  style: GoogleFonts.jockeyOne(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Input Qty
              // Input Qty
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.format_list_numbered,
                    color: Colors.blue,
                  ),
                  labelText: "Jumlah Pesanan",
                  labelStyle: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                  hintText: "Masukkan jumlah",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.blue.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Input Catatan
              TextField(
                controller: noteController,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.note_alt_outlined,
                    color: Colors.orange,
                  ),
                  labelText: "Catatan",
                  labelStyle: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                  hintText: "Tambahkan catatan pesanan...",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.orange,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 20),

              // Tombol Aksi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () => Navigator.of(bottomSheetContext).pop(),
                    child: const Text("Batal"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () async {
                      final newQty = int.tryParse(qtyController.text) ?? qty;
                      final newNote = noteController.text.trim();

                      int? newTotal;
                      if (newQty != qty) {
                        final unit = qty == 0 ? 0 : (total ~/ qty);
                        newTotal = unit * newQty;
                      }

                      await DatabaseHelper.instance.updatePesanan(
                        id,
                        nama: nama,
                        qty: newQty,
                        note: newNote,
                        total: newTotal,
                      );

                      Navigator.of(context).pop();
                      await _loadData();

                      await showDialog(
                        context: parentContext,
                        barrierDismissible: false,
                        builder: (context) {
                          Future.delayed(const Duration(milliseconds: 700), () {
                            Navigator.of(context).pop(true);
                          });
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
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 32,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Item Berhasil Di-update",
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
                    },
                    child: const Text(
                      "Simpan",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> pesananList = [];

  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.getPesanan();
    setState(() {
      pesananList = data;
    });
  }

  void _loadPesanan() {
    _pesananFuture = DatabaseHelper.instance.getPesanan();
  }
}
