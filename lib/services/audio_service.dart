import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

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

/// 音訊服務 — 用 flutter_soloud (Flutter 官方推薦遊戲音訊套件)
///
/// 架構優勢 (相對 audioplayers):
/// - **載一次、play 多 voice**: source 預載到記憶體後，每次 play 是觸發新 voice，
///   多 voice 並行根本沒 race condition (不像 audioplayers 是 per-player 排程)
/// - **Gapless looping**: BGM 循環無 gap
/// - **Atomic 切歌**: stop(oldHandle) + play(newSource) 原子操作，不會卡舊 BGM
/// - **Low latency**: 對連點 SFX 完全勝任
class AudioService {
  /// 主選單 BGM — 異聞錄系列共用，跨章節跨劇本維持品牌識別
  static const String homeBgmPath = 'assets/audio/bgm/horror-dark.mp3';

  // late final 避免 fake AudioService (test 環境) 觸發 SoLoud FFI library load
  late final SoLoud _soloud = SoLoud.instance;
  bool _initialized = false;
  bool _initFailed = false;

  /// asset path → loaded AudioSource cache (避免重複 load 同檔)
  final Map<String, AudioSource> _sourceCache = {};

  SoundHandle? _bgmHandle;
  SoundHandle? _ambientHandle;
  String? _currentBgmPath;
  String? _currentAmbientPath;
  Timer? _ambientTimer;
  Duration _ambientInterval = const Duration(seconds: 3);

  AudioService();

  Future<void> _ensureInit() async {
    if (_initialized || _initFailed) return;
    try {
      await _soloud.init();
      _initialized = true;
    } catch (e) {
      _initFailed = true;
      if (kDebugMode) debugPrint('SoLoud init failed: $e');
    }
  }

  Future<AudioSource?> _getSource(String assetPath) async {
    final cached = _sourceCache[assetPath];
    if (cached != null) return cached;
    try {
      final source = await _soloud.loadAsset(assetPath);
      _sourceCache[assetPath] = source;
      return source;
    } catch (e) {
      if (kDebugMode) debugPrint('SoLoud loadAsset $assetPath failed: $e');
      return null;
    }
  }

  // ── BGM ──────────────────────────────────────────────────────────

  Future<void> playBgm(String? assetPath) async {
    if (assetPath == _currentBgmPath && _bgmHandle != null) return;

    await _ensureInit();
    if (!_initialized) return;

    // 先 stop 舊 BGM (atomic 切歌)
    final old = _bgmHandle;
    _bgmHandle = null;
    _currentBgmPath = assetPath;
    if (old != null) {
      try { await _soloud.stop(old); } catch (_) {}
    }

    if (assetPath == null) return;

    try {
      final source = await _getSource(assetPath);
      if (source == null) return;
      _bgmHandle = await _soloud.play(source, looping: true);
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService.playBgm failed: $e');
    }
  }

  /// Splash 用 — SoLoud loadAsset 已是「預載到 memory」、play 立刻發聲
  Future<void> preloadBgm(String assetPath) => playBgm(assetPath);

  /// 純預載 source 到記憶體 (不 play)。Splash bootstrap 期間呼叫，
  /// user 點繼續時 playBgm 直接 play cached source — 對舊手機 (大伯 iPhone)
  /// 解 cold start 「過 2 個畫面才有聲」的問題。
  Future<void> preloadSource(String assetPath) async {
    await _ensureInit();
    if (!_initialized) return;
    await _getSource(assetPath);
  }

  Future<void> stopBgm() => playBgm(null);

  Future<void> pauseBgm() async {
    if (!_initialized) return;
    try {
      if (_bgmHandle != null) _soloud.setPause(_bgmHandle!, true);
      if (_ambientHandle != null) _soloud.setPause(_ambientHandle!, true);
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService.pauseBgm failed: $e');
    }
  }

  Future<void> resumeBgm() async {
    if (!_initialized) return;
    try {
      if (_bgmHandle != null) _soloud.setPause(_bgmHandle!, false);
      if (_ambientHandle != null) _soloud.setPause(_ambientHandle!, false);
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService.resumeBgm failed: $e');
    }
  }

  // ── SFX ──────────────────────────────────────────────────────────

  /// 一次性 SFX — SoLoud 每次 play 創新 voice，連點完全並行不阻塞
  void playSfx(SfxKey key) {
    _playSfxAsync(key);
  }

  Future<void> _playSfxAsync(SfxKey key) async {
    await _ensureInit();
    if (!_initialized) return;
    try {
      final source = await _getSource(key.assetPath);
      if (source == null) return;
      await _soloud.play(source);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AudioService.playSfx(${key.name}) failed: $e');
      }
    }
  }

  // ── Ambient (帶間隔循環) ─────────────────────────────────────────

  Future<void> playAmbient(
    String? assetPath, {
    Duration interval = const Duration(seconds: 3),
  }) async {
    if (assetPath == _currentAmbientPath) return;

    await _ensureInit();
    if (!_initialized) return;

    await _stopAmbientInternal();
    _currentAmbientPath = assetPath;
    _ambientInterval = interval;

    if (assetPath == null) return;

    await _playAmbientOnce();
  }

  Future<void> _playAmbientOnce() async {
    final path = _currentAmbientPath;
    if (path == null) return;
    try {
      final source = await _getSource(path);
      if (source == null) return;
      _ambientHandle = await _soloud.play(source);
      // 用音長 + interval 排程下一次播 (SoLoud 沒原生 onComplete callback)
      final length = _soloud.getLength(source);
      _ambientTimer?.cancel();
      _ambientTimer = Timer(length + _ambientInterval, () {
        if (_currentAmbientPath != path) return; // 已被切換
        _playAmbientOnce();
      });
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService ambient play failed: $e');
    }
  }

  Future<void> stopAmbient() => playAmbient(null);

  Future<void> _stopAmbientInternal() async {
    _ambientTimer?.cancel();
    _ambientTimer = null;
    final old = _ambientHandle;
    _ambientHandle = null;
    if (old != null) {
      try { await _soloud.stop(old); } catch (_) {}
    }
  }

  // ── 全停 ────────────────────────────────────────────────────────

  Future<void> stopAll() async {
    await Future.wait([stopBgm(), stopAmbient()]);
  }

  void dispose() {
    _ambientTimer?.cancel();
    try { _soloud.deinit(); } catch (_) {}
    _sourceCache.clear();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});
