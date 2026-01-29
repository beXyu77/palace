// lib/ui/screens/create_run_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/theme/app_theme.dart';
import '../../features/game/game_controller.dart';

class CreateRunScreen extends ConsumerStatefulWidget {
  final String? openingStyle; // 可空：继续人生时不传
  const CreateRunScreen({super.key, this.openingStyle});

  @override
  ConsumerState<CreateRunScreen> createState() => _CreateRunScreenState();
}

class _CreateRunScreenState extends ConsumerState<CreateRunScreen> {
  bool _inited = false;

  @override
  Widget build(BuildContext context) {
    final run = ref.watch(gameProvider);
    final ctrl = ref.read(gameProvider.notifier);

    // ✅ 统一一个永远非空的 styleKey：
    // 1) 优先用路由传入；2) 否则用 run 里记录的 openingStyle；3) 否则 balanced
    final styleKey =
    (widget.openingStyle != null && widget.openingStyle!.trim().isNotEmpty)
        ? widget.openingStyle!.trim()
        : ((run?.openingStyle ?? '').isNotEmpty ? run!.openingStyle : 'balanced');

    // ✅ 只初始化一次：仅当没有 run 时创建新人生 + 应用开局
    if (!_inited) {
      _inited = true;
      Future.microtask(() async {
        await ctrl.initData();
        if (!mounted) return;

        final rs = ref.read(gameProvider);
        if (rs == null) {
          // 第一次：创建 run -> 记录 openingStyle -> 应用加成
          ctrl.newRunSelectedGirl(openingStyle: styleKey);
          ctrl.applyOpeningStyleSafe(styleKey);
        }
        if (mounted) setState(() {});
      });
    }

    final avatarPath =
        AssetPaths.avatarOpening[styleKey] ?? AssetPaths.avatarOpening['balanced']!;
    final rankName = _rankNameByTier(run?.rankTier ?? 1);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('紫宸宫'),
        centerTitle: true,
        leading: IconButton(
          tooltip: '返回开始页',
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
                    playerName: run?.playerName ?? GameController.defaultPlayerName,
                    rankName: rankName,
                    onTapRename: () => _showRenameDialog(context, ref),
                  ),
                  const SizedBox(height: 14),

                  // 今日要务卡：保持你原来的大卡片
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
                              Text(
                                '第 ${run?.month ?? 1} 月 · 第 ${run?.day ?? 1} 日',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textSub.withOpacity(0.9),
                                ),
                              ),
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
                              '你随时可以返回开始页。',
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
        ),
      ),
    );
  }

  // ✅ tier -> 位份名（1–9）
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

class _TopProfileCard extends StatelessWidget {
  final String avatarPath;
  final dynamic run; // RunState?
  final String playerName;
  final String rankName;
  final VoidCallback onTapRename;

  const _TopProfileCard({
    required this.avatarPath,
    required this.run,
    required this.playerName,
    required this.rankName,
    required this.onTapRename,
  });

  // ✅ 取数：run.stats.toMap() -> Map<String,int>
  int _v(String k) {
    final s = run?.stats;
    if (s == null) return 0;
    final m = s.toMap() as Map<String, int>;
    return m[k] ?? 0;
  }

  // ✅ 8 维顺序
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

  // ✅ 中文名
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
        final avatar = w < 360 ? 112.0 : 120.0;
        final gap = w < 360 ? 10.0 : 12.0;
        final cardPad = w < 360 ? 12.0 : 14.0;

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
                      child: Image.asset(avatarPath, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 8),

                    // ✅ 名字可点击修改
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: onTapRename,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$playerName · $rankName',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.edit_rounded, size: 16, color: AppTheme.textSub),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: gap),
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
        mainAxisExtent: 30,
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

/// ✅ 兜底加成：只在“新开局”时调用
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

Future<void> _showRenameDialog(BuildContext context, WidgetRef ref) async {
  final ctrl = ref.read(gameProvider.notifier);
  final current = ref.read(gameProvider)?.playerName ?? GameController.defaultPlayerName;

  final tec = TextEditingController(text: current);

  final newName = await showDialog<String>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('修改名字'),
        content: TextField(
          controller: tec,
          autofocus: true,
          maxLength: 8,
          decoration: const InputDecoration(
            hintText: '请输入名字（最多8字）',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(tec.text),
            child: const Text('保存'),
          ),
        ],
      );
    },
  );

  if (newName == null) return;
  final name = newName.trim();
  if (name.isEmpty) return;

  ctrl.setPlayerName(name);
}
