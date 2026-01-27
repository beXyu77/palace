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
  bool _inited = false;
  String _openingStyle = 'balanced';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ 从 go_router 的 extra 拿 openingStyle（最稳）
    // 但在 Screen 内我们拿不到 GoRouterState，所以用 ModalRoute.arguments 兜底
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['openingStyle'] is String) {
      _openingStyle = args['openingStyle'] as String;
    }
  }

  @override
  Widget build(BuildContext context) {
    final run = ref.watch(gameProvider);
    final ctrl = ref.read(gameProvider.notifier);

    // ✅ 首次进入主页：初始化数据 + 创建新 run + 应用开局倾向（只做一次）
    if (!_inited) {
      _inited = true;
      Future.microtask(() async {
        await ctrl.initData();
        if (!mounted) return;
        ctrl.newRunSelectedGirl();
        ctrl.applyOpeningStyleSafe(_openingStyle);
        setState(() {}); // 刷新显示
      });
    }

    final avatarPath =
        AssetPaths.avatarOpening[_openingStyle] ?? AssetPaths.avatarOpening['balanced']!;
    final profile = _profileByStyle(_openingStyle);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('紫宸宫 · ${profile.title}'),
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
                  // 顶部：专属主页信息卡
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black.withOpacity(0.06)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 头像
                        Container(
                          width: 120,
                          height: 120,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: profile.accent.withOpacity(0.25)),
                          ),
                          child: Image.asset(avatarPath, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: profile.accent.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: profile.accent.withOpacity(0.22)),
                                    ),
                                    child: Text(
                                      profile.identity,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.textMain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      profile.title,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // 日/月信息（UI）
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _infoChip('第 ${run?.month ?? 1} 月'),
                                  _infoChip('第 ${run?.day ?? 1} 日'),
                                  _infoChip('位份 Tier：${run?.rankTier ?? 1}'),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // 8维属性（两列4行）
                              SizedBox(
                                height: 120, // 与头像高度一致
                                child: _StatsGrid(run: run),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 主页功能区（先做一个主按钮：开始今日事件）
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
                          const Text('今日要务', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 10),
                          Text(
                            '点击开始，将触发今日事件（后续我们把事件做成弹窗覆盖在主页上）。',
                            style: TextStyle(color: AppTheme.textSub, fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 420,
                            child: FilledButton(
                              onPressed: () async {
                                ctrl.drawTodayEvent();
                                // TODO：下一步：showDialog 弹出 LoopPanel
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

  _OpeningProfile _profileByStyle(String key) {
    switch (key) {
      case 'favor':
        return _OpeningProfile('以色侍君', '宠爱向', AppTheme.styleFavor);
      case 'power':
        return _OpeningProfile('静水深流', '权谋向', AppTheme.stylePower);
      case 'virtue':
        return _OpeningProfile('守礼自保', '清名向', AppTheme.styleVirtue);
      case 'talent':
        return _OpeningProfile('以艺入局', '才艺向', AppTheme.styleTalent);
      case 'family':
        return _OpeningProfile('人脉权势', '家世向', AppTheme.styleFamily);
      default:
        return _OpeningProfile('选秀入宫', '平衡向', AppTheme.styleBalanced);
    }
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt.withOpacity(0.45),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
    );
  }
}

class _OpeningProfile {
  final String title;
  final String identity;
  final Color accent;
  _OpeningProfile(this.title, this.identity, this.accent);
}

class _StatsGrid extends StatelessWidget {
  final dynamic run; // RunState?，避免你这边类型导入冲突
  const _StatsGrid({required this.run});

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
    final m = s.toMap() as Map<String, int>;
    return m[k] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _pairs.map((row) {
        return SizedBox(
          height: 24,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt.withOpacity(0.45),
        borderRadius: BorderRadius.circular(12),
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
