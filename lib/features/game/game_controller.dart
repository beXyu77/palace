// lib/features/game/game_controller.dart
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/game_repository.dart';
import '../../core/models/game_models.dart';

final repoProvider = Provider<GameRepository>((ref) => GameRepository());

final gameProvider = StateNotifierProvider<GameController, RunState?>(
      (ref) => GameController(ref),
);

class GameController extends StateNotifier<RunState?> {
  GameController(this.ref) : super(null);

  final Ref ref;
  final Random _rng = Random();

  List<RankDef> _ranks = [];
  List<EventDef> _events = [];
  List<EndingDef> _endings = [];

  static const String defaultPlayerName = '沈清辞';

  bool _loaded = false;

  Future<void> initData() async {
    if (_loaded) return;
    final repo = ref.read(repoProvider);
    _ranks = await repo.loadRanks();
    _events = await repo.loadEvents();
    _endings = await repo.loadEndings();
    _loaded = true;
  }

  RankDef get currentRankDef {
    final tier = state?.rankTier ?? 1;
    if (_ranks.isEmpty) {
      // 兜底，防止 UI 先读
      return RankDef(id: 'cairen', name: '才人', tier: 1, riskMultiplier: 1.0);
    }
    return _ranks.firstWhere((r) => r.tier == tier, orElse: () => _ranks.first);
  }

  EndingDef? findEnding(String id) {
    try {
      return _endings.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// ✅ 新开局（把 openingStyle & 默认名字写入 state）
  void newRunSelectedGirl({String openingStyle = 'balanced'}) {
    final s = Stats.newbieTemplate(_rng);

    state = RunState(
      day: 1,
      month: 1,
      rankTier: 1,
      playerName: defaultPlayerName,
      openingStyle: openingStyle,
      stats: s,
      factionAtt: {
        Faction.dowager: 0,
        Faction.empress: 0,
        Faction.inlaws: 0,
        Faction.pure: 0,
        Faction.military: 0,
        Faction.eunuchs: 0,
      },
      flags: <String>{},
      currentEvent: null,
      lastStatDelta: const {},
      lastFactionDelta: const {},
      endingId: null,
    );
  }

  /// ✅ 改名（命名功能用）
  void setPlayerName(String name) {
    final rs = state;
    if (rs == null) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    state = rs.copyWith(playerName: trimmed);
  }

  /// ✅ 记录开局路数（用于“继续人生”正确显示头像/倾向）
  void setOpeningStyle(String styleKey) {
    final rs = state;
    if (rs == null) return;
    state = rs.copyWith(openingStyle: styleKey);
  }

  /// ✅ 重生：清空本次人生
  void resetRun() {
    state = null;
  }

  bool _checkConditions(EventDef e, RunState rs) {
    final c = e.conditions;

    final minTier = (c['rankMinTier'] as num?)?.toInt() ?? 1;
    final maxTier = (c['rankMaxTier'] as num?)?.toInt() ?? 99;
    if (rs.rankTier < minTier || rs.rankTier > maxTier) return false;

    final statMin = Map<String, dynamic>.from(c['statMin'] ?? {});
    for (final key in statMin.keys) {
      final minVal = (statMin[key] as num?)?.toInt() ?? 0;
      if (rs.stats.getByKey(key) < minVal) return false;
    }

    final flagHas = List<String>.from(c['flagHas'] ?? const []);
    for (final f in flagHas) {
      if (!rs.flags.contains(f)) return false;
    }

    final flagNot = List<String>.from(c['flagNot'] ?? const []);
    for (final f in flagNot) {
      if (rs.flags.contains(f)) return false;
    }

    return true;
  }

  EventDef _pickEvent(RunState rs) {
    if (_events.isEmpty) {
      throw StateError('Events not loaded. Call initData() before drawing events.');
    }

    final pool = _events.where((e) => _checkConditions(e, rs)).toList();
    if (pool.isEmpty) return _events.first;

    final rank = currentRankDef;
    final weighted = <EventDef>[];

    for (final e in pool) {
      final isPower = e.tags.contains('power');
      final w = isPower ? (2 * rank.riskMultiplier).round().clamp(1, 6) : 1;
      for (int i = 0; i < w; i++) {
        weighted.add(e);
      }
    }
    return weighted[_rng.nextInt(weighted.length)];
  }

  void drawTodayEvent() {
    final rs = state;
    if (rs == null) return;

    final e = _pickEvent(rs);
    state = rs.copyWith(
      currentEvent: e,
      lastStatDelta: const {},
      lastFactionDelta: const {},
      endingId: null,
    );
  }

  void chooseOption(int optionIndex) {
    final rs0 = state;
    if (rs0 == null || rs0.currentEvent == null) return;

    final opt = rs0.currentEvent!.options[optionIndex];
    final eff = opt.effect;

    final newFactionAtt = Map<Faction, int>.from(rs0.factionAtt);
    final newFlags = Set<String>.from(rs0.flags);

    // stats delta（num -> int）
    final statDelta = <String, int>{};
    eff.stats.forEach((k, v) => statDelta[k] = (v as num).toInt());

    // 应用 stats（传 Map<String,int>）
    final safeStatDelta = eff.stats.map((k, v) => MapEntry(k, (v as num).toInt()));
    rs0.stats.applyDelta(safeStatDelta);

    // factions
    final factionDelta = <Faction, int>{};
    eff.factions.forEach((k, v) {
      final f = _factionFromKey(k);
      final d = (v as num).toInt();
      factionDelta[f] = d;
      newFactionAtt[f] = ((newFactionAtt[f] ?? 0) + d).clamp(-100, 100);
    });

    for (final f in eff.flagsAdd) newFlags.add(f);
    for (final f in eff.flagsRemove) newFlags.remove(f);

    // ✅ 位份范围：1–9
    final rankDelta = (eff.rankDelta as num).toInt();
    final newTier = (rs0.rankTier + rankDelta).clamp(1, 9);

    final endingId = eff.immediateEndingId;

    state = rs0.copyWith(
      rankTier: newTier,
      factionAtt: newFactionAtt,
      flags: newFlags,
      lastStatDelta: statDelta,
      lastFactionDelta: factionDelta,
      endingId: endingId,
    );

    if (endingId == null) _checkImmediateFail();
  }

  void _checkImmediateFail() {
    final rs = state;
    if (rs == null) return;

    if (rs.stats.health <= 5 || rs.flags.contains('death_sentence')) {
      state = rs.copyWith(endingId: 'fail_death');
      return;
    }

    if ((rs.stats.favor <= 8 && rs.stats.fame <= 15) || rs.flags.contains('cold_palace')) {
      state = rs.copyWith(endingId: 'fail_cold');
      return;
    }
  }

  void nextDayOrMonthEnd() {
    final rs = state;
    if (rs == null) return;
    if (rs.endingId != null) return;

    final nextDay = rs.day + 1;
    if (nextDay <= 30) {
      state = rs.copyWith(day: nextDay, currentEvent: null);
    } else {
      state = rs.copyWith(currentEvent: null);
    }
  }

  Map<String, dynamic> computeMonthEndReview() {
    final rs0 = state!;
    final newFlags = Set<String>.from(rs0.flags);

    final violations = newFlags.where((f) => f.startsWith('violation_')).length;

    final score = (0.35 * rs0.stats.fame +
        0.25 * rs0.stats.favor +
        0.20 * rs0.stats.health +
        0.10 * rs0.stats.learning -
        10.0 * violations)
        .round();

    String result;
    int rankDelta;
    if (score >= 80) {
      result = '考评上佳';
      rankDelta = 1;
    } else if (score >= 55) {
      result = '考评平稳';
      rankDelta = 0;
    } else if (score >= 35) {
      result = '考评不佳';
      rankDelta = -1;
    } else {
      result = '考评失仪';
      newFlags.add('cold_palace');
      rankDelta = -1;
    }

    // ✅ 位份范围：1–9
    final newTier = (rs0.rankTier + rankDelta).clamp(1, 9);

    state = rs0.copyWith(rankTier: newTier, flags: newFlags);

    _checkMainEndings();

    if (state?.endingId == null) {
      state = state!.copyWith(month: rs0.month + 1, day: 1);
    }

    return {
      'score': score,
      'result': result,
      'violations': violations,
      'rankDelta': rankDelta,
      'newTier': newTier,
    };
  }

  void _checkMainEndings() {
    final rs = state!;
    if (rs.rankTier >= 5 && rs.stats.fame >= 85 && rs.stats.scheming >= 70) {
      state = rs.copyWith(endingId: 'main_empress');
      return;
    }
    if (rs.rankTier >= 5 && rs.stats.learning >= 80 && rs.stats.fame >= 70) {
      state = rs.copyWith(endingId: 'main_regent');
      return;
    }
    if (rs.stats.favor >= 92 && rs.stats.beauty >= 80) {
      state = rs.copyWith(endingId: 'main_favor');
      return;
    }
    if (rs.month >= 12 && rs.stats.health >= 60 && rs.stats.fame >= 55) {
      state = rs.copyWith(endingId: 'main_safe');
      return;
    }
  }

  Faction _factionFromKey(String k) {
    switch (k) {
      case 'dowager':
        return Faction.dowager;
      case 'empress':
        return Faction.empress;
      case 'inlaws':
        return Faction.inlaws;
      case 'pure':
        return Faction.pure;
      case 'military':
        return Faction.military;
      case 'eunuchs':
        return Faction.eunuchs;
      default:
        return Faction.eunuchs;
    }
  }
}
