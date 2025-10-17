import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/db/database_helper.dart';
import '../utils/time_formatter.dart';
import 'database_item_card.dart';

class DatabaseCard extends StatelessWidget {
  final int noId;
  final List<Map<String, dynamic>> items;
  final VoidCallback onRefresh;

  const DatabaseCard({
    super.key,
    required this.noId,
    required this.items,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Urutkan items berdasarkan kategori
    final sortedItems = List<Map<String, dynamic>>.from(items);
    sortedItems.sort((a, b) {
      const order = ['makanan', 'minuman', 'tambahan'];
      final aIndex = order.indexOf((a['kategori'] ?? '').toLowerCase());
      final bIndex = order.indexOf((b['kategori'] ?? '').toLowerCase());
      return aIndex.compareTo(bIndex);
    });

    final totalGroup = sortedItems.fold<int>(
      0,
      (sum, item) => sum + ((item['total'] ?? 0) as num).toInt(),
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _buildHeader(context, totalGroup),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: sortedItems.map((item) {
                return DatabaseItemCard(item: item);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int totalGroup) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "ID: $noId",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            "Total: Rp ${NumberFormat('#,###').format(totalGroup)}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (selectedTime != null) {
                      final newTimestamp = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      ).millisecondsSinceEpoch;

                      await DatabaseHelper.instance.updateTimestamp(
                        noId,
                        newTimestamp,
                      );
                      onRefresh();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Timestamp berhasil diupdate"),
                        ),
                      );
                    }
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Konfirmasi"),
                      content: const Text("Hapus data ini?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Batal"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Ya"),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await DatabaseHelper.instance.deletePesanan(noId);
                    onRefresh();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
