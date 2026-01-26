import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/game/game_controller.dart';
import '../../core/theme/app_theme.dart';

class EndingScreen extends ConsumerWidget {
  const EndingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(gameProvider);
    final ctrl = ref.read(gameProvider.notifier);
    if (run == null || run.endingId == null) return const SizedBox.shrink();

    final ending = ctrl.findEnding(run.endingId!);

    return Scaffold(
      appBar: AppBar(title: const Text('结局')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ending?.title ?? '结局', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Text(
            ending?.description ?? '（缺少结局描述）',
            style: TextStyle(height: 1.35, color: AppTheme.textMain.withOpacity(0.9)),
          ),
          const Spacer(),
          FilledButton(
            onPressed: () => context.go('/'),
            child: const Text('返回标题（重新开局）'),
          ),
        ]),
      ),
    );
  }
}
