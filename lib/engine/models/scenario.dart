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
