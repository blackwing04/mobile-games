import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/dice/dice_roller.dart';
import '../../engine/models/resource.dart';
import '../../services/audio_service.dart';

/// 擲骰動畫 overlay：數字快速跳動 → 停在結果 → 顯示成功階級 + 資源變動
class DiceOverlay extends ConsumerStatefulWidget {
  final DiceResult result;
  final String triggerLabel;
  final VoidCallback onContinue;

  /// 本次擲骰造成的資源變動 (resource id → delta)。null / 空時不顯示
  final Map<String, int>? resourceDeltas;

  /// 對應的資源定義 (用於顯示 icon + name)
  final List<ResourceDef> resources;

  const DiceOverlay({
    super.key,
    required this.result,
    required this.triggerLabel,
    required this.onContinue,
    this.resourceDeltas,
    this.resources = const [],
  });

  @override
  ConsumerState<DiceOverlay> createState() => _DiceOverlayState();
}

class _DiceOverlayState extends ConsumerState<DiceOverlay>
    with SingleTickerProviderStateMixin {
  late int _displayNumber;
  Timer? _spinTimer;
  bool _settled = false;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _displayNumber = _random.nextInt(100) + 1;
    // 進場即播骰子滾動聲
    ref.read(audioServiceProvider).playSfx(SfxKey.diceRoll);

    _spinTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (t.tick >= 18) {
        t.cancel();
        setState(() {
          _displayNumber = widget.result.roll;
          _settled = true;
        });
        // 結果浮現時播對應 outcome SFX
        ref
            .read(audioServiceProvider)
            .playSfx(SfxKey.fromOutcome(widget.result.outcome));
        return;
      }
      setState(() {
        _displayNumber = _random.nextInt(100) + 1;
      });
    });
  }

  @override
  void dispose() {
    _spinTimer?.cancel();
    super.dispose();
  }

  Color _outcomeColor(DiceOutcome o) {
    return switch (o) {
      DiceOutcome.criticalSuccess => const Color(0xFFFFE082),
      DiceOutcome.success => const Color(0xFF81C784),
      DiceOutcome.partial => const Color(0xFFFFB74D),
      DiceOutcome.failure => const Color(0xFFE57373),
      DiceOutcome.fumble => const Color(0xFF8B0000),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.triggerLabel,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFE0C770),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '需要 ≤ ${widget.result.skillValue}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFA0A0A0),
                ),
              ),
              const SizedBox(height: 24),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: _settled ? 96 : 80,
                  fontWeight: FontWeight.bold,
                  color: _settled
                      ? _outcomeColor(widget.result.outcome)
                      : Colors.white,
                ),
                child: Text(_displayNumber.toString().padLeft(2, '0')),
              ),
              const SizedBox(height: 24),
              if (_settled) ...[
                Text(
                  widget.result.outcome.displayName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _outcomeColor(widget.result.outcome),
                  ),
                ),
                if (widget.resourceDeltas != null &&
                    widget.resourceDeltas!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween(begin: 0, end: 1),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 12 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: _DeltaRow(
                      deltas: widget.resourceDeltas!,
                      resources: widget.resources,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    ref.read(audioServiceProvider).playSfx(SfxKey.uiClick);
                    widget.onContinue();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 4,
                    ),
                    child: Text('繼續'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 顯示擲骰造成的資源變動 chip 列表 (例如「🧠 神智 -15」)
class _DeltaRow extends StatelessWidget {
  final Map<String, int> deltas;
  final List<ResourceDef> resources;

  const _DeltaRow({required this.deltas, required this.resources});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: deltas.entries.map((entry) {
        final def = resources.firstWhere(
          (r) => r.id == entry.key,
          orElse: () => ResourceDef(
            id: entry.key,
            name: entry.key,
            initial: 0,
            icon: '◆',
          ),
        );
        final delta = entry.value;
        final isPositive = delta > 0;
        final color = isPositive
            ? const Color(0xFF81C784)
            : const Color(0xFFE57373);
        final sign = isPositive ? '+' : '';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(def.icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                def.name,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$sign$delta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
