import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_games/engine/dice/dice_roller.dart';

void main() {
  group('DiceRoller.classify', () {
    test('擲到 1 在有技能值的情況下是大成功', () {
      expect(DiceRoller.classify(1, 50), DiceOutcome.criticalSuccess);
      expect(DiceRoller.classify(1, 10), DiceOutcome.criticalSuccess);
      expect(DiceRoller.classify(1, 5), DiceOutcome.criticalSuccess);
    });

    test('擲到 100 永遠是大失敗', () {
      expect(DiceRoller.classify(100, 99), DiceOutcome.fumble);
      expect(DiceRoller.classify(100, 50), DiceOutcome.fumble);
    });

    test('96-100 都是大失敗（即使技能 95）', () {
      for (var roll = 96; roll <= 100; roll++) {
        expect(DiceRoller.classify(roll, 95), DiceOutcome.fumble);
      }
    });

    test('技能 60：擲 12 = 大成功（≤ 12）；擲 13 = 普通成功', () {
      expect(DiceRoller.classify(12, 60), DiceOutcome.criticalSuccess);
      expect(DiceRoller.classify(13, 60), DiceOutcome.success);
    });

    test('技能 60：擲 60 = 成功；擲 61 = 代價成功（差距 1）', () {
      expect(DiceRoller.classify(60, 60), DiceOutcome.success);
      expect(DiceRoller.classify(61, 60), DiceOutcome.partial);
    });

    test('技能 60：擲 70 = 代價成功（剛好差距 10）；擲 71 = 失敗', () {
      expect(DiceRoller.classify(70, 60), DiceOutcome.partial);
      expect(DiceRoller.classify(71, 60), DiceOutcome.failure);
    });

    test('技能 0：critical / success / partial 都不適用，僅 failure 與 fumble', () {
      // 設計意圖：玩家連 1% 機會都沒有時，「差一點過關」(partial) 不該觸發
      expect(DiceRoller.classify(1, 0), DiceOutcome.failure);
      expect(DiceRoller.classify(50, 0), DiceOutcome.failure);
      expect(DiceRoller.classify(95, 0), DiceOutcome.failure);
      expect(DiceRoller.classify(100, 0), DiceOutcome.fumble);
    });
  });

  group('DiceRoller.roll', () {
    test('roll 出來的值永遠在 1-100 之間', () {
      final roller = DiceRoller(Random(42));
      for (var i = 0; i < 1000; i++) {
        final result = roller.roll(50);
        expect(result.roll, inInclusiveRange(1, 100));
        expect(result.skillValue, 50);
      }
    });

    test('技能 50 的成功率（含代價成功）大致符合預期', () {
      final roller = DiceRoller(Random(123));
      var successOrBetter = 0;
      const trials = 5000;
      for (var i = 0; i < trials; i++) {
        final r = roller.roll(50);
        if (r.outcome == DiceOutcome.criticalSuccess ||
            r.outcome == DiceOutcome.success) {
          successOrBetter++;
        }
      }
      // 技能 50 → 期望成功率約 50%（不含代價成功），允許 ±5%
      final rate = successOrBetter / trials;
      expect(rate, closeTo(0.50, 0.05));
    });
  });

  group('DiceOutcome serialization', () {
    test('jsonKey 與 fromKey 互為反函式', () {
      for (final o in DiceOutcome.values) {
        expect(DiceOutcome.fromKey(o.jsonKey), o);
      }
    });

    test('未知 key 拋例外', () {
      expect(() => DiceOutcome.fromKey('nope'), throwsArgumentError);
    });

    test('每個 outcome 都有中文顯示名稱', () {
      for (final o in DiceOutcome.values) {
        expect(o.displayName, isNotEmpty);
      }
    });
  });
}
