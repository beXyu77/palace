import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_OpeningItem>[
      _OpeningItem(
        keyName: 'favor',
        title: '以色侍君',
        identity: '宠爱向',
        accent: AppTheme.styleFavor,
      ),
      _OpeningItem(
        keyName: 'power',
        title: '静水深流',
        identity: '权谋向',
        accent: AppTheme.stylePower,
      ),
      _OpeningItem(
        keyName: 'virtue',
        title: '守礼自保',
        identity: '清名向',
        accent: AppTheme.styleVirtue,
      ),
      _OpeningItem(
        keyName: 'talent',
        title: '以艺入局',
        identity: '才艺向',
        accent: AppTheme.styleTalent,
      ),
      _OpeningItem(
        keyName: 'family',
        title: '人脉权势',
        identity: '家世向',
        accent: AppTheme.styleFamily,
      ),
      _OpeningItem(
        keyName: 'balanced',
        title: '选秀入宫',
        identity: '平衡向',
        accent: AppTheme.styleBalanced,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('后宫升职记 · 大晟'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderCard(
                    title: '后宫升职记 · 大晟',
                    subtitle: '选择你的入宫路数，开局倾向将影响后续事件与发展。',
                  ),
                  const SizedBox(height: 14),

                  Text(
                    '请选择你的入宫路数',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ...items.map((it) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OpeningRowTile(
                      item: it,
                      onTap: () {
                        // 跳到 create，具体数值放在 create 页展示即可
                        context.go('/create', extra: {'openingStyle': it.keyName});
                      },
                    ),
                  )),

                  const SizedBox(height: 10),

                  _SectionTitle('玩法说明'),
                  const SizedBox(height: 8),
                  _InfoCard(
                    icon: Icons.menu_book_rounded,
                    title: '核心玩法',
                    lines: const [
                      '• 每月进行行动与事件处理，属性会随选择浮动',
                      '• 宠爱/名声/权势/生存需要平衡，不是越高越安全',
                      '• 节庆与大事件会刷新事件池，派系斗争会升级',
                    ],
                  ),
                  const SizedBox(height: 10),
                  _InfoCard(
                    icon: Icons.warning_rounded,
                    title: '小提示',
                    lines: const [
                      '• 位份越高，收益更大，但被针对概率也更高',
                      '• 明站队收益更强，暗投更安全但有暴露风险',
                    ],
                  ),

                  const SizedBox(height: 14),

                  _SectionTitle('设置'),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    onOpenSettings: () {
                      // 你如果还没做设置页，可以先弹一个对话框占位
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('设置'),
                          content: const Text('设置页还没接入，后续可加入：音量/震动/文本速度/跳过动画等。'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('知道了'),
                            ),
                          ],
                        ),
                      );
                    },
                    onShowCredits: () {
                      showAboutDialog(
                        context: context,
                        applicationName: '后宫升职记 · 大晟',
                        applicationVersion: '0.1.0',
                        children: const [
                          Text('架空王朝互动模拟 · 事件驱动 · 多结局'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OpeningItem {
  final String keyName; // favor/power/virtue/talent/family/balanced
  final String title;
  final String identity;
  final Color accent;

  const _OpeningItem({
    required this.keyName,
    required this.title,
    required this.identity,
    required this.accent,
  });
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderCard({required this.title, required this.subtitle});

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
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppTheme.textMain,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
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

class _OpeningRowTile extends StatelessWidget {
  final _OpeningItem item;
  final VoidCallback onTap;

  const _OpeningRowTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 8),
              color: Colors.black.withOpacity(0.04),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 44,
              decoration: BoxDecoration(
                color: item.accent.withOpacity(0.65),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.identity,
                    style: TextStyle(
                      color: AppTheme.textSub,
                      fontWeight: FontWeight.w800,
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w900,
        color: AppTheme.textMain,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> lines;

  const _InfoCard({required this.icon, required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppTheme.textMain),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
                const SizedBox(height: 6),
                ...lines.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    t,
                    style: TextStyle(
                      color: AppTheme.textSub,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final VoidCallback onOpenSettings;
  final VoidCallback onShowCredits;

  const _SettingsCard({required this.onOpenSettings, required this.onShowCredits});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          _SettingsRow(
            icon: Icons.settings_rounded,
            title: '偏好设置',
            subtitle: '音量 / 震动 / 文本速度 / 跳过动画',
            onTap: onOpenSettings,
          ),
          const Divider(height: 16),
          _SettingsRow(
            icon: Icons.info_outline_rounded,
            title: '关于',
            subtitle: '版本信息与说明',
            onTap: onShowCredits,
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textMain),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: AppTheme.textSub, fontWeight: FontWeight.w700),
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
