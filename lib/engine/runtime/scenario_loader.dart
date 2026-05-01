import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/scenario.dart';

class ScenarioLoader {
  /// MVP 階段：劇本檔列表寫死在 manifest 裡。
  /// 之後可改為從 AssetManifest 自動掃 assets/scenarios/*.json
  static const List<String> _scenarioFiles = [
    'assets/scenarios/demo_office.json',
  ];

  Future<List<Scenario>> loadAll() async {
    final scenarios = <Scenario>[];
    for (final path in _scenarioFiles) {
      scenarios.add(await loadFromAsset(path));
    }
    return scenarios;
  }

  Future<Scenario> loadFromAsset(String path) async {
    final raw = await rootBundle.loadString(path);
    return parse(raw);
  }

  /// 純函式：給測試用
  static Scenario parse(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return Scenario.fromJson(json);
  }
}
