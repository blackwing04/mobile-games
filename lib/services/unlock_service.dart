import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 結局解鎖管理 — 玩家走過某個結局就 markUnlocked，CollectionScreen 顯示。
/// 全部章節 × 所有結局解鎖 → super ending「23:47 · 起源」入口顯示。
///
/// 資料層用 SharedPreferences 存字串集合，格式 `scenarioId:sceneId`。
/// 章節 / 結局來源完全 data-driven (從 ScenarioLoader 自動掃)，新增 scenario JSON
/// 就會自動納入收集系統，**不用改 framework code**。
class UnlockService {
  static const _kEndingsKey = 'unlocked_endings_v1';
  static const _kSuperEndingSeenKey = 'super_ending_seen_v1';

  /// Super ending scenario id (玩家全結局解鎖後可進的章節)
  /// 對應 assets/scenarios/epilogue_origin.json — 等內容完成再放
  static const String superEndingScenarioId = 'epilogue_origin';

  final Set<String> _cache = {};
  bool _superEndingSeen = false;
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _cache
      ..clear()
      ..addAll(prefs.getStringList(_kEndingsKey) ?? const []);
    _superEndingSeen = prefs.getBool(_kSuperEndingSeenKey) ?? false;
    await _migrateLegacyKeys(prefs);
    _loaded = true;
  }

  /// 把舊版 `demo_office:*` key 遷移到 `ch01_office:*`，玩家不丟失解鎖進度。
  /// 只在第一次 load 時執行；遷移後 prefs 內就只剩新 key。
  Future<void> _migrateLegacyKeys(SharedPreferences prefs) async {
    const legacyPrefix = 'demo_office:';
    const newPrefix = 'ch01_office:';
    final hasLegacy = _cache.any((k) => k.startsWith(legacyPrefix));
    if (!hasLegacy) return;
    final migrated = _cache.map((k) {
      return k.startsWith(legacyPrefix)
          ? '$newPrefix${k.substring(legacyPrefix.length)}'
          : k;
    }).toSet();
    _cache
      ..clear()
      ..addAll(migrated);
    await prefs.setStringList(_kEndingsKey, _cache.toList());
  }

  static String _key(String scenarioId, String sceneId) =>
      '$scenarioId:$sceneId';

  /// 玩家觸達某結局時呼叫 (EndingScreen initState)
  Future<void> markUnlocked(String scenarioId, String sceneId) async {
    await _ensureLoaded();
    final key = _key(scenarioId, sceneId);
    if (_cache.contains(key)) return;
    _cache.add(key);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kEndingsKey, _cache.toList());
  }

  Future<bool> isUnlocked(String scenarioId, String sceneId) async {
    await _ensureLoaded();
    return _cache.contains(_key(scenarioId, sceneId));
  }

  /// 已解鎖結局清單 (給 CollectionScreen 直接渲染用)
  Future<Set<String>> getUnlockedKeys() async {
    await _ensureLoaded();
    return Set.unmodifiable(_cache);
  }

  Future<int> get unlockedCount async {
    await _ensureLoaded();
    return _cache.length;
  }

  Future<bool> get superEndingSeen async {
    await _ensureLoaded();
    return _superEndingSeen;
  }

  Future<void> markSuperEndingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    _superEndingSeen = true;
    await prefs.setBool(_kSuperEndingSeenKey, true);
  }

  /// 給開發者用 — 清空所有解鎖記錄 (測試用)
  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kEndingsKey);
    await prefs.remove(_kSuperEndingSeenKey);
    _cache.clear();
    _superEndingSeen = false;
  }
}

final unlockServiceProvider = Provider<UnlockService>((ref) {
  return UnlockService();
});
