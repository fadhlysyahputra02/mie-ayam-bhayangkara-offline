import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PesananCard extends StatefulWidget {
  final int noId;
  final num totalHari;
  final List<Map<String, dynamic>> items;

  const PesananCard({Key? key, required this.noId, required this.totalHari, required this.items}) : super(key: key);

  @override
  State<PesananCard> createState() => _PesananCardState();
}

class _PesananCardState extends State<PesananCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final String ciriPembeli = widget.items.isNotEmpty ? widget.items.first['ciri_pembeli'] ?? '-' : '-';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color.fromARGB(255, 198, 187, 169), Color.fromARGB(255, 183, 183, 183)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "No ID: ${widget.noId}",
                        style: GoogleFonts.jockeyOne(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        "Ciri pembeli: $ciriPembeli",
                        style: GoogleFonts.jockeyOne(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                      ),
                      if (widget.items.isNotEmpty)
                        Text(
                          DateFormat('dd MMM yyyy').format(DateTime.tryParse(widget.items.first['created_at'] ?? '') ?? DateTime.now()),
                          style: GoogleFonts.jockeyOne(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Rp ${NumberFormat('#,###').format(widget.totalHari)}",
                        style: GoogleFonts.jockeyOne(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Column(
                    children: widget.items.map((item) {
                      final date = DateTime.tryParse(item['created_at'] ?? '');
                      final dateStr = date != null ? DateFormat('dd MMM yyyy HH:mm').format(date) : '-';
                      return ListTile(
                        title: Text("${item['nama'] ?? ''} x${item['qty'] ?? 0}", style: GoogleFonts.jockeyOne(fontSize: 16)),
                        subtitle: Text(dateStr, style: GoogleFonts.jockeyOne(fontSize: 14, color: Colors.grey[600])),
                        trailing: Text(
                          "Rp ${NumberFormat('#,###').format(item['total'] ?? 0)}",
                          style: GoogleFonts.jockeyOne(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade700),
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
