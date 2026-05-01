import 'dart:math';

enum DiceOutcome {
  criticalSuccess,
  success,
  partial,
  failure,
  fumble;

  String get displayName => switch (this) {
        DiceOutcome.criticalSuccess => '大成功',
        DiceOutcome.success => '成功',
        DiceOutcome.partial => '代價成功',
        DiceOutcome.failure => '失敗',
        DiceOutcome.fumble => '大失敗',
      };

  static DiceOutcome fromKey(String key) => switch (key) {
        'critical_success' => DiceOutcome.criticalSuccess,
        'success' => DiceOutcome.success,
        'partial' => DiceOutcome.partial,
        'failure' => DiceOutcome.failure,
        'fumble' => DiceOutcome.fumble,
        _ => throw ArgumentError('未知的 outcome key: $key'),
      };

  String get jsonKey => switch (this) {
        DiceOutcome.criticalSuccess => 'critical_success',
        DiceOutcome.success => 'success',
        DiceOutcome.partial => 'partial',
        DiceOutcome.failure => 'failure',
        DiceOutcome.fumble => 'fumble',
      };
}

class DiceResult {
  final int roll;
  final int skillValue;
  final DiceOutcome outcome;

  const DiceResult({
    required this.roll,
    required this.skillValue,
    required this.outcome,
  });
}

/// d100 + 5 階結果判定
///
/// 規則（CoC 風 + PbtA 代價成功概念混血）：
///   - 擲到 ≤ skill / 5      → 大成功（critical）
///   - 擲到 ≤ skill          → 成功
///   - 擲到 > skill 且差距 ≤ 10 → 代價成功（partial）— 推進但有副作用
///   - 擲到 > skill + 10 且 < 96 → 失敗
///   - 擲到 96-100           → 大失敗（fumble）
class DiceRoller {
  final Random _random;

  DiceRoller([Random? random]) : _random = random ?? Random();

  DiceResult roll(int skillValue) {
    final roll = _random.nextInt(100) + 1; // 1..100
    return DiceResult(
      roll: roll,
      skillValue: skillValue,
      outcome: _classify(roll, skillValue),
    );
  }

  static DiceOutcome _classify(int roll, int skill) {
    if (roll >= 96) return DiceOutcome.fumble;
    if (skill > 0 && roll <= (skill / 5).floor().clamp(1, 100)) {
      return DiceOutcome.criticalSuccess;
    }
    if (roll <= skill) return DiceOutcome.success;
    // partial（代價成功）需要玩家「真的差一點通過」— 技能 0 不適用
    if (skill > 0 && roll - skill <= 10) return DiceOutcome.partial;
    return DiceOutcome.failure;
  }

  /// 給測試用的純函式版本
  static DiceOutcome classify(int roll, int skill) => _classify(roll, skill);
}
