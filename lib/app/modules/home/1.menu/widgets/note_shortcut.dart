import 'package:flutter/material.dart';

class NoteShortcutButton extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const NoteShortcutButton({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero, // biar tombol kecil
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () {
        final current = controller.text.trim();
        if (current.isEmpty) {
          controller.text = label;
        } else {
          controller.text = "$current $label";
        }

        // pindahkan cursor ke akhir text
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      },
      child: Text(
        label,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
