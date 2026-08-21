import 'package:flutter/material.dart';

class SoftCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const SoftCard({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE9E3D9),
        ),
      ),
      child: child,
    );
  }
}
