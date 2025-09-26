import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../views/quantity_button.dart';

class MenuCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> menuList;
  final List<int> qtyList;
  final Color color;
  final Color titleColor;
  final double topOffset;
  final double screenHeight;
  final Color bgColor;
  final Function(int index, int newQty) onQuantityChanged;
  final double titleTopPadding; // 👈 tambahan

  const MenuCard({
    super.key,
    required this.title,
    required this.menuList,
    required this.qtyList,
    required this.color,
    required this.titleColor,
    required this.topOffset,
    required this.screenHeight,
    required this.bgColor,
    required this.onQuantityChanged,
    this.titleTopPadding = 0, // default 0
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: Card(
        elevation: 5,
        color: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
        child: Container(
          height: screenHeight, // tinggi card tetap
          child: Column(
            children: [
              SizedBox(height: titleTopPadding), // 👈 jarak atas judul
              Text(
                title,
                style: GoogleFonts.jockeyOne(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 8),

              // Bagian scroll
              Expanded(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: menuList.length,
                  itemBuilder: (context, index) {
                    final item = menuList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['nama'],
                              style: GoogleFonts.jockeyOne(fontSize: 20),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          QuantityButton(
                            quantity: qtyList[index],
                            onAdd: () => onQuantityChanged(index, qtyList[index] + 1),
                            onRemove: () {
                              if (qtyList[index] > 0) {
                                onQuantityChanged(index, qtyList[index] - 1);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
