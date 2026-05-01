import 'resource.dart';
import 'skill_check.dart';

class Choice {
  final String label;
  final String? next;
  final SkillCheck? skillCheck;
  final List<ResourceEffect> effects;

  const Choice({
    required this.label,
    this.next,
    this.skillCheck,
    this.effects = const [],
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
      );

  bool get isCheck => skillCheck != null;
}
