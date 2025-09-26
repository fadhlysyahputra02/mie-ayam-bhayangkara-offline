import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/time_formatter.dart';

class DatabaseItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const DatabaseItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final nama = item['nama'] ?? '';
    final qty = item['qty'] ?? 0;
    final total = item['total'] ?? 0;
    final note = item['note'] ?? '';
    final ciriPembeli = item['ciri_pembeli'] ?? '';
    final createdAt = item['created_at'] ?? '';
    final timestamp = item['timestamp'] ?? 0;
    final status = item['status'] ?? '';
    final kategori = item['kategori'] ?? '';

    final readableTime = formatTimestamp(createdAt);
    final readableTimestamp = DateFormat('dd/MM/yyyy HH:mm:ss')
        .format(DateTime.fromMillisecondsSinceEpoch(timestamp));

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$nama x$qty",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Text("Rp $total",
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.category, size: 16, color: Colors.orange),
            const SizedBox(width: 6),
            Text("Kategori: $kategori"),
          ]),
          if (note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(children: [
                const Icon(Icons.note, size: 16, color: Colors.blueGrey),
                const SizedBox(width: 6),
                Expanded(child: Text("Catatan: $note")),
              ]),
            ),
          if (ciriPembeli.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(children: [
                const Icon(Icons.person, size: 16, color: Colors.teal),
                const SizedBox(width: 6),
                Expanded(child: Text("Ciri Pembeli: $ciriPembeli")),
              ]),
            ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Waktu: $readableTime",
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text("Timestamp: $readableTimestamp",
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status == "selesai_bayar"
                      ? Colors.green.withOpacity(0.2)
                      : status == "selesai_masak"
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.isNotEmpty ? status : "pending",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: status == "selesai_bayar"
                        ? Colors.green
                        : status == "selesai_masak"
                            ? Colors.orange
                            : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
