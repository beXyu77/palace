// lib/ui/screens/start_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/theme/app_theme.dart';
import '../../features/game/game_controller.dart';

class StartScreen extends ConsumerWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(gameProvider);
    final ctrl = ref.read(gameProvider.notifier);
    final hasRun = run != null;

    final cards = <_OpeningCardData>[
      _OpeningCardData(key: 'favor', title: '以色侍君', identity: '宠爱向'),
      _OpeningCardData(key: 'power', title: '静水深流', identity: '权谋向'),
      _OpeningCardData(key: 'virtue', title: '守礼自保', identity: '清名向'),
      _OpeningCardData(key: 'talent', title: '以艺入局', identity: '才艺向'),
      _OpeningCardData(key: 'family', title: '人脉权势', identity: '家世向'),
      _OpeningCardData(key: 'balanced', title: '选秀入宫', identity: '平衡向'),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('紫宸宫'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderCard(hasRun: hasRun),
                  const SizedBox(height: 14),

                  if (!hasRun) ...[
                    // ✅ 新用户：显示六个入宫路数
                    LayoutBuilder(
                      builder: (context, c) {
                        final w = c.maxWidth;
                        final cross = w >= 900 ? 3 : (w >= 600 ? 2 : 1);

                        return GridView.builder(
                          itemCount: cards.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cross,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: cross == 1 ? 3.2 : 2.6,
                          ),
                          itemBuilder: (context, i) {
                            final data = cards[i];
                            return _OpeningCard(
                              data: data,
                              onTap: () {
                                context.go('/create', extra: {'openingStyle': data.key});
                              },
                            );
                          },
                        );
                      },
                    ),
                  ] else ...[
                    // ✅ 老用户：不显示路数，只显示 重生（+ 可选继续人生）
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              // ✅ 关键：继续人生必须带上 run.openingStyle
                              context.go('/create', extra: {'openingStyle': run!.openingStyle});
                            },
                            child: const Text('继续人生'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ctrl.resetRun();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已重生：请重新选择入宫路数')),
                              );
                            },
                            child: const Text('重生'),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 14),
                  _HelpCard(),
                  const SizedBox(height: 12),
                  _SettingsCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final bool hasRun;
  const _HeaderCard({required this.hasRun});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasRun ? '欢迎回宫' : '请选择你的入宫路数',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppTheme.textMain,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasRun ? '你可以继续当前人生，或选择重生改写命途。' : '不同路数会影响开局属性与事件倾向。',
            style: TextStyle(color: AppTheme.textSub, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('玩法说明', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Text(
            '• 每日触发事件 → 选择选项 → 属性变化\n'
                '• 月末进行考评，影响位份与风险\n'
                '• 宠爱 / 名声 / 权势 / 生存需要平衡',
            style: TextStyle(color: AppTheme.textSub, fontWeight: FontWeight.w700, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('设置', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Text(
            '• 音效 / 震动\n'
                '• 文本速度\n'
                '• 画质 / 性能',
            style: TextStyle(color: AppTheme.textSub, fontWeight: FontWeight.w700, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _OpeningCardData {
  final String key;
  final String title;
  final String identity;
  const _OpeningCardData({required this.key, required this.title, required this.identity});
}

class _OpeningCard extends StatelessWidget {
  final _OpeningCardData data;
  final VoidCallback onTap;
  const _OpeningCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final avatarPath = AssetPaths.avatarOpening[data.key] ?? AssetPaths.avatarOpening['balanced']!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              blurRadius: 14,
              offset: const Offset(0, 8),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black.withOpacity(0.08)),
              ),
              child: Image.asset(avatarPath, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.identity,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textSub,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textSub),
          ],
        ),
      ),
    );
  }
}
