import 'dart:convert';

import 'package:flutter/services.dart' show AssetManifest, rootBundle;

import '../models/scenario.dart';

class ScenarioLoader {
  /// 用 Flutter 標準 AssetManifest API 自動掃出所有 assets/scenarios/*.json
  /// (Flutter 3.13+ 把 manifest 改成 .bin 格式，這個 API 自動處理跨版本差異)
  ///
  /// 排序規則 (從前到後)：
  /// 1. dev_* 開頭的 scenario 永遠排最後（避免污染主選單第一位）
  /// 2. 非 dev 之間以 Scenario.episode 排序 (Ch1=1, Ch2=2, ..., epilogue=99)
  /// 3. episode 相同 → 用檔名排
  Future<List<Scenario>> loadAll() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

    final paths = manifest
        .listAssets()
        .where((k) => k.startsWith('assets/scenarios/') && k.endsWith('.json'))
        .toList();

    final loaded = <_LoadedScenario>[];
    for (final path in paths) {
      loaded.add(_LoadedScenario(path, await loadFromAsset(path)));
    }

    loaded.sort((a, b) {
      final aDev = _isDev(a.path);
      final bDev = _isDev(b.path);
      if (aDev != bDev) return aDev ? 1 : -1;
      final episodeCmp = a.scenario.episode.compareTo(b.scenario.episode);
      if (episodeCmp != 0) return episodeCmp;
      return a.path.compareTo(b.path);
    });

    return loaded.map((e) => e.scenario).toList(growable: false);
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

class _LoadedScenario {
  final String path;
  final Scenario scenario;
  const _LoadedScenario(this.path, this.scenario);
}
