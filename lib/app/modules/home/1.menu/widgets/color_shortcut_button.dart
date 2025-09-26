import 'package:flutter/material.dart';

class ColorShortcutButton extends StatelessWidget {
  final String label; // tetap perlu untuk input ke textfield
  final Color color;
  final TextEditingController controller;

  const ColorShortcutButton({
    super.key,
    required this.label,
    required this.color,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final current = controller.text.trim();
        if (current.isEmpty) {
          controller.text = label;
        } else {
          controller.text = "$current $label";
        }

        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle, // bulat
          border: Border.all(color: Colors.grey.shade400, width: 1),
        ),
      ),
    );
  }
}
