import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatChip extends StatelessWidget {
  final String label;
  final int value;
  const StatChip({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.eventCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Text('$label $value', style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}