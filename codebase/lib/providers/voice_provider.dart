import 'package:flutter/material.dart';

enum VoiceState { idle, listening, speaking, processing, error }

class VoiceProvider with ChangeNotifier {
  VoiceState _currentState = VoiceState.idle;
  double _volumeLevel = 0.0;
  String _transcribedText = '';
  String _responseText = '';
  bool _isRecording = false;

  // Getters
  VoiceState get currentState => _currentState;
  double get volumeLevel => _volumeLevel;
  String get transcribedText => _transcribedText;
  String get responseText => _responseText;
  bool get isRecording => _isRecording;

  // Voice interaction methods
  void startListening() {
    _currentState = VoiceState.listening;
    _isRecording = true;
    _transcribedText = '';
    notifyListeners();

    // Simulate voice input for demo purposes
    _simulateVoiceInput();
  }

  void stopListening() {
    _currentState = VoiceState.processing;
    _isRecording = false;
    notifyListeners();

    // Simulate processing and response
    _simulateProcessing();
  }

  void _simulateVoiceInput() {
    // Simulate volume levels during recording
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_currentState == VoiceState.listening) {
        _volumeLevel = (DateTime.now().millisecondsSinceEpoch % 1000) / 1000.0;
        notifyListeners();
        _simulateVoiceInput();
      }
    });
  }

  void _simulateProcessing() {
    Future.delayed(const Duration(seconds: 1), () {
      _transcribedText =
          "Hello, I'd like to practice my English conversation skills.";
      _currentState = VoiceState.speaking;
      _responseText =
          "Great! I'm here to help you practice. Let's start with a casual conversation. How was your day?";
      notifyListeners();

      // Simulate speaking animation
      _simulateSpeaking();
    });
  }

  void _simulateSpeaking() {
    Future.delayed(const Duration(seconds: 3), () {
      _currentState = VoiceState.idle;
      _volumeLevel = 0.0;
      notifyListeners();
    });
  }

  void resetConversation() {
    _currentState = VoiceState.idle;
    _volumeLevel = 0.0;
    _transcribedText = '';
    _responseText = '';
    _isRecording = false;
    notifyListeners();
  }

  void setError(String errorMessage) {
    _currentState = VoiceState.error;
    _responseText = errorMessage;
    notifyListeners();

    // Auto-reset after error
    Future.delayed(const Duration(seconds: 3), () {
      _currentState = VoiceState.idle;
      notifyListeners();
    });
  }
}
