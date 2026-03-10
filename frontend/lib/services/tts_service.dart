/// Campus AI Assistant — Text-to-Speech Service
///
/// Wraps the flutter_tts package to read AI responses aloud.
/// Provides simple speak/stop controls.

import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  /// Initialize TTS engine with default settings.
  Future<void> init() async {
    if (_isInitialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _isInitialized = true;
  }

  /// Speak the given text aloud.
  Future<void> speak(String text) async {
    await init();
    await _tts.speak(text);
  }

  /// Stop any current speech.
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Dispose the TTS engine.
  void dispose() {
    _tts.stop();
  }
}
