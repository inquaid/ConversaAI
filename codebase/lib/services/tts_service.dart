import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech service that works on both web and native platforms
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _flutterTts = FlutterTts();

      if (kIsWeb) {
        // Web-specific TTS settings
        await _flutterTts!.setSharedInstance(true);
      }

      // Configure TTS settings
      await _flutterTts!.setLanguage("en-US");
      await _flutterTts!.setSpeechRate(0.6); // Slightly slower for clarity
      await _flutterTts!.setVolume(0.8);
      await _flutterTts!.setPitch(1.0);

      // Set up completion handler
      _flutterTts!.setCompletionHandler(() {
        print('TtsService: Speech completed');
        _isSpeaking = false;
      });

      _flutterTts!.setStartHandler(() {
        print('TtsService: Speech started');
        _isSpeaking = true;
      });

      _flutterTts!.setErrorHandler((msg) {
        print('TtsService: Speech error - $msg');
        _isSpeaking = false;
      });

      _isInitialized = true;
      print('TtsService: Initialized successfully');
    } catch (e) {
      print('TtsService: Initialization failed - $e');
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_flutterTts == null) {
      print('TtsService: TTS not available');
      return;
    }

    try {
      // Stop any current speech
      await stop();

      print('TtsService: Speaking - "$text"');
      _isSpeaking = true;
      await _flutterTts!.speak(text);
    } catch (e) {
      print('TtsService: Speech failed - $e');
      _isSpeaking = false;
    }
  }

  Future<void> stop() async {
    if (_flutterTts != null && _isSpeaking) {
      print('TtsService: Stopping speech');
      await _flutterTts!.stop();
      _isSpeaking = false;
    }
  }

  Future<void> pause() async {
    if (_flutterTts != null && _isSpeaking) {
      await _flutterTts!.pause();
    }
  }

  void dispose() {
    _flutterTts?.stop();
    _isSpeaking = false;
  }

  // Get available languages
  Future<List<String>> getLanguages() async {
    if (!_isInitialized) await initialize();

    try {
      final languages = await _flutterTts?.getLanguages;
      return List<String>.from(languages ?? ['en-US']);
    } catch (e) {
      print('TtsService: Failed to get languages - $e');
      return ['en-US'];
    }
  }

  // Get available voices
  Future<List<Map<String, String>>> getVoices() async {
    if (!_isInitialized) await initialize();

    try {
      final voices = await _flutterTts?.getVoices;
      return List<Map<String, String>>.from(voices ?? []);
    } catch (e) {
      print('TtsService: Failed to get voices - $e');
      return [];
    }
  }
}
