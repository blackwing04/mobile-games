class SkillDef {
  final String id;
  final String name;
  final int value;

  const SkillDef({required this.id, required this.name, required this.value});

  factory SkillDef.fromJson(Map<String, dynamic> json) => SkillDef(
        id: json['id'] as String,
        name: json['name'] as String,
        value: json['value'] as int,
      );
}
