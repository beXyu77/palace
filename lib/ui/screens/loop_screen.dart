import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/game/game_controller.dart';
import '../widgets/palace_modal.dart';
import 'loop_panel.dart';

class LoopScreen extends ConsumerStatefulWidget {
  const LoopScreen({super.key});

  @override
  ConsumerState<LoopScreen> createState() => _LoopScreenState();
}

class _LoopScreenState extends ConsumerState<LoopScreen> {
  bool _shown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shown) return;
    _shown = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final run = ref.read(gameProvider);
      if (run == null) return;

      // 如果没事件，先抽一个，避免弹空
      if (run.currentEvent == null) {
        ref.read(gameProvider.notifier).drawTodayEvent();
      }

      await showPalaceModal<void>(
        title: '今日',
        desc: '深宫一日，步步皆是因果。',
        child: const LoopPanel(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
