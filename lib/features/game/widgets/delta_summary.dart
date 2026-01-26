import 'package:flutter/material.dart';
import '../../../core/models/game_models.dart';
import '../../../core/ui/labels_zh.dart';

class DeltaSummary extends StatelessWidget {
  const DeltaSummary({
    super.key,
    required this.statDelta,
    required this.factionDelta,
  });

  final Map<String, int> statDelta;
  final Map<Faction, int> factionDelta;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('属性变化', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (statDelta.isEmpty) _chip('无'),
        ...statDelta.entries.map((e) => _chip('${statLabelZh(e.key)} ${deltaSign(e.value)}')),

        const SizedBox(height: 16),
        const Text('派系态度变化', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (factionDelta.isEmpty) _chip('无'),
        ...factionDelta.entries.map((e) => _chip('${factionLabelZh(e.key)} ${deltaSign(e.value)}')),
      ],
    );
  }

  Widget _chip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text),
      ),
    );
  }
}