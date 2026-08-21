import 'package:flutter/material.dart';

class Tag extends StatelessWidget {
  final String text;
  final bool active;

  const Tag({
    super.key,
    required this.text,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFD9EAD5) : Colors.white,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          color: active ? const Color(0xFF56745B) : const Color(0xFF403E38),
        ),
      ),
    );
  }
}
