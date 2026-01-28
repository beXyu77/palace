// lib/ui/screens/create_run_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/theme/app_theme.dart';
import '../../features/game/game_controller.dart';
import 'package:flutter/services.dart';

class CreateRunScreen extends ConsumerStatefulWidget {
  const CreateRunScreen({super.key});

  @override
  ConsumerState<CreateRunScreen> createState() => _CreateRunScreenState();
}

class _CreateRunScreenState extends ConsumerState<CreateRunScreen> {
  bool _inited = false;
  String _openingStyle = 'balanced';

  // ✅ 先不做改名功能，默认名字
  static const String _defaultPlayerName = '沈清辞';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 兜底：从 ModalRoute.arguments 拿 openingStyle
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['openingStyle'] is String) {
      _openingStyle = args['openingStyle'] as String;
    }
  }

  @override
  Widget build(BuildContext context) {
    final run = ref.watch(gameProvider);
    final ctrl = ref.read(gameProvider.notifier);

    if (!_inited) {
      _inited = true;
      Future.microtask(() async {
        await ctrl.initData();
        if (!mounted) return;
        ctrl.newRunSelectedGirl();
        ctrl.applyOpeningStyleSafe(_openingStyle);
        if (mounted) setState(() {});
        debugLoadAsset();
      });
    }

    final avatarPath =
        AssetPaths.avatarOpening[_openingStyle] ?? AssetPaths.avatarOpening['balanced']!;
    final rankName = _rankNameByTier(run?.rankTier ?? 1);

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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _TopProfileCard(
                    avatarPath: avatarPath,
                    run: run,
                    playerName: _defaultPlayerName,
                    rankName: rankName,
                  ),
                  const SizedBox(height: 14),
                  // ✅ 今日要务：保持你之前那种大卡片风格
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
                          Row(
                            children: [
                              const Text(
                                '今日要务',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                              const Spacer(),
                              _DayText(month: run?.month ?? 1, day: run?.day ?? 1),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '点击开始，将触发今日事件。',
                            style: TextStyle(color: AppTheme.textSub, fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 420,
                            child: FilledButton(
                              onPressed: () async {
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
                              style: TextStyle(color: AppTheme.textSub.withOpacity(0.9), fontSize: 12),
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
        ),
      ),
    );
  }


  Future<void> debugLoadAsset() async {
    const p = 'assets/images/avatars/opening/avatar_favor_01.png';
    try {
      await rootBundle.load(p);
      debugPrint('✅ asset ok: $p');
    } catch (e) {
      debugPrint('❌ asset fail: $p\n$e');
    }
  }

  // ✅ tier -> 位份名（与你 rank.json 的 tier 对齐）
  String _rankNameByTier(int tier) {
    switch (tier) {
      case 1:
        return '才人';
      case 2:
        return '选侍';
      case 3:
        return '常在';
      case 4:
        return '贵人';
      case 5:
        return '嫔';
      case 6:
        return '妃';
      case 7:
        return '贵妃';
      case 8:
        return '皇贵妃';
      case 9:
        return '皇后';
      default:
        return '才人';
    }
  }
}

class _DayText extends StatelessWidget {
  final int month;
  final int day;

  const _DayText({required this.month, required this.day});

  @override
  Widget build(BuildContext context) {
    return Text(
      '第 $month 月 · 第 $day 日',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppTheme.textSub.withOpacity(0.9),
      ),
    );
  }
}


class _TopProfileCard extends StatelessWidget {
  final String avatarPath;
  final dynamic run; // RunState?（避免你这边导入冲突）
  final String playerName;
  final String rankName;

  const _TopProfileCard({
    required this.avatarPath,
    required this.run,
    required this.playerName,
    required this.rankName,
  });

  int _v(String k) {
    final s = run?.stats;
    if (s == null) return 0;
    final m = s.toMap() as Map<String, int>;
    return m[k] ?? 0;
  }

  static const _order = <String>[
    'favor',
    'fame',
    'scheming',
    'talent',
    'family',
    'health',
    'beauty',
    'learning',
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;

        // ✅ 小屏更大头像，但整体更紧凑，避免溢出
        final avatar = w < 360 ? 112.0 : 120.0;
        final gap = w < 360 ? 10.0 : 12.0;
        final cardPad = w < 360 ? 12.0 : 14.0;

        final month = run?.month ?? 1;
        final day = run?.day ?? 1;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(cardPad),
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
                width: avatar,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: avatar,
                      height: avatar,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.black.withOpacity(0.10)),
                      ),
                      child: Image.asset(
                        avatarPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) {
                          return Center(
                            child: Text(
                              '找不到资源\n$avatarPath',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),

                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$playerName · $rankName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    // ✅ 月份日期同一行
                    // Row(
                    //   children: [
                    //     Expanded(child: _TightChip('第 $month 月')),
                    //     const SizedBox(width: 6),
                    //     Expanded(child: _TightChip('第 $day 日')),
                    //   ],
                    // ),
                  ],
                ),
              ),

              SizedBox(width: gap),

              // 右：数值（2列4行）
              Expanded(
                child: _StatsTightGrid(
                  keysInOrder: _order,
                  labelCN: _cn,
                  valueOf: _v,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TightChip extends StatelessWidget {
  final String text;
  const _TightChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt.withOpacity(0.45),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
        ),
      ),
    );
  }
}

class _StatsTightGrid extends StatelessWidget {
  final List<String> keysInOrder;
  final Map<String, String> labelCN;
  final int Function(String key) valueOf;

  const _StatsTightGrid({
    required this.keysInOrder,
    required this.labelCN,
    required this.valueOf,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: keysInOrder.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: 30, // ✅ 固定高度更紧凑，避免小屏溢出
      ),
      itemBuilder: (context, i) {
        final k = keysInOrder[i];
        final label = labelCN[k] ?? k;
        final v = valueOf(k);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.surfaceAlt.withOpacity(0.45),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    color: AppTheme.textMain,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$v',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  color: AppTheme.textMain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ✅ 给 GameController 一个安全兜底：即使你 controller 没写 applyOpeningStyle 也能跑
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
