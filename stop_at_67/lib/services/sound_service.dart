import 'package:flutter_tts/flutter_tts.dart';

class SoundService {
  final FlutterTts _tts = FlutterTts();
  bool _enabled = true;

  Future<void> init() async {
    await _tts.setLanguage('en-US');
    await _tts.awaitSpeakCompletion(false);
  }

  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  bool get isEnabled => _enabled;

  Future<void> play(String name) async {
    if (!_enabled) return;
    final config = _speechMap[name];
    if (config == null) return;
    try {
      await _tts.stop();
      await _tts.setPitch(config.$1);
      await _tts.setSpeechRate(config.$2);
      await _tts.speak(config.$3);
    } catch (_) {}
  }

  Future<void> speakSixSeven() async {
    if (!_enabled) return;
    try {
      await _tts.stop();
      await _tts.setPitch(1.1);
      await _tts.setSpeechRate(0.9);
      await _tts.speak('Six Seven!');
    } catch (_) {}
  }

  Future<void> cleanup() async {
    await _tts.stop();
  }

  // (pitch, rate, text)
  static const _speechMap = <String, (double, double, String)>{
    'perfect':     (1.2, 0.95, 'Six Seven! Perfect!'),
    'excellent':   (1.1, 0.9,  'Six Seven!'),
    'good':        (1.0, 1.0,  'Good'),
    'miss':        (0.8, 1.0,  'Miss'),
    'levelUp':     (1.2, 0.9,  'Level Up!'),
    'achievement': (1.1, 0.9,  'Achievement unlocked!'),
  };
}
