import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderWidget extends StatelessWidget {
  final double screenHeight;

  const HeaderWidget({
    super.key,   // penting biar bisa pakai GlobalKey dari parent
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      color: const Color.fromARGB(255, 255, 235, 213),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SizedBox(
        height: screenHeight * 0.25,  // ini nanti akan kita hitung real tingginya di parent
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.045,
                left: screenHeight * 0.01,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    "Aplikasi By:",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jockeyOne(
                      fontSize: screenHeight * 0.025,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Mie Ayam \nBhayangkara",
                textAlign: TextAlign.center,
                style: GoogleFonts.jockeyOne(
                  fontSize: screenHeight * 0.05,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
