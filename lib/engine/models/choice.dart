import 'resource.dart';
import 'skill_check.dart';

class Choice {
  final String label;
  final String? next;
  final SkillCheck? skillCheck;
  final List<ResourceEffect> effects;

  /// 顯示條件 — 玩家所有指定 resource 都達到門檻才會看到此 choice。
  /// 用於「線索夠 / 神智夠才解鎖的隱藏選項」。
  final Map<String, int>? requireResourceAtLeast;

  /// 隱藏條件 — 玩家任一指定 resource 達到門檻就隱藏此 choice。
  /// 跟 requireResourceAtLeast 對稱使用：clue<3 顯示擲骰版、clue≥3 顯示直通版。
  final Map<String, int>? hideIfResourceAtLeast;

  const Choice({
    required this.label,
    this.next,
    this.skillCheck,
    this.effects = const [],
    this.requireResourceAtLeast,
    this.hideIfResourceAtLeast,
  });

  factory Choice.fromJson(Map<String, dynamic> json) => Choice(
        label: json['label'] as String,
        next: json['next'] as String?,
        skillCheck: json['skill_check'] == null
            ? null
            : SkillCheck.fromJson(
                json['skill_check'] as Map<String, dynamic>,
              ),
        effects: ((json['effects'] as List<dynamic>?) ?? const [])
            .map((e) => ResourceEffect.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        requireResourceAtLeast:
            (json['require_resource_at_least'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v as int)),
        hideIfResourceAtLeast:
            (json['hide_if_resource_at_least'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v as int)),
      );

  bool get isCheck => skillCheck != null;

  /// 依當前 resources 判斷此 choice 是否該對玩家顯示
  bool isVisibleFor(Map<String, int> resources) {
    final require = requireResourceAtLeast;
    if (require != null) {
      for (final entry in require.entries) {
        if ((resources[entry.key] ?? 0) < entry.value) return false;
      }
    }
    final hide = hideIfResourceAtLeast;
    if (hide != null) {
      for (final entry in hide.entries) {
        if ((resources[entry.key] ?? 0) >= entry.value) return false;
      }
    }
    return true;
  }
}
