import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/game_models.dart';

class GameRepository {
  Future<List<RankDef>> loadRanks() async {
    final s = await rootBundle.loadString('assets/data/ranks.json');
    final j = jsonDecode(s) as List;
    return j.map((e) => RankDef.fromMap(e)).toList();
  }

  Future<List<EventDef>> loadEvents() async {
    final s = await rootBundle.loadString('assets/data/events.json');
    final j = jsonDecode(s) as List;
    return j.map((e) => EventDef.fromMap(e)).toList();
  }

  Future<List<EndingDef>> loadEndings() async {
    final s = await rootBundle.loadString('assets/data/endings.json');
    final j = jsonDecode(s) as List;
    return j.map((e) => EndingDef.fromMap(e)).toList();
  }
}