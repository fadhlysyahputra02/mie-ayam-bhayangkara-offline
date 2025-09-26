import 'package:flutter/material.dart';

class NoteChoiceGroup extends StatefulWidget {
  final List<String> options;
  final TextEditingController controller;

  const NoteChoiceGroup({
    super.key,
    required this.options,
    required this.controller,
  });

  @override
  State<NoteChoiceGroup> createState() => _NoteChoiceGroupState();
}

class _NoteChoiceGroupState extends State<NoteChoiceGroup> {
  String? selected;

  void _onSelect(String label) {
    setState(() {
      selected = label;
    });
    widget.controller.text = label;

    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.controller.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.options.map((label) {
        final isSelected = label == selected;
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: isSelected ? Colors.blue : null,
            foregroundColor: isSelected ? Colors.white : Colors.black,
          ),
          onPressed: () => _onSelect(label),
          child: Text(label, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
    );
  }
}
