import 'package:flutter/material.dart';

class DraggableFab extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double minTop; 
  final double maxTop; 
  final Color backgroundColor;

  const DraggableFab({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.minTop, 
    required this.maxTop,
    this.backgroundColor = const Color.fromARGB(129, 244, 67, 54),
  });

  @override
  State<DraggableFab> createState() => _DraggableFabState();
}

class _DraggableFabState extends State<DraggableFab> {
  double top = 200;
  double left = 20;
  double fabSize = 60;
  bool isDragging = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedPositioned(
      duration: isDragging
          ? Duration.zero
          : const Duration(milliseconds: 300), // animasi ke pinggir
      curve: Curves.easeOutBack,
      left: left,
      top: top,
      child: GestureDetector(
        onPanStart: (_) {
          setState(() => isDragging = true);
        },
        onPanUpdate: (details) {
          setState(() {
            left += details.delta.dx;
            top += details.delta.dy;

            // ✅ batasi agar nggak naik ke area header
            if (top < widget.minTop) top = widget.minTop;
            if (top > widget.maxTop) top = widget.maxTop;
          });
        },
        onPanEnd: (_) {
          setState(() {
            isDragging = false;

            // Tentukan sisi terdekat & animasi snap
            if (left + fabSize / 2 < screenWidth / 2) {
              left = 10; // snap kiri
            } else {
              left = screenWidth - fabSize - 10; // snap kanan
            }
          });
        },
        child: FloatingActionButton(
          backgroundColor: widget.backgroundColor,
          child: Icon(widget.icon, color: Colors.white),
          onPressed: widget.onPressed,
        ),
      ),
    );
  }
}
