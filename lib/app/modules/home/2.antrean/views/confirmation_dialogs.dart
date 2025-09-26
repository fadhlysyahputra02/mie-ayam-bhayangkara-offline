import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmationDialogs {
  // Show a standard confirmation dialog (returns bool)
  static Future<bool?> showConfirm(
    BuildContext context,
    String title,
    String message, {
    required IconData icon,
    required Color iconColor,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFFFF8F0),
        title: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.jockeyOne(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Batal"),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.check, size: 18, color: Colors.white),
            label: const Text("Ya", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Show delete-all confirmation (specific for bulk delete)
  static Future<bool?> showDeleteAll(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFFFF8F0),
        title: const Row(
          children: [
            Icon(Icons.delete, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text(
              "Konfirmasi",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        content: Text(
          "Apakah Anda yakin ingin menghapus\nSEMUA ANTREAN",
          style: GoogleFonts.jockeyOne(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Batal"),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_forever, size: 18, color: Colors.white),
            label: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Show auto-dismiss success/error dialog (non-interactive, auto-closes)
  static Future<void> showAutoDismiss(
    BuildContext context,
    IconData icon,
    Color iconColor,
    String message,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 700), () {
          Navigator.of(context).pop();
        });
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: 32),
                const SizedBox(width: 12),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show simple success dialog (non-auto-dismiss)
  static Future<void> showSuccess(BuildContext context, String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFFFF8F0),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 12),
            Text(
              message,
              style: GoogleFonts.jockeyOne(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}