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
  AudioPlayer? _ambientPlayerInternal;

  /// SFX Pool — 4 個 player round-robin 輪流播放
  /// 解決「連點 SFX 互相 race / 阻塞 / truncate」的核心問題
  /// 每個 player 各自處理自己的 play 命令，多軌真並行
  static const int _sfxPoolSize = 4;
  final List<AudioPlayer> _sfxPool = [];
  int _sfxRoundRobinIdx = 0;

  AudioPlayer get _bgmPlayer => _bgmPlayerInternal ??= _createBgmPlayer();
  AudioPlayer get _ambientPlayer =>
      _ambientPlayerInternal ??= _createAmbientPlayer();

  /// BGM 用的 audio context — gain focus 獨佔，因為 BGM 是長音流
  /// audioplayers 高階 API，內部自動 map 到對的 Android/iOS 設定
  static final AudioContext _bgmContext = AudioContextConfig(
    focus: AudioContextConfigFocus.gain,
    route: AudioContextConfigRoute.system,
  ).build();

  /// SFX 用的 audio context — mixWithOthers，跟 BGM 真並行混音不打架
  /// 這是 audioplayers 官方推薦給「遊戲音效」場景的設定
  static final AudioContext _sfxContext = AudioContextConfig(
    focus: AudioContextConfigFocus.mixWithOthers,
    route: AudioContextConfigRoute.system,
  ).build();

  AudioPlayer _createBgmPlayer() {
    final p = AudioPlayer(playerId: 'bgm');
    p.setAudioContext(_bgmContext);
    p.setReleaseMode(ReleaseMode.loop);
    p.setPlayerMode(PlayerMode.mediaPlayer);
    return p;
  }

  AudioPlayer _createSfxPlayer(int index) {
    final p = AudioPlayer(playerId: 'sfx_$index');
    p.setAudioContext(_sfxContext);
    p.setReleaseMode(ReleaseMode.release);
    p.setPlayerMode(PlayerMode.lowLatency);
    return p;
  }

  void _ensureSfxPool() {
    while (_sfxPool.length < _sfxPoolSize) {
      _sfxPool.add(_createSfxPlayer(_sfxPool.length));
    }
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

  /// 一次性 SFX。從 pool 拿下一個 player 播放，連點不阻塞、不互相 truncate。
  /// 用 fire-and-forget — 不 await，避免 caller 連續呼叫時被排隊等待。
  void playSfx(SfxKey key) {
    try {
      _ensureSfxPool();
      final player = _sfxPool[_sfxRoundRobinIdx];
      _sfxRoundRobinIdx = (_sfxRoundRobinIdx + 1) % _sfxPoolSize;
      // 不 await — 多 player 各自處理 play 命令，並行
      player.play(AssetSource(key.assetSourcePath)).catchError((Object e) {
        if (kDebugMode) debugPrint('AudioService.playSfx(${key.name}) failed: $e');
      });
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
    try { _ambientPlayerInternal?.dispose(); } catch (_) {}
    for (final p in _sfxPool) {
      try { p.dispose(); } catch (_) {}
    }
    _sfxPool.clear();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});
