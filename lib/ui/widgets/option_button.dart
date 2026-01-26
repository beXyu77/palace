import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum OptionTone { normal, favor, rule, power, risk }

class OptionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final OptionTone tone;

  const OptionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.tone = OptionTone.normal,
  });

  Color _borderColor() {
    switch (tone) {
      case OptionTone.risk:
        return AppTheme.danger.withOpacity(0.55);
      case OptionTone.power:
        return AppTheme.primary.withOpacity(0.45);
      case OptionTone.rule:
        return AppTheme.factionDowager.withOpacity(0.45);
      case OptionTone.favor:
        return AppTheme.secondary.withOpacity(0.55);
      case OptionTone.normal:
        return Colors.black.withOpacity(0.10);
    }
  }

  Color _bgColor(Set<WidgetState> states) {
    final disabled = states.contains(WidgetState.disabled);
    if (disabled) return AppTheme.textDisabled.withOpacity(0.25);

    // 用“宣纸底 + 轻染色”避免太艳
    switch (tone) {
      case OptionTone.risk:
        return AppTheme.surface.withOpacity(0.96);
      case OptionTone.power:
        return AppTheme.surface.withOpacity(0.96);
      case OptionTone.rule:
        return AppTheme.surface.withOpacity(0.96);
      case OptionTone.favor:
        return AppTheme.surfaceAlt.withOpacity(0.55);
      case OptionTone.normal:
        return AppTheme.surface.withOpacity(0.96);
    }
  }

  Color _textColor(Set<WidgetState> states) {
    final disabled = states.contains(WidgetState.disabled);
    if (disabled) return AppTheme.textDisabled;

    switch (tone) {
      case OptionTone.risk:
        return AppTheme.danger.withOpacity(0.95);
      case OptionTone.power:
        return AppTheme.primary;
      case OptionTone.rule:
        return AppTheme.factionDowager;
      case OptionTone.favor:
        return AppTheme.textMain;
      case OptionTone.normal:
        return AppTheme.textMain;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(_bgColor),
        foregroundColor: WidgetStateProperty.resolveWith(_textColor),
        elevation: const WidgetStatePropertyAll(0),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: _borderColor(), width: 1),
          ),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w800, fontSize: 14, height: 1.2),
        ),
        overlayColor: WidgetStatePropertyAll(Colors.black.withOpacity(0.04)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text),
      ),
    );
  }
}
