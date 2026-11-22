import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioService {
  AudioPlayer? _player;

  AudioPlayer get player => _player ??= AudioPlayer();

  Future<void> playDing() async {
    try {
      await player.stop();
      await player.play(AssetSource('sounds/ding.mp3'));
    } catch (_) {
      // Degrades gracefully on headless test environments or unsupported devices
    }
  }

  void dispose() {
    _player?.dispose();
    _player = null;
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});
