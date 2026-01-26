import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/game_models.dart';
import '../../features/game/game_controller.dart';
import '../widgets/event_card.dart';
import '../widgets/option_button.dart';
import '../widgets/palace_modal.dart';
import 'resolution_panel.dart';

class LoopPanel extends ConsumerWidget {
  const LoopPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(gameProvider);
    final ctrl = ref.read(gameProvider.notifier);

    if (run == null) {
      return const Text('尚未开局，请先在首页开始游戏。');
    }

    final e = run.currentEvent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '第 ${run.month} 月 · 第 ${run.day} 天',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
            ),
            const Spacer(),
            _pill('位阶 ${run.rankTier}'),
          ],
        ),
        const SizedBox(height: 12),

        if (e == null) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => ctrl.drawTodayEvent(),
              child: const Text('抽取今日事件'),
            ),
          ),
        ] else ...[
          EventCard(event: e),
          const SizedBox(height: 12),

          ...List.generate(e.options.length, (i) {
            final opt = e.options[i];
            final tone = _toneFromEvent(e, opt);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OptionButton(
                text: opt.text,
                tone: tone,
                onPressed: () async {
                  // 1) 记录选择 -> 属性/派系/flag变化
                  ctrl.chooseOption(i);

                  // 2) 关闭“事件弹窗”（这一步用当前 context 是安全的）
                  Navigator.of(context).pop();

                  // 3) 用 rootNavigatorKey 的 context 再弹“结算”
                  final next = await showPalaceModal<String>(
                    title: '结算',
                    desc: '当日行止已记，诸方态度各有变化。',
                    child: const ResolutionPanel(),
                  );

                  // 4) 根据返回值决定下一步（仍然弹在 Create 上）
                  if (next == 'toEnding') return;
                  if (next == 'toMonthEnd') return;

                  // 继续下一天：再次弹出 loop
                  await showPalaceModal<void>(
                    title: '今日',
                    desc: '深宫一日，步步皆是因果。',
                    child: const LoopPanel(),
                  );
                },
              ),
            );
          }),
        ],
      ],
    );
  }

  // ===== Style helpers =====

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
        color: Colors.white.withOpacity(0.6),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
    );
  }

  OptionTone _toneFromEvent(EventDef e, EventOption opt) {
    // 1) 按事件 tags
    if (e.tags.contains('risk')) return OptionTone.risk;
    if (e.tags.contains('power')) return OptionTone.power;
    if (e.tags.contains('rule')) return OptionTone.rule;
    if (e.tags.contains('favor')) return OptionTone.favor;

    // 2) 按效果做一点 MVP 推断（安全取值）
    final eff = opt.effect;
    int d(String k) => (eff.stats[k] as num?)?.toInt() ?? 0;

    final flags = eff.flagsAdd;
    final hasViolation = flags.any((x) => x.startsWith('violation_') || x == 'rule_violation');
    final hasBadFlag = flags.contains('cold_palace') || flags.contains('death_sentence');
    if (hasViolation || hasBadFlag) return OptionTone.risk;

    if (d('health') <= -2 || d('fame') <= -2 || d('favor') <= -2) return OptionTone.risk;
    if (d('scheming') >= 2) return OptionTone.power;
    if (d('fame') >= 2) return OptionTone.rule;
    if (d('favor') >= 1 || d('beauty') >= 1) return OptionTone.favor;

    return OptionTone.normal;
  }
}
