import 'package:flutter/material.dart';

import '../../../data/db/database_helper.dart';
import '../../../data/models/pesanan.dart';

class PesananListPage extends StatefulWidget {
  const PesananListPage({super.key});

  @override
  State<PesananListPage> createState() => _PesananListPageState();
}

class _PesananListPageState extends State<PesananListPage> {
  List<Pesanan> pesananList = [];

  @override
  void initState() {
    super.initState();
    _fetchPesanan();
  }

  Future<void> _fetchPesanan() async {
    final data = await DatabaseHelper.instance.getPesanan();
    final List<Pesanan> list = data.map((item) => Pesanan.fromMap(item)).toList();
    setState(() {
      pesananList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
      ),
      body: pesananList.isEmpty
          ? const Center(child: Text('Belum ada pesanan'))
          : ListView.builder(
              itemCount: pesananList.length,
              itemBuilder: (context, index) {
                final pesanan = pesananList[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No ID: ${pesanan.noId}'),
                        Text('Nama: ${pesanan.nama}'),
                        Text('Qty: ${pesanan.qty}'),
                        Text('Total: ${pesanan.total}'),
                        Text('Note: ${pesanan.note}'),
                        Text('Ciri Pembeli: ${pesanan.ciriPembeli}'),
                        Text('Created At: ${pesanan.createdAt}'),
                        Text('Timestamp: ${pesanan.timestamp}'),
                        Text('Status: ${pesanan.status}'),
                        Text('Kategori: ${pesanan.kategori}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
