import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/game/game_controller.dart';
import '../../core/models/game_models.dart';
import '../../core/theme/app_theme.dart';

class ResolutionScreen extends ConsumerWidget {
  const ResolutionScreen({super.key});

  // --- UI labels (Chinese) ---
  static const Map<String, String> _statZh = {
    'favor': '宠爱',
    'fame': '名声',
    'scheming': '心机',
    'talent': '才艺',
    'family': '家世',
    'health': '健康',
    'beauty': '外貌',
    'learning': '学识',

    // legacy keys (in case old json slips through)
    'reputation': '名声',
    'appearance': '外貌',
    'background': '家世',
  };

  static const Map<Faction, String> _factionZh = {
    Faction.dowager: '太后党',
    Faction.empress: '皇后党',
    Faction.inlaws: '外戚党',
    Faction.pure: '清流党',
    Faction.military: '军功派',
    Faction.eunuchs: '内廷势力',
  };

  static String _statLabel(String key) => _statZh[key] ?? key;
  static String _factionLabel(Faction f) => _factionZh[f] ?? f.name;
  static String _deltaText(int v) => v >= 0 ? '+$v' : '$v';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(gameProvider);
    final ctrl = ref.read(gameProvider.notifier);
    if (run == null) return const SizedBox.shrink();

    final hasEnding = run.endingId != null;
    final isMonthEnd = run.day >= 30;

    return Scaffold(
      appBar: AppBar(title: const Text('结算')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('属性变化', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (run.lastStatDelta.isEmpty)
            Text('无明显变化', style: TextStyle(color: AppTheme.textMain.withOpacity(0.75)))
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: run.lastStatDelta.entries
                  .map((e) => _deltaPill('${_statLabel(e.key)} ${_deltaText(e.value)}'))
                  .toList(),
            ),

          const SizedBox(height: 14),
          const Text('派系态度变化', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (run.lastFactionDelta.isEmpty)
            Text('无明显变化', style: TextStyle(color: AppTheme.textMain.withOpacity(0.75)))
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: run.lastFactionDelta.entries
                  .map((e) => _deltaPill('${_factionLabel(e.key)} ${_deltaText(e.value)}'))
                  .toList(),
            ),

          const Spacer(),

          if (hasEnding)
            FilledButton(
              onPressed: () => context.go('/ending'),
              child: const Text('进入结局'),
            )
          else
            FilledButton(
              onPressed: () {
                if (isMonthEnd) {
                  context.go('/monthEnd');
                } else {
                  ctrl.nextDayOrMonthEnd();
                  ctrl.drawTodayEvent();
                  context.go('/loop');
                }
              },
              child: Text(isMonthEnd ? '进入月末考评' : '进入下一天'),
            ),
        ]),
      ),
    );
  }

  Widget _deltaPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.eventCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
