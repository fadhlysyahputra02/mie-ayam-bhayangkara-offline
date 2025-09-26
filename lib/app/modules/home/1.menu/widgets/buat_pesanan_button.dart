import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuatPesananButton extends StatelessWidget {
  final double screenHeight;
  final VoidCallback onPressed;

  const BuatPesananButton({
    super.key,
    required this.screenHeight,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: screenHeight * 0.02,
      left: 16,
      right: 16,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(
          "Buat Pesanan",
          style: GoogleFonts.jockeyOne(fontSize: 25, color: Colors.white),
        ),
      ),
    );
  }
}