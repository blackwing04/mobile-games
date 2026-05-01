import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// BGM 播放服務。
///
/// - 場景傳來新 path：切換並開始 loop
/// - 場景傳來相同 path：保持播放（連續），不重啟
/// - 場景傳來 null：停止
///
/// 採 fire-and-forget 設計：playBgm 不 await，UI 切場景時不卡頓。
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  String? _currentPath;

  String? get currentPath => _currentPath;

  Future<void> playBgm(String? assetPath) async {
    if (assetPath == _currentPath) return;
    _currentPath = assetPath;

    try {
      if (assetPath == null) {
        await _player.stop();
        return;
      }
      await _player.setAsset(assetPath);
      await _player.setLoopMode(LoopMode.one);
      await _player.play();
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService.playBgm failed: $e');
    }
  }

  Future<void> stop() => playBgm(null);

  void dispose() {
    _player.dispose();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});
