import 'choice.dart';

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

  /// 場景插圖的 asset 路徑，如 "assets/images/scenarios/demo_office/scene_start.webp"
  /// 為 null 時 UI 不顯示圖片區、敘事文字直接全寬呈現
  final String? image;

  const Scene({
    required this.id,
    required this.narrative,
    this.choices = const [],
    this.ending,
    this.chapterId,
    this.image,
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
      );

  bool get isEnding => ending != null;
}
