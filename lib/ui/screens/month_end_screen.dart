import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/game/game_controller.dart';

class MonthEndScreen extends ConsumerStatefulWidget {
  const MonthEndScreen({super.key});

  @override
  ConsumerState<MonthEndScreen> createState() => _MonthEndScreenState();
}

class _MonthEndScreenState extends ConsumerState<MonthEndScreen> {
  Map<String, dynamic>? review;

  @override
  void initState() {
    super.initState();
    Future(() {
      final r = ref.read(gameProvider.notifier).computeMonthEndReview();
      setState(() => review = r);
    });
  }

  @override
  Widget build(BuildContext context) {
    final run = ref.watch(gameProvider);
    if (run == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('月末宫规考评')),
      body: review == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('评分：${review!['score']}'),
          Text('结果：${review!['result']}'),
          Text('违规次数：${review!['violations']}'),
          Text('位份变化：${review!['rankDelta']}'),
          const Spacer(),
          FilledButton(
            onPressed: () {
              if (run.endingId != null) {
                context.go('/ending');
              } else {
                ref.read(gameProvider.notifier).drawTodayEvent();
                context.go('/loop');
              }
            },
            child: Text(run.endingId != null ? '进入结局' : '进入下一月'),
          ),
        ]),
      ),
    );
  }
}
