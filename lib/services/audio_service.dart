import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/dice/dice_roller.dart';

/// 音效鍵 — 對應 assets/audio/sfx/ 下的檔案。
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

  /// audioplayers 的 AssetSource 路徑 (不含 'assets/' prefix)
  String get assetSourcePath => 'audio/sfx/$filename';

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

/// 把 scenario JSON 內常用的「assets/audio/...」路徑轉成 audioplayers 需要的
/// 「audio/...」格式 (audioplayers 不要 assets/ prefix)
String _normalizeAssetPath(String fullPath) {
  if (fullPath.startsWith('assets/')) {
    return fullPath.substring('assets/'.length);
  }
  return fullPath;
}

/// 音訊服務 — 用 audioplayers (遊戲音訊業界標準) 取代 just_audio
///
/// 三個獨立 player，BGM/SFX/Ambient 並行不打架:
/// - BGM: ReleaseMode.loop 連續循環
/// - SFX: 一次性，PlayerMode.lowLatency (Android 用 SoundPool)
/// - Ambient: 帶間隔的循環 (用 onPlayerComplete 觸發 timer)
class AudioService {
  /// 主選單 BGM — 異聞錄系列共用，跨章節跨劇本維持品牌識別
  static const String homeBgmPath = 'assets/audio/bgm/horror-dark.mp3';

  AudioPlayer? _bgmPlayerInternal;
  AudioPlayer? _sfxPlayerInternal;
  AudioPlayer? _ambientPlayerInternal;

  AudioPlayer get _bgmPlayer => _bgmPlayerInternal ??= _createBgmPlayer();
  AudioPlayer get _sfxPlayer => _sfxPlayerInternal ??= _createSfxPlayer();
  AudioPlayer get _ambientPlayer =>
      _ambientPlayerInternal ??= _createAmbientPlayer();

  /// BGM 用的 audio context — 持續持有 audio focus、跟系統其他 audio 混音
  static final AudioContext _bgmContext = AudioContext(
    android: AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: false,
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.media,
      audioFocus: AndroidAudioFocus.gain,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: const {AVAudioSessionOptions.mixWithOthers},
    ),
  );

  /// SFX 用的 audio context — 完全不 request audio focus，
  /// 確保 SFX 播放時 BGM 不被中斷 (核心修法)
  static final AudioContext _sfxContext = AudioContext(
    android: AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: false,
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.assistanceSonification,
      audioFocus: AndroidAudioFocus.none,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.ambient,
      options: const {AVAudioSessionOptions.mixWithOthers},
    ),
  );

  AudioPlayer _createBgmPlayer() {
    final p = AudioPlayer(playerId: 'bgm');
    p.setAudioContext(_bgmContext);
    p.setReleaseMode(ReleaseMode.loop);
    p.setPlayerMode(PlayerMode.mediaPlayer);
    return p;
  }

  AudioPlayer _createSfxPlayer() {
    final p = AudioPlayer(playerId: 'sfx');
    p.setAudioContext(_sfxContext);
    p.setReleaseMode(ReleaseMode.release);
    p.setPlayerMode(PlayerMode.lowLatency);
    return p;
  }

  AudioPlayer _createAmbientPlayer() {
    final p = AudioPlayer(playerId: 'ambient');
    p.setAudioContext(_sfxContext); // ambient 也用 sfx context 不搶 focus
    p.setReleaseMode(ReleaseMode.release);
    p.setPlayerMode(PlayerMode.mediaPlayer);
    return p;
  }

  String? _currentBgmPath;
  String? _currentAmbientPath;
  StreamSubscription<void>? _ambientCompleteSub;
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
      await _bgmPlayer.play(AssetSource(_normalizeAssetPath(assetPath)));
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService.playBgm failed: $e');
    }
  }

  /// Splash 用 — 預載 source (asset 已 load 到 memory) 後立刻 play。
  /// 不等「真發聲」(那個會被 audio engine 排程，等不到也沒意義)，
  /// source ready 就跳 home，audio 接續播放零延遲。
  Future<void> preloadBgm(String assetPath) async {
    if (assetPath == _currentBgmPath) return;
    _currentBgmPath = assetPath;

    try {
      await _bgmPlayer.setSource(AssetSource(_normalizeAssetPath(assetPath)));
      await _bgmPlayer.resume();
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService.preloadBgm failed: $e');
    }
  }

  Future<void> stopBgm() => playBgm(null);

  Future<void> pauseBgm() async {
    try {
      await _bgmPlayerInternal?.pause();
      await _ambientPlayerInternal?.pause();
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService.pauseBgm failed: $e');
    }
  }

  Future<void> resumeBgm() async {
    try {
      if (_currentBgmPath != null) await _bgmPlayerInternal?.resume();
      if (_currentAmbientPath != null) await _ambientPlayerInternal?.resume();
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService.resumeBgm failed: $e');
    }
  }

  // ── SFX ──────────────────────────────────────────────────────────

  /// 一次性 SFX。audioplayers low-latency 模式立刻發聲、跟 BGM 並行不打架。
  Future<void> playSfx(SfxKey key) async {
    try {
      await _sfxPlayer.play(AssetSource(key.assetSourcePath));
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService.playSfx(${key.name}) failed: $e');
    }
  }

  // ── Ambient (帶間隔循環) ─────────────────────────────────────────

  /// 帶間隔的循環環境音。null = 停止。同 path 不重啟。
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
      // 監聽播放完成 → 設 timer 等 interval → 重播
      _ambientCompleteSub = _ambientPlayer.onPlayerComplete.listen((_) {
        _ambientTimer?.cancel();
        _ambientTimer = Timer(_ambientInterval, () async {
          if (_currentAmbientPath != assetPath) return; // 已被切換
          try {
            await _ambientPlayer
                .play(AssetSource(_normalizeAssetPath(assetPath)));
          } catch (e) {
            if (kDebugMode) {
              debugPrint('AudioService ambient replay failed: $e');
            }
          }
        });
      });
      await _ambientPlayer.play(AssetSource(_normalizeAssetPath(assetPath)));
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService.playAmbient failed: $e');
    }
  }

  Future<void> stopAmbient() => playAmbient(null);

  Future<void> _stopAmbientInternal() async {
    _ambientTimer?.cancel();
    _ambientTimer = null;
    await _ambientCompleteSub?.cancel();
    _ambientCompleteSub = null;
    try {
      await _ambientPlayerInternal?.stop();
    } catch (_) {}
  }

  // ── 全停 ────────────────────────────────────────────────────────

  Future<void> stopAll() async {
    await Future.wait([stopBgm(), stopAmbient()]);
  }

  void dispose() {
    _ambientTimer?.cancel();
    _ambientCompleteSub?.cancel();
    try { _bgmPlayerInternal?.dispose(); } catch (_) {}
    try { _sfxPlayerInternal?.dispose(); } catch (_) {}
    try { _ambientPlayerInternal?.dispose(); } catch (_) {}
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});
