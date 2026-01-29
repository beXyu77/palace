import 'dart:math';

enum Faction { dowager, empress, inlaws, pure, military, eunuchs }

class Stats {
  int favor, fame, scheming, talent, family, health, beauty, learning;

  Stats({
    required this.favor,
    required this.fame,
    required this.scheming,
    required this.talent,
    required this.family,
    required this.health,
    required this.beauty,
    required this.learning,
  });

  factory Stats.fromMap(Map<String, dynamic> m) => Stats(
    favor: (m['favor'] as num?)?.toInt() ?? 50,
    fame: (m['fame'] as num?)?.toInt() ?? 50,
    scheming: (m['scheming'] as num?)?.toInt() ?? 50,
    talent: (m['talent'] as num?)?.toInt() ?? 50,
    family: (m['family'] as num?)?.toInt() ?? 50,
    health: (m['health'] as num?)?.toInt() ?? 50,
    beauty: (m['beauty'] as num?)?.toInt() ?? 50,
    learning: (m['learning'] as num?)?.toInt() ?? 50,
  );

  Map<String, int> toMap() => {
    'favor': favor,
    'fame': fame,
    'scheming': scheming,
    'talent': talent,
    'family': family,
    'health': health,
    'beauty': beauty,
    'learning': learning,
  };

  int getByKey(String k) => toMap()[k] ?? 0;

  void applyDelta(Map<String, dynamic> delta) {
    int clamp100(int v) => v.clamp(1, 100);

    int d(String key) => (delta[key] as num?)?.toInt() ?? 0;

    favor = clamp100(favor + d('favor'));
    fame = clamp100(fame + d('fame'));
    scheming = clamp100(scheming + d('scheming'));
    talent = clamp100(talent + d('talent'));
    family = clamp100(family + d('family'));
    health = clamp100(health + d('health'));
    beauty = clamp100(beauty + d('beauty'));
    learning = clamp100(learning + d('learning'));
  }

  static Stats newbieTemplate(Random r) {
    int b(int base) => (base + r.nextInt(11) - 5).clamp(1, 100);
    return Stats(
      favor: b(35),
      fame: b(40),
      scheming: b(35),
      talent: b(45),
      family: b(35),
      health: b(55),
      beauty: b(55),
      learning: b(45),
    );
  }
}

class RankDef {
  final String id;
  final String name;
  final int tier; // 数字越大越高
  final double riskMultiplier;

  RankDef({
    required this.id,
    required this.name,
    required this.tier,
    required this.riskMultiplier,
  });

  factory RankDef.fromMap(Map<String, dynamic> m) => RankDef(
    id: (m['id'] ?? '').toString(),
    name: (m['name'] ?? '').toString(),
    tier: (m['tier'] as num?)?.toInt() ?? 1,
    riskMultiplier: (m['riskMultiplier'] as num?)?.toDouble() ?? 1.0,
  );
}

class EventOptionEffect {
  final Map<String, dynamic> stats;
  final Map<String, dynamic> factions;
  final List<String> flagsAdd;
  final List<String> flagsRemove;
  final int rankDelta;
  final String? immediateEndingId;

  EventOptionEffect({
    required this.stats,
    required this.factions,
    required this.flagsAdd,
    required this.flagsRemove,
    required this.rankDelta,
    required this.immediateEndingId,
  });

  factory EventOptionEffect.fromMap(Map<String, dynamic> m) => EventOptionEffect(
    stats: Map<String, dynamic>.from(m['stats'] ?? const {}),
    factions: Map<String, dynamic>.from(m['factions'] ?? const {}),
    // ✅ 兼容旧字段 flags: []
    flagsAdd: List<String>.from(m['flagsAdd'] ?? m['flags'] ?? const []),
    flagsRemove: List<String>.from(m['flagsRemove'] ?? const []),
    rankDelta: (m['rankDelta'] as num?)?.toInt() ?? 0,
    immediateEndingId: m['immediateEndingId']?.toString(),
  );
}

class EventOption {
  final String id;
  final String text;
  final EventOptionEffect effect;

  EventOption({
    required this.id,
    required this.text,
    required this.effect,
  });

  factory EventOption.fromMap(Map<String, dynamic> m) {
    final rawEff = (m['effect'] ?? m['effects'] ?? const {});
    final effMap = (rawEff is Map) ? Map<String, dynamic>.from(rawEff) : <String, dynamic>{};

    return EventOption(
      id: (m['id'] ?? m['optionId'] ?? '').toString(),
      text: (m['text'] ?? '').toString(),
      effect: EventOptionEffect.fromMap(effMap),
    );
  }
}

class EventDef {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final Map<String, dynamic> conditions;
  final List<EventOption> options;

  EventDef({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.conditions,
    required this.options,
  });

  factory EventDef.fromMap(Map<String, dynamic> m) => EventDef(
    id: (m['id'] ?? m['eventId'] ?? '').toString(),
    title: (m['title'] ?? '').toString(),
    description: (m['description'] ?? '').toString(),
    tags: List<String>.from(m['tags'] ?? const []),
    conditions: Map<String, dynamic>.from(m['conditions'] ?? const {}),
    options: ((m['options'] as List?) ?? const [])
        .map((e) => EventOption.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );
}

class EndingDef {
  final String id;
  final String type; // main / fail
  final String title;
  final String description;

  EndingDef({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
  });

  factory EndingDef.fromMap(Map<String, dynamic> m) => EndingDef(
    id: (m['id'] ?? '').toString(),
    type: (m['type'] ?? '').toString(),
    title: (m['title'] ?? '').toString(),
    description: (m['description'] ?? '').toString(),
  );
}

class RunState {
  final int day;
  final int month;
  final int rankTier;

  /// ✅ 新增：记录开局路数（favor/power/.../balanced）
  final String openingStyle;
  final String playerName;

  final Stats stats;
  final Map<Faction, int> factionAtt;
  final Set<String> flags;

  final EventDef? currentEvent;
  final Map<String, int> lastStatDelta;
  final Map<Faction, int> lastFactionDelta;

  final String? endingId;

  const RunState({
    required this.day,
    required this.month,
    required this.rankTier,
    required this.openingStyle, // ✅ 新增
    required this.playerName,
    required this.stats,
    required this.factionAtt,
    required this.flags,
    required this.currentEvent,
    required this.lastStatDelta,
    required this.lastFactionDelta,
    required this.endingId,
  });

  RunState copyWith({
    int? day,
    int? month,
    int? rankTier,
    String? openingStyle, // ✅ 新增
    String? playerName,
    Stats? stats,
    Map<Faction, int>? factionAtt,
    Set<String>? flags,
    EventDef? currentEvent,
    Map<String, int>? lastStatDelta,
    Map<Faction, int>? lastFactionDelta,
    String? endingId,
  }) {
    return RunState(
      day: day ?? this.day,
      month: month ?? this.month,
      rankTier: rankTier ?? this.rankTier,
      openingStyle: openingStyle ?? this.openingStyle,
      playerName: playerName ?? this.playerName,
      stats: stats ?? this.stats,
      factionAtt: factionAtt ?? this.factionAtt,
      flags: flags ?? this.flags,
      currentEvent: currentEvent ?? this.currentEvent,
      lastStatDelta: lastStatDelta ?? this.lastStatDelta,
      lastFactionDelta: lastFactionDelta ?? this.lastFactionDelta,
      endingId: endingId ?? this.endingId,
    );
  }
}
