import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 玩家是否購買「去除廣告」買斷 IAP。
///
/// Phase 1 (現在)：純 SharedPreferences flag。沒有真 IAP，永遠 false。
/// Phase 3 (未來)：玩家購買後寫入 flag，跨章節立即生效。
///
/// 詳細規劃見 docs/MONETIZATION_PLAN.md。
class PremiumService {
  static const _kPremiumKey = 'premium_pass_active';

  bool? _cache;

  Future<bool> isPremium() async {
    if (_cache != null) return _cache!;
    final prefs = await SharedPreferences.getInstance();
    _cache = prefs.getBool(_kPremiumKey) ?? false;
    return _cache!;
  }

  /// Phase 3 IAP 成功時呼叫
  Future<void> activate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPremiumKey, true);
    _cache = true;
  }

  /// 開發 / 測試用 — 清掉 premium flag（恢復為非付費玩家）
  Future<void> resetForTest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPremiumKey);
    _cache = false;
  }
}

final premiumServiceProvider = Provider<PremiumService>((ref) {
  return PremiumService();
});
