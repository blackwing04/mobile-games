import 'character.dart';
import 'resource.dart';
import 'scene.dart';

class Chapter {
  final String id;
  final String title;
  final String startScene;

  const Chapter({
    required this.id,
    required this.title,
    required this.startScene,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        id: json['id'] as String,
        title: json['title'] as String,
        startScene: json['start_scene'] as String,
      );
}

class Scenario {
  final String id;
  final String title;
  final String? subtitle;
  final String? author;
  final int? estimatedMinutes;
  final String? coverImage;

  /// 異聞錄系列的章節順序 — Ch1 = 1, Ch2 = 2 ... epilogue = 99
  /// HomeScreen carousel 用此排序，沒設則排在最後 (預設 999)
  final int episode;

  /// 真結局/隱藏結局的解法提示 — CollectionScreen 玩家點開才顯示
  /// 因為真結局機率低 (~1-2%)，給 hint 是「告訴玩家目標」但仍需執行運氣
  final String? truthEndingHint;

  /// 該 scenario 的真結局 / 隱藏結局 scene id (CollectionScreen 高亮顯示)
  final String? truthEndingId;

  final List<ResourceDef> resources;
  final List<SkillDef> skills;
  final String startScene;
  final Map<String, Scene> scenes;
  final List<Chapter> chapters;

  const Scenario({
    required this.id,
    required this.title,
    this.subtitle,
    this.author,
    this.estimatedMinutes,
    this.coverImage,
    this.episode = 999,
    this.truthEndingHint,
    this.truthEndingId,
    required this.resources,
    required this.skills,
    required this.startScene,
    required this.scenes,
    this.chapters = const [],
  });

  factory Scenario.fromJson(Map<String, dynamic> json) {
    final scenesJson = json['scenes'] as Map<String, dynamic>;
    return Scenario(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      author: json['author'] as String?,
      estimatedMinutes: json['estimated_minutes'] as int?,
      coverImage: json['cover_image'] as String?,
      episode: json['episode'] as int? ?? 999,
      truthEndingHint: json['truth_ending_hint'] as String?,
      truthEndingId: json['truth_ending_id'] as String?,
      resources: ((json['resources'] as List<dynamic>?) ?? const [])
          .map((e) => ResourceDef.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      skills: ((json['skills'] as List<dynamic>?) ?? const [])
          .map((e) => SkillDef.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      startScene: json['start_scene'] as String,
      scenes: {
        for (final entry in scenesJson.entries)
          entry.key: Scene.fromJson(
            entry.key,
            entry.value as Map<String, dynamic>,
          ),
      },
      chapters: ((json['chapters'] as List<dynamic>?) ?? const [])
          .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  /// 引擎用於決定廣告策略：分章 = 長劇本走章節廣告；無分章 = 短劇本走開場廣告
  bool get isMultiChapter => chapters.length > 1;

  /// HomeScreen carousel 用 — 沒設 cover_image 時 fallback 到 scene_start 圖
  String? get displayCoverImage {
    if (coverImage != null && coverImage!.isNotEmpty) return coverImage;
    return scenes[startScene]?.image;
  }

  Scene? sceneById(String id) => scenes[id];

  SkillDef? skillById(String id) {
    for (final s in skills) {
      if (s.id == id) return s;
    }
    return null;
  }
}
