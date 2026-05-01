import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/models/choice.dart';
import '../../engine/models/scenario.dart';
import '../../services/audio_service.dart';

class ChoiceButton extends ConsumerWidget {
  final Choice choice;
  final Scenario scenario;
  final VoidCallback onPressed;

  const ChoiceButton({
    super.key,
    required this.choice,
    required this.scenario,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCheck = choice.isCheck;
    final skill = isCheck ? scenario.skillById(choice.skillCheck!.skill) : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            ref.read(audioServiceProvider).playSfx(SfxKey.uiClick);
            onPressed();
          },
          child: Row(
            children: [
              if (isCheck) ...[
                const Icon(Icons.casino, size: 18, color: Color(0xFFE0C770)),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  choice.label,
                  textAlign: TextAlign.left,
                ),
              ),
              if (skill != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '${skill.name} ${skill.value}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE0C770),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
