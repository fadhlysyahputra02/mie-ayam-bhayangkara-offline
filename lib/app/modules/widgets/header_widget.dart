import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderWidget extends StatelessWidget {
  final double screenHeight;

  const HeaderWidget({
    super.key, // penting biar bisa pakai GlobalKey dari parent
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
        height: screenHeight * 0.255,
        child: Stack(
          children: [
            Column(
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
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.169,
                        child: Image.asset(
                          'assets/image/WajahAyah.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      Text(
                        "Mie Ayam \nBhayangkara",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.jockeyOne(
                          fontSize: screenHeight * 0.05,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // TAG VERSI
            Positioned(
              bottom: 8,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "versi 3.5",
                  style: GoogleFonts.jockeyOne(
                    fontSize: screenHeight * 0.015,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
