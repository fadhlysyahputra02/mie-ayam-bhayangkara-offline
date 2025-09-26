import 'package:flutter/material.dart';

class AnimatedFab extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color backgroundColor;

  const AnimatedFab({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor = Colors.red,
  }) : super(key: key);

  @override
  State<AnimatedFab> createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<AnimatedFab> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: _isPressed ? 1.0 : 0.7,
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton(
            backgroundColor: widget.backgroundColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(60),
                bottomLeft: Radius.circular(60),
              ),
            ),
            child: Icon(widget.icon, color: Colors.white),
            onPressed: widget.onPressed,
          ),
        ),
      ),
    );
  }
}
