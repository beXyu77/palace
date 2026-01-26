import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/game/game_controller.dart';
import '../widgets/stat_chip.dart';

class CreateRunScreen extends ConsumerStatefulWidget {
  const CreateRunScreen({super.key});

  @override
  ConsumerState<CreateRunScreen> createState() => _CreateRunScreenState();
}

class _CreateRunScreenState extends ConsumerState<CreateRunScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future(() async {
      await ref.read(gameProvider.notifier).initData();
      ref.read(gameProvider.notifier).newRunSelectedGirl();
      setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final run = ref.watch(gameProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('选秀入宫')),
      body: _loading || run == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('初始属性', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            StatChip(label: '宠爱', value: run.stats.favor),
            StatChip(label: '名声', value: run.stats.fame),
            StatChip(label: '心机', value: run.stats.scheming),
            StatChip(label: '才艺', value: run.stats.talent),
            StatChip(label: '家世', value: run.stats.family),
            StatChip(label: '健康', value: run.stats.health),
            StatChip(label: '外貌', value: run.stats.beauty),
            StatChip(label: '学识', value: run.stats.learning),
          ]),
          const Spacer(),
          FilledButton(
            onPressed: () {
              ref.read(gameProvider.notifier).drawTodayEvent();
              context.go('/loop');
            },
            child: const Text('入宫 · 开始第一天'),
          ),
        ]),
      ),
    );
  }
}
