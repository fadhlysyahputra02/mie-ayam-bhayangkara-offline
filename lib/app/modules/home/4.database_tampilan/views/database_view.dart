import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/db/database_helper.dart';
import '../../../widgets/header_widget.dart';
import '../widgets/database_card.dart';

class DatabaseView extends StatefulWidget {
  const DatabaseView({super.key});

  @override
  State<DatabaseView> createState() => _DatabaseViewState();
}

class _DatabaseViewState extends State<DatabaseView> {
  late Future<List<Map<String, dynamic>>> _pesananFuture;
  List<Map<String, dynamic>> _allPesanan = [];
  List<Map<String, dynamic>> _filteredPesanan = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPesanan();
    _searchController.addListener(_filterPesanan);
  }

  void _loadPesanan() async {
    await DatabaseHelper.instance.deleteOldPesanan();
    final data = await DatabaseHelper.instance.getPesanan();
    setState(() {
      _allPesanan = List<Map<String, dynamic>>.from(data);
      _filteredPesanan = List<Map<String, dynamic>>.from(_allPesanan);
    });
  }

  void _filterPesanan() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _filteredPesanan = List.from(_allPesanan));
    } else {
      setState(() {
        _filteredPesanan = _allPesanan.where((item) {
          final idStr = item['no_id'].toString();
          final timestampStr = item['timestamp'].toString();
          return idStr.contains(query) || timestampStr.contains(query);
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          HeaderWidget(screenHeight: screenHeight),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari data berdasarkan ID...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadPesanan(),
              child: _filteredPesanan.isEmpty
                  ? const Center(child: Text("Belum ada data"))
                  : ListView(
                      padding: const EdgeInsets.all(8),
                      children: _groupedPesananWidgets(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _groupedPesananWidgets() {
    // Urutkan dulu dari terbaru ke lama
    _filteredPesanan.sort((a, b) {
      final aDate =
          DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
      final bDate =
          DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
      return bDate.compareTo(aDate);
    });

    // Grouping berdasarkan no_id
    final Map<int, List<Map<String, dynamic>>> groupedPesanan = {};
    for (var item in _filteredPesanan) {
      final noId = item['no_id'] ?? 0;
      groupedPesanan.putIfAbsent(noId, () => []).add(item);
    }

    return groupedPesanan.entries.map((entry) {
      return DatabaseCard(
        noId: entry.key,
        items: entry.value,
        onRefresh: () => _loadPesanan(),
      );
    }).toList();
  }
}
