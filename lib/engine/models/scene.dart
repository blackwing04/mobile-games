import 'choice.dart';
import 'conditional_next.dart';

class Ending {
  final String type; // good / neutral / bad
  final String title;
  final String description;
  final String? image;

  const Ending({
    required this.type,
    required this.title,
    required this.description,
    this.image,
  });

  factory Ending.fromJson(Map<String, dynamic> json) => Ending(
        type: json['type'] as String? ?? 'neutral',
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        image: json['image'] as String?,
      );
}

class Scene {
  final String id;
  final String narrative;
  final List<Choice> choices;
  final Ending? ending;
  final String? chapterId;

  /// 場景插圖的 asset 路徑，如 "assets/images/scenarios/demo_office/scene_start.png"
  /// 為 null 時 UI 不顯示圖片區、敘事文字直接全寬呈現
  final String? image;

  /// 背景音樂的 asset 路徑，如 "assets/audio/bgm/the_mountain-lonely.mp3"
  /// 為 null 時停止 BGM；與前一場景相同時不重啟（連續播放）
  final String? bgm;

  /// 帶間隔循環的環境聲，如 "assets/audio/sfx/woman-crying.wav"
  /// 與 BGM 並行播放（兩個獨立 player）；間隔由 ambientIntervalMs 控制
  final String? ambient;

  /// ambient 兩次播放之間的間隔毫秒數，預設 3000ms
  final int ambientIntervalMs;

  /// 進場時播放一次的 SFX key（對應 SfxKey.jsonKey），如 "elevator_open"
  /// 不像 BGM/ambient 那樣持續播放
  final String? sfxOnEnter;

  /// 條件式跳轉規則 — 進入此場景時依序檢查，第一條符合的決定下一個 sceneId。
  /// 常用於「結局調度」場景 (router scene)：本身不顯示 UI，立刻按資源條件分流。
  final List<ConditionalNext> conditionalNext;

  const Scene({
    required this.id,
    required this.narrative,
    this.choices = const [],
    this.ending,
    this.chapterId,
    this.image,
    this.bgm,
    this.ambient,
    this.ambientIntervalMs = 3000,
    this.sfxOnEnter,
    this.conditionalNext = const [],
  });

  factory Scene.fromJson(String id, Map<String, dynamic> json) => Scene(
        id: id,
        narrative: json['narrative'] as String? ?? '',
        choices: ((json['choices'] as List<dynamic>?) ?? const [])
            .map((c) => Choice.fromJson(c as Map<String, dynamic>))
            .toList(growable: false),
        ending: json['ending'] == null
            ? null
            : Ending.fromJson(json['ending'] as Map<String, dynamic>),
        chapterId: json['chapter'] as String?,
        image: json['image'] as String?,
        bgm: json['bgm'] as String?,
        ambient: json['ambient'] as String?,
        ambientIntervalMs: json['ambient_interval_ms'] as int? ?? 3000,
        sfxOnEnter: json['sfx_on_enter'] as String?,
        conditionalNext: ((json['conditional_next'] as List<dynamic>?) ?? const [])
            .map((c) => ConditionalNext.fromJson(c as Map<String, dynamic>))
            .toList(growable: false),
      );

  bool get isEnding => ending != null;

  /// router scene = 沒 narrative、沒 choices、有 conditional_next
  bool get isRouter => conditionalNext.isNotEmpty && choices.isEmpty;
}
