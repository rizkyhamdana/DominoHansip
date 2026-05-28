import 'package:audioplayers/audioplayers.dart';

/// Singleton service for background music and sound effects playback.
class AudioService {
  AudioService._internal();
  static final AudioService instance = AudioService._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isMusicMuted = false;
  bool _isSfxMuted = false;

  bool get isMusicMuted => _isMusicMuted;
  bool get isSfxMuted => _isSfxMuted;

  // ── Background Music ────────────────────────────────────────────────────────

  /// Start playing background music on loop at a comfortable volume.
  /// Safe to call multiple times — won't restart if already playing.
  Future<void> play() async {
    if (_musicPlayer.state == PlayerState.playing) return;
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(0.35);
    if (!_isMusicMuted) {
      await _musicPlayer.play(AssetSource('audio/bg_music.mp3'));
    }
  }

  /// Pause background music (keeps position).
  Future<void> pause() async {
    await _musicPlayer.pause();
  }

  /// Resume from paused position.
  Future<void> resume() async {
    if (_isMusicMuted) return;
    if (_musicPlayer.state == PlayerState.paused) {
      await _musicPlayer.resume();
    } else {
      await play();
    }
  }

  /// Toggle music mute on/off. Returns new muted state.
  Future<bool> toggleMusic() async {
    _isMusicMuted = !_isMusicMuted;
    if (_isMusicMuted) {
      await _musicPlayer.pause();
    } else {
      await resume();
    }
    return _isMusicMuted;
  }

  // ── Sound Effects ───────────────────────────────────────────────────────────

  /// Play a sound effect by asset name (without extension).
  /// Supported: 'tile_place', 'round_end'
  Future<void> playSfx(String name) async {
    if (_isSfxMuted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setVolume(0.8);
      await _sfxPlayer.play(AssetSource('audio/$name.m4a'));
    } catch (_) {
      // Silently ignore SFX errors — game must continue
    }
  }

  /// Toggle SFX mute on/off. Returns new muted state.
  bool toggleSfx() {
    _isSfxMuted = !_isSfxMuted;
    return _isSfxMuted;
  }

  /// Stop both background music and SFX immediately.
  Future<void> stopAll() async {
    await _musicPlayer.stop();
    await _sfxPlayer.stop();
  }

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  /// Release resources. Call when app is terminating.
  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}
