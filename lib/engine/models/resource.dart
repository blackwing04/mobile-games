class ResourceDef {
  final String id;
  final String name;
  final int? max;
  final int initial;
  final String icon;

  const ResourceDef({
    required this.id,
    required this.name,
    this.max,
    required this.initial,
    required this.icon,
  });

  factory ResourceDef.fromJson(Map<String, dynamic> json) => ResourceDef(
        id: json['id'] as String,
        name: json['name'] as String,
        max: json['max'] as int?,
        initial: json['initial'] as int? ?? 0,
        icon: json['icon'] as String? ?? '◆',
      );
}

class ResourceEffect {
  final String resource;
  final int delta;

  const ResourceEffect({required this.resource, required this.delta});

  factory ResourceEffect.fromJson(Map<String, dynamic> json) => ResourceEffect(
        resource: json['resource'] as String,
        delta: json['delta'] as int,
      );
}
