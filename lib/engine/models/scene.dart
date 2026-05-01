import 'choice.dart';

class Ending {
  final String type; // good / neutral / bad
  final String title;
  final String description;

  const Ending({
    required this.type,
    required this.title,
    required this.description,
  });

  factory Ending.fromJson(Map<String, dynamic> json) => Ending(
        type: json['type'] as String? ?? 'neutral',
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
      );
}

class Scene {
  final String id;
  final String narrative;
  final List<Choice> choices;
  final Ending? ending;
  final String? chapterId;

  const Scene({
    required this.id,
    required this.narrative,
    this.choices = const [],
    this.ending,
    this.chapterId,
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
      );

  bool get isEnding => ending != null;
}
