// lib/ui/screens/create_run_screen.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/theme/app_theme.dart';
import '../../features/game/game_controller.dart';

class CreateRunScreen extends ConsumerStatefulWidget {
  const CreateRunScreen({super.key});

  @override
  ConsumerState<CreateRunScreen> createState() => _CreateRunScreenState();
}

class _CreateRunScreenState extends ConsumerState<CreateRunScreen> {
  bool _bootstrapped = false;
  bool _readExtraOnce = false;

  String _openingStyle = 'balanced';
  static const String _defaultName = '沈清辞';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ 读取 openingStyle（只读一次）
    if (!_readExtraOnce) {
      _readExtraOnce = true;

      String? style;

      final extra = GoRouterState.of(context).extra;
      if (extra is Map && extra['openingStyle'] is String) {
        style = extra['openingStyle'] as String;
      }

      final args = ModalRoute.of(context)?.settings.arguments;
      if (style == null && args is Map && args['openingStyle'] is String) {
        style = args['openingStyle'] as String;
      }

      if (style != null && style.isNotEmpty) _openingStyle = style;
    }

    // ✅ 首次进入：初始化数据 + 创建 run + 应用开局倾向（只做一次）
    if (!_bootstrapped) {
      _bootstrapped = true;
      final ctrl = ref.read(gameProvider.notifier);

      Future.microtask(() async {
        await ctrl.initData();
        if (!mounted) return;
        ctrl.newRunSelectedGirl();
        ctrl.applyOpeningStyleSafe(_openingStyle);
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final run = ref.watch(gameProvider);
    final ctrl = ref.read(gameProvider.notifier);

    final avatarPath =
        AssetPaths.avatarOpening[_openingStyle] ?? AssetPaths.avatarOpening['balanced']!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('紫宸宫'),
        centerTitle: true,
        leading: IconButton(
          tooltip: '返回重选路数',
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;

            // 头像大小：手机端更合适
            final avatarSize = math.max(84.0, math.min(118.0, w * 0.22));

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ✅ 顶部卡片（按你给的布局）
                      _TopCard(
                        avatarPath: avatarPath,
                        avatarSize: avatarSize,
                        name: _defaultName,
                        rankName: _rankNameFromRun(run),
                        month: run?.month ?? 1,
                        day: run?.day ?? 1,
                        run: run,
                      ),

                      const SizedBox(height: 14),

                      // ✅ 今日要务：保持你之前的尺寸/布局（不缩小）
                      Expanded(
                        child: Container(
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
                              const Text(
                                '今日要务',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '点击开始，将触发今日事件（后续我们把事件做成弹窗覆盖在主页上）。',
                                style: TextStyle(
                                  color: AppTheme.textSub,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 420,
                                child: FilledButton(
                                  onPressed: () {
                                    ctrl.drawTodayEvent();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('已生成今日事件（下一步接弹窗）。')),
                                    );
                                  },
                                  child: const Text('开始今日事件'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: Text(
                                  '你随时可以返回重选路数。',
                                  style: TextStyle(
                                    color: AppTheme.textSub.withOpacity(0.9),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _rankNameFromRun(dynamic run) {
    try {
      final v = run?.rankName;
      if (v is String && v.trim().isNotEmpty) return v.trim();
    } catch (_) {}
    return '才人';
  }
}

class _TopCard extends StatelessWidget {
  final String avatarPath;
  final double avatarSize;
  final String name;
  final String rankName;
  final int month;
  final int day;
  final dynamic run;

  const _TopCard({
    required this.avatarPath,
    required this.avatarSize,
    required this.name,
    required this.rankName,
    required this.month,
    required this.day,
    required this.run,
  });

  @override
  Widget build(BuildContext context) {
    // 右侧数值区：每行高度更小一点
    const rowGap = 8.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左：头像 + 名字位份 + 月日
          SizedBox(
            width: avatarSize,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black.withOpacity(0.08)),
                  ),
                  child: Image.asset(avatarPath, fit: BoxFit.cover),
                ),
                const SizedBox(height: 10),

                // ✅ 沈清辞 · 才人
                Text(
                  '$name  ·  $rankName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textMain,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    _chip('第 $month 月'),
                    const SizedBox(width: 8),
                    _chip('第 $day 日'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 右：2×4 数值区（顶对齐头像）
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                children: [
                  _StatsGridCompact(run: run, gap: rowGap),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt.withOpacity(0.45),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          color: AppTheme.textMain,
        ),
      ),
    );
  }
}

class _StatsGridCompact extends StatelessWidget {
  final dynamic run;
  final double gap;
  const _StatsGridCompact({required this.run, required this.gap});

  static const _pairs = <List<String>>[
    ['favor', 'fame'],
    ['scheming', 'talent'],
    ['family', 'health'],
    ['beauty', 'learning'],
  ];

  static const _cn = <String, String>{
    'favor': '宠爱',
    'fame': '名声',
    'scheming': '心机',
    'talent': '才艺',
    'family': '家世',
    'health': '健康',
    'beauty': '外貌',
    'learning': '学识',
  };

  int _v(String k) {
    final s = run?.stats;
    if (s == null) return 0;
    try {
      final m = s.toMap() as Map<String, int>;
      return m[k] ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _pairs.map((row) {
        return Padding(
          padding: EdgeInsets.only(bottom: gap),
          child: Row(
            children: [
              Expanded(child: _pill('${_cn[row[0]]!}  ${_v(row[0])}')),
              const SizedBox(width: 10),
              Expanded(child: _pill('${_cn[row[1]]!}  ${_v(row[1])}')),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _pill(String text) {
    // ✅ 数值栏更小：高度更矮、字体更小、内边距更小
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt.withOpacity(0.40),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          color: AppTheme.textMain,
        ),
      ),
    );
  }
}

/// 给 GameController 一个安全兜底：即使你 controller 没写 applyOpeningStyle 也能跑
extension _OpeningStyleApplySafe on GameController {
  void applyOpeningStyleSafe(String styleKey) {
    final rs = state;
    if (rs == null) return;

    Map<String, dynamic> delta;
    switch (styleKey) {
      case 'favor':
        delta = {'beauty': 10, 'favor': 8, 'health': -5};
        break;
      case 'power':
        delta = {'scheming': 10, 'learning': 5, 'favor': -5};
        break;
      case 'virtue':
        delta = {'fame': 10, 'health': 5, 'scheming': -5};
        break;
      case 'talent':
        delta = {'talent': 10, 'learning': 5, 'family': -5};
        break;
      case 'family':
        delta = {'family': 10, 'fame': 5, 'beauty': -5};
        break;
      default:
        delta = {};
        break;
    }

    rs.stats.applyDelta(delta);
    state = rs.copyWith(stats: rs.stats);
  }
}
