/// 場景層級的條件式跳轉規則。
///
/// 用法：在 scene 內定義 conditional_next 陣列，玩家進入該場景時依序檢查每條規則，
/// 第一條符合的決定 next。常用於「結局調度」(看資源條件決定走哪個結局)。
///
/// JSON 範例：
/// ```json
/// "conditional_next": [
///   {"if_resource_below": {"san": 50}, "next": "scene_end_broken"},
///   {"default": true, "next": "scene_end_neutral"}
/// ]
/// ```
class ConditionalNext {
  /// 跳轉目標場景 id
  final String next;

  /// 「資源 < 閾值」條件 (多個條件 AND)
  final Map<String, int>? ifResourceBelow;

  /// 「資源 >= 閾值」條件 (多個條件 AND)
  final Map<String, int>? ifResourceAtLeast;

  /// 兜底規則 (放在最後一條)
  final bool isDefault;

  const ConditionalNext({
    required this.next,
    this.ifResourceBelow,
    this.ifResourceAtLeast,
    this.isDefault = false,
  });

  factory ConditionalNext.fromJson(Map<String, dynamic> json) {
    return ConditionalNext(
      next: json['next'] as String,
      ifResourceBelow: (json['if_resource_below'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as int)),
      ifResourceAtLeast: (json['if_resource_at_least'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as int)),
      isDefault: json['default'] == true,
    );
  }

  bool matches(Map<String, int> resources) {
    if (isDefault) return true;
    if (ifResourceBelow != null) {
      for (final entry in ifResourceBelow!.entries) {
        final cur = resources[entry.key] ?? 0;
        if (cur >= entry.value) return false;
      }
      return true;
    }
    if (ifResourceAtLeast != null) {
      for (final entry in ifResourceAtLeast!.entries) {
        final cur = resources[entry.key] ?? 0;
        if (cur < entry.value) return false;
      }
      return true;
    }
    return false;
  }
}
