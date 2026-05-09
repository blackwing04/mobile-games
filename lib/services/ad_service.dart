import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'premium_service.dart';

/// 章節 gating 廣告服務。
///
/// 詳細設計：docs/MONETIZATION_PLAN.md
///
/// ### Phase 1 行為（現在）
/// - **每章都 gating**（含 Ch1 — 2026-05 修正版，原本 Ch1 免費已廢除）
/// - Premium 玩家：直接 return true（無 ad）
/// - 在 1 小時 cooldown 內：直接 return true
/// - 否則：顯示假廣告畫面 5 秒（StubAd dialog）→ 寫入 cooldown timestamp → return true
/// - Web (kIsWeb)：永遠 NoopAdService，直接 return true（不顯示 ad、不寫 cooldown）
///
/// ### Phase 2 升級（未來）
/// 把 `_showStubAd` 換成真 AdMob interstitial。其他邏輯不動。
abstract class AdService {
  /// 章節點開時呼叫。回傳是否可以進章節：
  /// - true: 可進（已過 cooldown / Premium / Web / 看完 ad）
  /// - false: 玩家取消（按返回 / 關掉 ad dialog）
  Future<bool> ensureAdWatched(BuildContext context, String scenarioId);

  /// 給 Settings UI 顯示用：剩餘 cooldown 秒數（0 = 已過 / 沒紀錄）
  Future<int> remainingCooldownSeconds(String scenarioId);
}

/// Web / 測試環境用：永遠免廣告
class NoopAdService implements AdService {
  @override
  Future<bool> ensureAdWatched(BuildContext context, String scenarioId) async {
    return true;
  }

  @override
  Future<int> remainingCooldownSeconds(String scenarioId) async => 0;
}

/// Phase 1 Android impl：cooldown 邏輯 + stub ad dialog
class CooldownAdService implements AdService {
  static const _kCooldownPrefix = 'ad_cooldown:';
  static const _cooldownMs = 60 * 60 * 1000; // 1 hour
  static const _stubAdDurationSeconds = 5;

  final PremiumService _premium;

  CooldownAdService(this._premium);

  @override
  Future<bool> ensureAdWatched(
    BuildContext context,
    String scenarioId,
  ) async {
    if (await _premium.isPremium()) return true;

    final remaining = await remainingCooldownSeconds(scenarioId);
    if (remaining > 0) return true; // cooldown 內，免廣告

    // 顯示 stub ad（Phase 2 換 AdMob）
    if (!context.mounted) return false;
    final completed = await _showStubAd(context);
    if (!completed) return false;

    // 寫入 cooldown timestamp
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('$_kCooldownPrefix$scenarioId', now);
    return true;
  }

  @override
  Future<int> remainingCooldownSeconds(String scenarioId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastWatched = prefs.getInt('$_kCooldownPrefix$scenarioId') ?? 0;
    if (lastWatched == 0) return 0;
    final elapsed = DateTime.now().millisecondsSinceEpoch - lastWatched;
    final remainMs = _cooldownMs - elapsed;
    return remainMs <= 0 ? 0 : (remainMs / 1000).ceil();
  }

  /// Phase 1 stub：5 秒倒數 dialog 模擬看廣告。
  /// Phase 2 換成 AdMob InterstitialAd.show()。
  Future<bool> _showStubAd(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const _StubAdDialog(seconds: _stubAdDurationSeconds),
        ) ??
        false;
  }
}

class _StubAdDialog extends StatefulWidget {
  final int seconds;
  const _StubAdDialog({required this.seconds});

  @override
  State<_StubAdDialog> createState() => _StubAdDialogState();
}

class _StubAdDialogState extends State<_StubAdDialog> {
  late int _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _tick();
  }

  Future<void> _tick() async {
    while (_remaining > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _remaining--);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1C1C1C),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '廣告播放中⋯',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFFE0C770),
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '$_remaining',
              style: const TextStyle(
                fontSize: 64,
                color: Color(0xFFE0C770),
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '（Phase 1 stub — 之後接 AdMob）',
              style: TextStyle(fontSize: 11, color: Color(0xFF666666)),
            ),
          ],
        ),
      ),
    );
  }
}

final adServiceProvider = Provider<AdService>((ref) {
  if (kIsWeb) return NoopAdService();
  return CooldownAdService(ref.read(premiumServiceProvider));
});
