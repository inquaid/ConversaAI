import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import '../services/speech_recognition_service.dart';
import '../services/tts_service.dart';
import '../services/web_ai_backend_service.dart';
import '../config/app_config.dart';
import '../models/conversation_models.dart';

enum VoiceState { idle, listening, speaking, processing, error }

class VoiceProvider with ChangeNotifier {
  final SpeechRecognitionService _speechService = SpeechRecognitionService();
  final TtsService _ttsService = TtsService();
  final AiBackendService _aiService = AiBackendService(
    geminiApiKey: AppConfig.activeGeminiApiKey,
  );

  VoiceState _currentState = VoiceState.idle;
  double _volumeLevel = 0.0;
  String _transcribedText = '';
  String _responseText = '';
  bool _isRecording = false;
  bool _isTyping = false;
  String _currentTranscript = '';

  // Stream subscriptions
  StreamSubscription<String>? _speechResultSubscription;
  StreamSubscription<bool>? _speechListeningSubscription;
  Timer? _volumeSimulationTimer;

  // Enhanced conversation management
  ConversationSession? _currentSession;
  final List<ConversationSession> _conversationHistory = [];

  VoiceProvider() {
    _initializeServices();
  }

  void _initializeServices() async {
    await _speechService.initialize();
    await _ttsService.initialize();
  }

  // Getters
  VoiceState get currentState => _currentState;
  double get volumeLevel => _volumeLevel;
  String get transcribedText => _transcribedText;
  String get responseText => _responseText;
  bool get isRecording => _isRecording;
  bool get isTyping => _isTyping;
  String get currentTranscript => _currentTranscript;

  // Current conversation messages
  List<ChatMessage> get currentMessages => _currentSession?.messages ?? [];

  // Voice interaction methods with real speech recognition
  Future<void> startListening() async {
    try {
      print('VoiceProvider: Starting real speech recognition...');
      _ensureCurrentSession();
      _currentState = VoiceState.listening;
      _isRecording = true;
      _transcribedText = '';
      _currentTranscript = 'Listening for your voice...';
      notifyListeners();

      // Start real speech recognition
      final speechStarted = await _speechService.startListening();
      if (!speechStarted) {
        setError(
          'Speech recognition unavailable. Please check microphone permissions.',
        );
        return;
      }

      // Subscribe to real-time speech results
      _speechResultSubscription?.cancel();
      _speechResultSubscription = _speechService.speechResultStream.listen((
        text,
      ) {
        print('VoiceProvider: Real-time speech - "$text"');
        _currentTranscript = text.isNotEmpty
            ? text
            : 'Listening for your voice...';
        notifyListeners();
      });

      // Subscribe to speech listening status
      _speechListeningSubscription?.cancel();
      _speechListeningSubscription = _speechService.listeningStream.listen((
        isListening,
      ) {
        _isRecording = isListening;
        if (!isListening && _currentState == VoiceState.listening) {
          // Speech recognition has finished, process the final result
          _processRecognizedSpeech();
        }
        notifyListeners();
      });

      // Start volume simulation for visual feedback
      _startVolumeSimulation();

      print('VoiceProvider: Speech recognition started successfully');
    } catch (e) {
      print('VoiceProvider: Error starting speech recognition: $e');
      setError('Failed to start speech recognition: $e');
    }
  }

  Future<void> stopListening() async {
    try {
      if (_currentState != VoiceState.listening) return;

      print('VoiceProvider: Stopping speech recognition...');
      _currentState = VoiceState.processing;
      _isRecording = false;

      // Stop speech recognition
      await _speechService.stopListening();

      // Cancel subscriptions and timers
      _speechResultSubscription?.cancel();
      _speechListeningSubscription?.cancel();
      _stopVolumeSimulation();

      notifyListeners();

      // Process the final recognized speech
      _processRecognizedSpeech();
    } catch (e) {
      print('VoiceProvider: Error stopping speech recognition: $e');
      setError('Error stopping speech recognition: $e');
    }
  }

  void _processRecognizedSpeech() async {
    final recognizedText = _speechService.lastWords;
    print('VoiceProvider: Processing recognized speech - "$recognizedText"');

    if (recognizedText.isEmpty) {
      setError('No speech was recognized. Please try again.');
      return;
    }

    // Add user message
    addUserMessage(recognizedText);

    // Generate AI response (simulated for now)
    _currentState = VoiceState.processing;
    _isTyping = true;
    notifyListeners();

    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 1));

    final aiResponse = await _generateAIResponse(recognizedText);
    addAssistantMessage(aiResponse);

    _isTyping = false;

    // Speak the AI response
    _currentState = VoiceState.speaking;
    notifyListeners();

    await _ttsService.speak(aiResponse);

    // Return to idle after speaking
    await Future.delayed(const Duration(seconds: 1));
    _currentState = VoiceState.idle;
    _currentTranscript = '';
    notifyListeners();
  }

  Future<String> _generateAIResponse(String userInput) async {
    print('VoiceProvider: Generating AI response for: "$userInput"');
    try {
      // Use the actual AI backend service
      print('VoiceProvider: Calling AI service...');
      final response = await _aiService.processText(userInput);
      print('VoiceProvider: AI service responded: "$response"');
      return response;
    } catch (e) {
      print('AI service error: $e');
      // Fallback to simple responses if AI service fails
      final responses = [
        "I'm having trouble connecting to my AI service. Can you try again?",
        "Sorry, there seems to be a technical issue. Let's continue our conversation.",
        "I apologize for the interruption. What were you saying?",
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }
  }

  // Helper methods
  void _startVolumeSimulation() {
    _volumeSimulationTimer?.cancel();
    _volumeSimulationTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      if (_currentState == VoiceState.listening) {
        _volumeLevel = (DateTime.now().millisecondsSinceEpoch % 1000) / 1000.0;
        notifyListeners();
      }
    });
  }

  void _stopVolumeSimulation() {
    _volumeSimulationTimer?.cancel();
    _volumeLevel = 0.0;
  }

  void _ensureCurrentSession() {
    _currentSession ??= ConversationSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      messages: [],
      title: "Conversation ${_conversationHistory.length + 1}",
    );
  }

  void addUserMessage(String content) {
    _ensureCurrentSession();
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
    _currentSession!.addMessage(message);
    _transcribedText = content;
    notifyListeners();
  }

  void addAssistantMessage(String content) {
    _ensureCurrentSession();
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.assistant,
      timestamp: DateTime.now(),
    );
    _currentSession!.addMessage(message);
    _responseText = content;
    notifyListeners();
  }

  void resetConversation() {
    if (_currentSession != null && _currentSession!.messages.isNotEmpty) {
      _conversationHistory.add(_currentSession!);
    }

    _currentSession = null;
    _currentState = VoiceState.idle;
    _volumeLevel = 0.0;
    _transcribedText = '';
    _responseText = '';
    _isRecording = false;
    _isTyping = false;
    _currentTranscript = '';
    notifyListeners();
  }

  void setError(String errorMessage) {
    _currentState = VoiceState.error;
    _responseText = errorMessage;
    _currentTranscript = errorMessage;
    notifyListeners();

    // Auto-reset after error
    Future.delayed(const Duration(seconds: 3), () {
      _currentState = VoiceState.idle;
      _currentTranscript = '';
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _speechResultSubscription?.cancel();
    _speechListeningSubscription?.cancel();
    _volumeSimulationTimer?.cancel();
    _speechService.dispose();
    _ttsService.dispose();
    super.dispose();
  }
}
