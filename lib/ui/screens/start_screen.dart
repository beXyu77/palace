import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/theme/app_theme.dart';

enum OpeningStyle { favor, power, virtue, talent, family, balanced }

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = <_OpeningCardData>[
      _OpeningCardData(
        key: 'favor',
        title: '以色侍君',
        identity: '宠爱向',
        accent: AppTheme.styleFavor,
        statDeltaText: const {
          'favor': '+8',
          'fame': '0',
          'scheming': '0',
          'talent': '0',
          'family': '0',
          'health': '-5',
          'beauty': '+10',
          'learning': '0',
        },
      ),
      _OpeningCardData(
        key: 'power',
        title: '静水深流',
        identity: '权谋向',
        accent: AppTheme.stylePower,
        statDeltaText: const {
          'favor': '-5',
          'fame': '0',
          'scheming': '+10',
          'talent': '0',
          'family': '0',
          'health': '0',
          'beauty': '0',
          'learning': '+5',
        },
      ),
      _OpeningCardData(
        key: 'virtue',
        title: '守礼自保',
        identity: '清名向',
        accent: AppTheme.styleVirtue,
        statDeltaText: const {
          'favor': '0',
          'fame': '+10',
          'scheming': '-5',
          'talent': '0',
          'family': '0',
          'health': '+5',
          'beauty': '0',
          'learning': '0',
        },
      ),
      _OpeningCardData(
        key: 'talent',
        title: '以艺入局',
        identity: '才艺向',
        accent: AppTheme.styleTalent,
        statDeltaText: const {
          'favor': '0',
          'fame': '0',
          'scheming': '0',
          'talent': '+10',
          'family': '-5',
          'health': '0',
          'beauty': '0',
          'learning': '+5',
        },
      ),
      _OpeningCardData(
        key: 'family',
        title: '人脉权势',
        identity: '家世向',
        accent: AppTheme.styleFamily,
        statDeltaText: const {
          'favor': '0',
          'fame': '+5',
          'scheming': '0',
          'talent': '0',
          'family': '+10',
          'health': '0',
          'beauty': '-5',
          'learning': '0',
        },
      ),
      _OpeningCardData(
        key: 'balanced',
        title: '选秀入宫',
        identity: '平衡向',
        accent: AppTheme.styleBalanced,
        statDeltaText: const {
          'favor': '±3',
          'fame': '±3',
          'scheming': '±3',
          'talent': '±3',
          'family': '±3',
          'health': '±3',
          'beauty': '±3',
          'learning': '±3',
        },
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('六种入宫路数'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final cross = w >= 900 ? 3 : (w >= 600 ? 2 : 1);

                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      sliver: SliverToBoxAdapter(child: _TopIntroCard()),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cross,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: cross == 1 ? 2.35 : 1.95,
                        ),
                        delegate: SliverChildBuilderDelegate(
                              (context, i) {
                            final data = cards[i];
                            return _OpeningCard(
                              data: data,
                              onTap: () => context.go('/create', extra: {'openingStyle': data.key}),
                            );
                          },
                          childCount: cards.length,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TopIntroCard extends StatelessWidget {
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
            '请选择你的入宫路数',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppTheme.textMain,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '不同路数会影响开局属性与事件倾向。',
            style: TextStyle(
              color: AppTheme.textSub,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpeningCardData {
  final String key; // favor/power/virtue/talent/family/balanced
  final String title;
  final String identity;
  final Color accent;
  final Map<String, String> statDeltaText;

  const _OpeningCardData({
    required this.key,
    required this.title,
    required this.identity,
    required this.accent,
    required this.statDeltaText,
  });
}

class _OpeningCard extends StatelessWidget {
  final _OpeningCardData data;
  final VoidCallback onTap;

  const _OpeningCard({required this.data, required this.onTap});

  static const double _avatarSize = 92;

  @override
  Widget build(BuildContext context) {
    final avatarPath =
        AssetPaths.avatarOpening[data.key] ?? AssetPaths.avatarOpening['balanced']!;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左头像 + 右属性（高度对齐）
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: _avatarSize,
                  height: _avatarSize,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: data.accent.withOpacity(0.25)),
                  ),
                  child: Image.asset(avatarPath, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: _avatarSize,
                    child: _StatGrid2x4(
                      accent: data.accent,
                      deltaText: data.statDeltaText,
                    ),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: data.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: data.accent.withOpacity(0.22)),
                  ),
                  child: Text(
                    data.identity,
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
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppTheme.textSub),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatGrid2x4 extends StatelessWidget {
  final Color accent;
  final Map<String, String> deltaText;

  const _StatGrid2x4({required this.accent, required this.deltaText});

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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _pairs.map((row) {
        return SizedBox(
          height: 20,
          child: Row(
            children: [
              Expanded(child: _pill(_cn[row[0]]!, deltaText[row[0]] ?? '0')),
              const SizedBox(width: 8),
              Expanded(child: _pill(_cn[row[1]]!, deltaText[row[1]] ?? '0')),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _pill(String label, String delta) {
    final t = delta.trim();
    final isNeg = t.startsWith('-');
    final isPlus = t.startsWith('+');
    final color = isNeg ? AppTheme.danger : (isPlus ? accent : AppTheme.textSub);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt.withOpacity(0.45),
        borderRadius: BorderRadius.circular(10),
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
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppTheme.textMain,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            delta,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }
}