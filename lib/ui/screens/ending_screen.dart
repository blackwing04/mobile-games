import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/models/scene.dart';
import '../../services/audio_service.dart';
import '../widgets/debug_scene_id_chip.dart';
import '../widgets/scene_image.dart';

class EndingScreen extends ConsumerWidget {
  final Ending ending;
  final String? sceneImage;

  /// 「再玩一次」callback。null 時隱藏該按鈕 (用於 CollectionScreen 回顧模式)
  final VoidCallback? onRestart;
  final VoidCallback onHome;

  /// 回顧模式 — 「回主選單」按鈕 label 改為「返回」
  final bool viewOnly;

  /// 是否為該章節的真結局 (scenario.truthEndingId == 當前 sceneId)
  /// true 時上方 label 顯示「— 真結局 —」取代「— 好結局 —」之類
  final bool isTruth;

  /// Debug 模式下顯示在右上角的 scene id（給開發回報用）
  /// null 時不顯示；release build 統一傳 null
  final String? debugSceneId;

  const EndingScreen({
    super.key,
    required this.ending,
    this.sceneImage,
    this.onRestart,
    required this.onHome,
    this.viewOnly = false,
    this.isTruth = false,
    this.debugSceneId,
  });

  /// 結局插圖：優先使用 ending.image，沒有就 fallback 到 scene.image
  String? get _image => ending.image ?? sceneImage;

  Color get _accent => switch (ending.type) {
        'good' => const Color(0xFF81C784),
        'bad' => const Color(0xFF8B0000),
        _ => const Color(0xFFE0C770),
      };

  String get _label {
    if (isTruth) return '— 真結局 —';
    return switch (ending.type) {
      'good' => '— 好結局 —',
      'bad' => '— 壞結局 —',
      _ => '— 結局 —',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(child: _buildContent(ref)),
          if (debugSceneId != null)
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: DebugSceneIdChip(
                    sceneId: debugSceneId!,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_image != null) ...[
                SceneImage(assetPath: _image),
                const SizedBox(height: 24),
              ],
              Text(
                _label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: _accent,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                ending.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _accent,
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  ending.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.7,
                    color: Color(0xFFCFCFCF),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              if (onRestart != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(audioServiceProvider).playSfx(SfxKey.uiClick);
                      onRestart!();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('再玩一次'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextButton(
                onPressed: () {
                  ref.read(audioServiceProvider).playSfx(SfxKey.uiClick);
                  onHome();
                },
                child: Text(viewOnly ? '返回' : '回主選單'),
              ),
            ],
          ),
        );
  }
}
