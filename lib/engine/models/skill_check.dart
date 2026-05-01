import '../dice/dice_roller.dart';
import 'resource.dart';

class SkillCheck {
  final String skill;
  final Map<DiceOutcome, CheckOutcome> outcomes;

  const SkillCheck({required this.skill, required this.outcomes});

  factory SkillCheck.fromJson(Map<String, dynamic> json) {
    final outcomesJson = json['outcomes'] as Map<String, dynamic>;
    return SkillCheck(
      skill: json['skill'] as String,
      outcomes: {
        for (final entry in outcomesJson.entries)
          DiceOutcome.fromKey(entry.key): CheckOutcome.fromJson(
            entry.value as Map<String, dynamic>,
          ),
      },
    );
  }

  CheckOutcome outcomeFor(DiceOutcome o) {
    return outcomes[o] ??
        outcomes[DiceOutcome.failure] ??
        outcomes.values.first;
  }
}

class CheckOutcome {
  final String? next;
  final String? text;
  final List<ResourceEffect> effects;

  const CheckOutcome({this.next, this.text, this.effects = const []});

  factory CheckOutcome.fromJson(Map<String, dynamic> json) => CheckOutcome(
        next: json['next'] as String?,
        text: json['text'] as String?,
        effects: ((json['effects'] as List<dynamic>?) ?? const [])
            .map((e) => ResourceEffect.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
      );
}
