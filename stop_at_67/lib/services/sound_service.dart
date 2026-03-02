import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SoundService {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();
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
    try {
      switch (name) {
        case 'perfect':
          await _playSixSeven();
          await _tts.stop();
          await _tts.setPitch(1.2);
          await _tts.setSpeechRate(0.3);
          await _tts.speak('Perrrrfect!');
        case 'excellent':
          await _playSixSeven();
        case 'good':
          await _tts.stop();
          await _tts.setPitch(1.0);
          await _tts.setSpeechRate(1.0);
          await _tts.speak('Good');
        case 'miss':
          await _tts.stop();
          await _tts.setPitch(0.8);
          await _tts.setSpeechRate(1.0);
          await _tts.speak('Miss');
        case 'levelUp':
          await _tts.stop();
          await _tts.setPitch(1.2);
          await _tts.setSpeechRate(0.9);
          await _tts.speak('Level Up!');
        case 'achievement':
          await _tts.stop();
          await _tts.setPitch(1.1);
          await _tts.setSpeechRate(0.9);
          await _tts.speak('Achievement unlocked!');
      }
    } catch (_) {}
  }

  Future<void> speakSixSeven() async {
    if (!_enabled) return;
    try {
      await _playSixSeven();
    } catch (_) {}
  }

  Future<void> cleanup() async {
    await _tts.stop();
    await _player.stop();
  }

  Future<void> _playSixSeven() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/67-kid.mp3'));
  }
}
