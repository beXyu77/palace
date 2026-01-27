import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/game_models.dart';
import '../../../ui/widgets/event_card.dart';
import '../../features/game/game_controller.dart';

class LoopPanel extends ConsumerWidget {
  const LoopPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(gameProvider);
    final ctrl = ref.read(gameProvider.notifier);

    if (run == null || run.currentEvent == null) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('今日暂无事件')),
      );
    }

    final EventDef e = run.currentEvent!;

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日事件',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppTheme.textMain,
            ),
          ),
          const SizedBox(height: 10),

          /// ✅ 这里传 event
          EventCard(event: e),

          const SizedBox(height: 12),

          ...List.generate(e.options.length, (i) {
            final opt = e.options[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    ctrl.chooseOption(i);
                    Navigator.of(context).pop('chosen');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      opt.text,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 4),
          Text(
            '点击空白处或右上角 × 可关闭',
            style: TextStyle(fontSize: 12, color: AppTheme.textSub),
          ),
        ],
      ),
    );
  }
}
