class ResourceDef {
  final String id;
  final String name;
  final int? max;
  final int initial;
  final String icon;

  /// 隱藏旗標 — UI 不顯示這個資源 (e.g. SMS 機制的 sms_sent flag)。
  /// 引擎內部仍正常追蹤、conditional_next / effects 仍可用。
  final bool hidden;

  const ResourceDef({
    required this.id,
    required this.name,
    this.max,
    required this.initial,
    required this.icon,
    this.hidden = false,
  });

  factory ResourceDef.fromJson(Map<String, dynamic> json) => ResourceDef(
        id: json['id'] as String,
        name: json['name'] as String,
        max: json['max'] as int?,
        initial: json['initial'] as int? ?? 0,
        icon: json['icon'] as String? ?? '◆',
        hidden: json['hidden'] as bool? ?? false,
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
