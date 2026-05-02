import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../engine/dice/dice_roller.dart';

/// 音效鍵 — 對應到 assets/audio/sfx/ 下的檔案。
///
/// 用 enum 而非字串避免拼錯；fromOutcome 把骰子結果映射到對應 SFX。
enum SfxKey {
  uiClick('ui_click', 'ui-button-sound.mp3'),
  diceRoll('dice_roll', 'dice-rolling-on-table.wav'),
  outcomeCritical('outcome_critical', 'success.mp3'),
  outcomeSuccess('outcome_success', 'message-received.mp3'),
  outcomePartial('outcome_partial', 'magicalstaffgroundimpact.wav'),
  outcomeFailure('outcome_failure', 'deep-bass-thump.wav'),
  outcomeFumble('outcome_fumble', 'failure.mp3'),
  elevatorOpen('elevator_open', 'elevator-door-and-ding.mp3');

  final String jsonKey;
  final String filename;
  const SfxKey(this.jsonKey, this.filename);

  String get assetPath => 'assets/audio/sfx/$filename';

  static SfxKey fromOutcome(DiceOutcome outcome) => switch (outcome) {
        DiceOutcome.criticalSuccess => SfxKey.outcomeCritical,
        DiceOutcome.success => SfxKey.outcomeSuccess,
        DiceOutcome.partial => SfxKey.outcomePartial,
        DiceOutcome.failure => SfxKey.outcomeFailure,
        DiceOutcome.fumble => SfxKey.outcomeFumble,
      };

  static SfxKey? tryParse(String key) {
    for (final s in SfxKey.values) {
      if (s.jsonKey == key) return s;
    }
    return null;
  }
}

/// 音訊服務 — 三個獨立 player：BGM / SFX / Ambient
///
/// - BGM：場景背景音樂，連續循環，同 path 不重啟
/// - SFX：一次性短音效（按鍵、骰子、結果提示、電梯叮）
/// - Ambient：帶間隔循環的環境聲（如哭聲，scene_blurry_view 用）
class AudioService {
  /// 主選單 BGM。刻意選用與 scene_start 同一首，從首頁進劇本時零切歌、無縫銜接。
  static const String homeBgmPath = 'assets/audio/bgm/the_mountain-lonely.mp3';

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _ambientPlayer = AudioPlayer();

  String? _currentBgmPath;
  String? _currentAmbientPath;
  StreamSubscription<PlayerState>? _ambientSub;
  Timer? _ambientTimer;
  Duration _ambientInterval = const Duration(seconds: 3);

  AudioService();

  // ── BGM ──────────────────────────────────────────────────────────

  Future<void> playBgm(String? assetPath) async {
    if (assetPath == _currentBgmPath) return;
    _currentBgmPath = assetPath;

    try {
      if (assetPath == null) {
        await _bgmPlayer.stop();
        return;
      }
      await _bgmPlayer.setAsset(assetPath);
      await _bgmPlayer.setLoopMode(LoopMode.one);
      await _bgmPlayer.play();
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService.playBgm failed: $e');
    }
  }

  Future<void> stopBgm() => playBgm(null);

  /// App 切到背景時暫停 BGM (不清空 _currentBgmPath，回前景能 resume)
  Future<void> pauseBgm() async {
    try {
      await _bgmPlayer.pause();
      await _ambientPlayer.pause();
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService.pauseBgm failed: $e');
    }
  }

  Future<void> resumeBgm() async {
    try {
      if (_currentBgmPath != null) await _bgmPlayer.play();
      if (_currentAmbientPath != null) await _ambientPlayer.play();
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService.resumeBgm failed: $e');
    }
  }

  // ── SFX ──────────────────────────────────────────────────────────

  /// 一次性 SFX。重複呼叫會打斷上一次（短音效 OK，不需要 overlap）。
  Future<void> playSfx(SfxKey key) async {
    try {
      await _sfxPlayer.setAsset(key.assetPath);
      await _sfxPlayer.play();
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService.playSfx(${key.name}) failed: $e');
    }
  }

  // ── Ambient (帶間隔循環) ─────────────────────────────────────────

  /// 帶間隔的循環環境音。null = 停止。
  /// 同 path 不重啟（與 BGM 一致的 idempotent 行為）。
  Future<void> playAmbient(
    String? assetPath, {
    Duration interval = const Duration(seconds: 3),
  }) async {
    if (assetPath == _currentAmbientPath) return;

    await _stopAmbientInternal();
    _currentAmbientPath = assetPath;
    _ambientInterval = interval;

    if (assetPath == null) return;

    try {
      _ambientSub = _ambientPlayer.playerStateStream.listen((state) {
        if (state.processingState != ProcessingState.completed) return;
        _ambientTimer?.cancel();
        _ambientTimer = Timer(_ambientInterval, () async {
          if (_currentAmbientPath != assetPath) return; // 已被切換
          await _ambientPlayer.seek(Duration.zero);
          await _ambientPlayer.play();
        });
      });
      await _ambientPlayer.setAsset(assetPath);
      await _ambientPlayer.play();
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService.playAmbient failed: $e');
    }
  }

  Future<void> stopAmbient() => playAmbient(null);

  Future<void> _stopAmbientInternal() async {
    _ambientTimer?.cancel();
    _ambientTimer = null;
    await _ambientSub?.cancel();
    _ambientSub = null;
    await _ambientPlayer.stop();
  }

  // ── 全停 ────────────────────────────────────────────────────────

  Future<void> stopAll() async {
    await Future.wait([stopBgm(), stopAmbient()]);
  }

  void dispose() {
    _ambientTimer?.cancel();
    _ambientSub?.cancel();
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    _ambientPlayer.dispose();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});
