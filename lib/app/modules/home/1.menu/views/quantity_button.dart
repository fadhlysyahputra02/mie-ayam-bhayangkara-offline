import 'package:flutter/material.dart';

class QuantityButton extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const QuantityButton({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Tombol -
        _buildCircleButton(Icons.remove, onRemove, Colors.red),
        const SizedBox(width: 8),
        Text(
          "$quantity",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        // Tombol +
        _buildCircleButton(Icons.add, onAdd, Colors.green),
      ],
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onPressed, Color color) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
