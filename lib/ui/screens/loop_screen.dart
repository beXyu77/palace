import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../features/game/game_controller.dart';
import '../../ui/screens/loop_panel.dart';
import '../widgets/palace_modal.dart';

class LoopScreen extends ConsumerStatefulWidget {
  const LoopScreen({super.key});

  @override
  ConsumerState<LoopScreen> createState() => _LoopScreenState();
}

class _LoopScreenState extends ConsumerState<LoopScreen> {
  bool _opened = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ 只在首次进入时自动弹一次，避免重复弹窗
    if (!_opened) {
      _opened = true;
      Future.microtask(() async {
        final ctrl = ref.read(gameProvider.notifier);

        // 确保有事件
        ctrl.drawTodayEvent();

        if (!mounted) return;

        final r = await PalaceModal.show(
          context: context,
          child: const LoopPanel(),
          maxWidth: 560,
        );

        if (!mounted) return;

        // 用户完成选择（LoopPanel pop('chosen')）
        if (r == 'chosen') {
          // 这里下一步应该弹 ResolutionPanel
          // 你现在的 resolution_screen.dart 还在，我们后面会改成 ResolutionPanel
          // 先用 SnackBar 占位，证明流程通了
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已选择选项，下一步弹出结算面板')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final run = ref.watch(gameProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('回合推进')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '第 ${run?.month ?? 1} 月 · 第 ${run?.day ?? 1} 日',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Text(
                  '此页面用于承载“弹窗循环”，实际玩法仍在主页上弹出。',
                  style: TextStyle(color: AppTheme.textSub, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () async {
                    final ctrl = ref.read(gameProvider.notifier);
                    ctrl.drawTodayEvent();

                    final r = await PalaceModal.show(
                      context: context,
                      child: const LoopPanel(),
                      maxWidth: 560,
                    );

                    if (!mounted) return;

                    if (r == 'chosen') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已选择选项（下一步接结算面板）')),
                      );
                    }
                  },
                  child: const Text('手动弹出今日事件'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
