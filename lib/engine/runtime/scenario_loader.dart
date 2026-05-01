import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/scenario.dart';

class ScenarioLoader {
  /// 從 Flutter 內建的 AssetManifest 自動掃出所有 assets/scenarios/*.json
  /// 排序：dev_* 開頭的 scenario 排最後（避免出現在主選單第一位）
  Future<List<Scenario>> loadAll() async {
    final manifestRaw = await rootBundle.loadString('AssetManifest.json');
    final manifest = jsonDecode(manifestRaw) as Map<String, dynamic>;

    final paths = manifest.keys
        .where((k) => k.startsWith('assets/scenarios/') && k.endsWith('.json'))
        .toList()
      ..sort((a, b) {
        final aDev = _isDev(a);
        final bDev = _isDev(b);
        if (aDev != bDev) return aDev ? 1 : -1;
        return a.compareTo(b);
      });

    final scenarios = <Scenario>[];
    for (final path in paths) {
      scenarios.add(await loadFromAsset(path));
    }
    return scenarios;
  }

  static bool _isDev(String path) {
    final filename = path.split('/').last;
    return filename.startsWith('dev_');
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
