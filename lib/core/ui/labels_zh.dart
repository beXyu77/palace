import '../models/game_models.dart';

/// Internal keys are English; UI labels are Chinese.
const Map<String, String> statZh = {
  'favor': '宠爱',
  'fame': '名声',
  'scheming': '心机',
  'talent': '才艺',
  'family': '家世',
  'health': '健康',
  'beauty': '外貌',
  'learning': '学识',
};

const Map<Faction, String> factionZh = {
  Faction.dowager: '太后党',
  Faction.empress: '皇后党',
  Faction.inlaws: '外戚党',
  Faction.pure: '清流党',
  Faction.military: '军功派',
  Faction.eunuchs: '内廷势力',
};

String statLabelZh(String key) => statZh[key] ?? key;

String factionLabelZh(Faction f) => factionZh[f] ?? f.name;

String deltaSign(int v) => v >= 0 ? '+$v' : '$v';