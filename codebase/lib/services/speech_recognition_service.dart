import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';

/// Real-time speech recognition service
class SpeechRecognitionService {
  static final SpeechRecognitionService _instance =
      SpeechRecognitionService._internal();
  factory SpeechRecognitionService() => _instance;
  SpeechRecognitionService._internal();

  late stt.SpeechToText _speech;
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastWords = '';

  // Stream controller for real-time results
  final StreamController<String> _speechResultController =
      StreamController<String>.broadcast();
  final StreamController<double> _confidenceController =
      StreamController<double>.broadcast();
  final StreamController<bool> _listeningController =
      StreamController<bool>.broadcast();

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String get lastWords => _lastWords;

  // Streams
  Stream<String> get speechResultStream => _speechResultController.stream;
  Stream<double> get confidenceStream => _confidenceController.stream;
  Stream<bool> get listeningStream => _listeningController.stream;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _speech = stt.SpeechToText();
      _isInitialized = await _speech.initialize(
        onError: _onSpeechError,
        onStatus: _onSpeechStatus,
        debugLogging: true,
      );

      print(
        'SpeechRecognitionService: Initialized successfully - $_isInitialized',
      );
      return _isInitialized;
    } catch (e) {
      print('SpeechRecognitionService: Initialization failed - $e');
      _isInitialized = false;
      return false;
    }
  }

  Future<bool> startListening({
    String localeId = 'en_US',
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (!_isInitialized) {
      print('SpeechRecognitionService: Not initialized');
      return false;
    }

    if (_isListening) {
      print('SpeechRecognitionService: Already listening');
      return true;
    }

    try {
      await _speech.listen(
        onResult: _onSpeechResult,
        localeId: localeId,
        listenFor: timeout,
        pauseFor: const Duration(seconds: 3),
        partialResults: true, // Enable real-time partial results
        onSoundLevelChange: _onSoundLevelChange,
        cancelOnError: false,
        listenMode: stt.ListenMode.confirmation,
      );

      _isListening = true;
      _listeningController.add(true);
      print('SpeechRecognitionService: Started listening');
      return true;
    } catch (e) {
      print('SpeechRecognitionService: Failed to start listening - $e');
      return false;
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speech.stop();
      _isListening = false;
      _listeningController.add(false);
      print('SpeechRecognitionService: Stopped listening');
    } catch (e) {
      print('SpeechRecognitionService: Error stopping - $e');
    }
  }

  Future<void> cancel() async {
    if (!_isListening) return;

    try {
      await _speech.cancel();
      _isListening = false;
      _listeningController.add(false);
      _lastWords = '';
      _speechResultController.add('');
      print('SpeechRecognitionService: Cancelled listening');
    } catch (e) {
      print('SpeechRecognitionService: Error cancelling - $e');
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
    print(
      'SpeechRecognitionService: Result - "${_lastWords}" (confidence: ${result.confidence})',
    );

    // Send real-time results
    _speechResultController.add(_lastWords);
    _confidenceController.add(result.confidence);

    // If this is a final result, stop listening
    if (result.finalResult) {
      print('SpeechRecognitionService: Final result received');
      _isListening = false;
      _listeningController.add(false);
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    print('SpeechRecognitionService: Error - ${error.errorMsg}');
    _isListening = false;
    _listeningController.add(false);
  }

  void _onSpeechStatus(String status) {
    print('SpeechRecognitionService: Status - $status');

    if (status == 'listening') {
      _isListening = true;
      _listeningController.add(true);
    } else if (status == 'notListening' || status == 'done') {
      _isListening = false;
      _listeningController.add(false);
    }
  }

  void _onSoundLevelChange(double level) {
    // Level is typically between 0.0 and 1.0
    // You can use this for volume visualization
  }

  Future<List<stt.LocaleName>> getAvailableLanguages() async {
    if (!_isInitialized) await initialize();

    try {
      return await _speech.locales();
    } catch (e) {
      print('SpeechRecognitionService: Failed to get languages - $e');
      return [];
    }
  }

  Future<bool> hasPermission() async {
    try {
      return await _speech.hasPermission;
    } catch (e) {
      print('SpeechRecognitionService: Permission check failed - $e');
      return false;
    }
  }

  void dispose() {
    if (_isListening) {
      _speech.cancel();
    }
    _speechResultController.close();
    _confidenceController.close();
    _listeningController.close();
  }

  // Web compatibility check
  bool get isWebSupported {
    return kIsWeb; // speech_to_text supports web
  }
}
