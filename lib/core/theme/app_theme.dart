// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import '../models/game_models.dart';

class AppTheme {
  AppTheme._();

  // ===== Base palette (Palace Classic) =====
  static const Color background = Color(0xFFD0DFE6);
  static const Color surface = Color(0xFFF0FCF8);
  static const Color surfaceAlt = Color(0xFFC7D2D4);

  static const Color textMain = Color(0xFF2B3541); // 墨青正文
  static const Color textSub = Color(0xFF5E626D); // 次级文字
  static const Color textDisabled = Color(0xFF9AA1A8); // 禁用/灰态

  static const Color primary = Color(0xFF360508); // 深宫朱砂（重点/主按钮）
  static const Color secondary = Color(0xFFEC592C); // 宫灯暖橙（交互/强调）

  static const Color danger = Color(0xFFE62013); // 惩罚/失败
  static const Color success = Color(0xFF5C8A6A); // 晋升/成功

  // ===== UI tokens =====
  static const Color eventCard = surface; // 事件卡
  static const Color optionCard = surfaceAlt; // 选项卡（可选：你也可统一用 surface）
  static const Color divider = Color(0x14000000); // 8% black
  static const Color borderSoft = Color(0x0F000000); // 6% black

  // ===== Faction subtle tones =====
  static const Color factionDowager = Color(0xFF904059); // 太后党
  static const Color factionEmpress = Color(0xFFEC592C); // 皇后党
  static const Color factionInlaws = Color(0xFF5E626D); // 外戚党
  static const Color factionPure = Color(0xFF9AD3DE); // 清流党
  static const Color factionMilitary = Color(0xFFC27D44); // 军功派
  static const Color factionEunuchs = Color(0xFF68657A); // 内廷势力
  static const styleFavor = Color(0xFF904059);   // 红：宠爱向（偏胭脂）
  static const stylePower = Color(0xFF2F5F8F);   // 蓝：权谋向（偏青黛）
  static const styleVirtue = Color(0xFF2E6B5B);  // 绿：清名向（偏松青）
  static const styleTalent = Color(0xFFC49A3A);  // 黄：才艺向（偏鎏金）
  static const styleFamily = Color(0xFF6A4B8A);  // 紫：家世向（偏紫檀）
  static const styleBalanced = Color(0xFF5E626D); // 灰：平衡向


  static Color factionColor(Faction f) {
    switch (f) {
      case Faction.dowager:
        return factionDowager;
      case Faction.empress:
        return factionEmpress;
      case Faction.inlaws:
        return factionInlaws;
      case Faction.pure:
        return factionPure;
      case Faction.military:
        return factionMilitary;
      case Faction.eunuchs:
        return factionEunuchs;
    }
  }

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        surface: surface,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: background,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textMain,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: textMain,
        ),
      ),

      // Text
      textTheme: base.textTheme.copyWith(
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textMain,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textMain,
        ),
        bodyLarge: const TextStyle(
          fontSize: 15,
          height: 1.35,
          color: textMain,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          height: 1.35,
          color: textMain,
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          height: 1.35,
          color: textSub,
        ),
      ),

      // Cards (fixes CardTheme type issues)
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: borderSoft),
        ),
      ),

      // Dialog (fixes DialogTheme type issues)
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: borderSoft),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: textMain,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          height: 1.35,
          color: textMain,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return textDisabled;
            return primary;
          }),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.08)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(primary),
          side: WidgetStateProperty.all(const BorderSide(color: borderSoft)),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(primary),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ),
      ),

      // Chips (for stat/faction pills)
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surface,
        disabledColor: surface.withOpacity(0.6),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          color: textMain,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSoft),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textMain,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
