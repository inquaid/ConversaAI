import 'package:flutter/material.dart';
import 'dart:async';

enum ConversationState { idle, speaking, listening, processing }

class AppStateProvider extends ChangeNotifier {
  ConversationState _conversationState = ConversationState.idle;
  bool _isConnected = false;
  String _statusMessage = 'Ready to start conversation';
  bool _isAutoFlowActive = false;
  Timer? _simulationTimer;

  // Getters
  ConversationState get conversationState => _conversationState;
  bool get isConnected => _isConnected;
  String get statusMessage => _statusMessage;
  bool get isAutoFlowActive => _isAutoFlowActive;

  bool get isSpeaking => _conversationState == ConversationState.speaking;
  bool get isListening => _conversationState == ConversationState.listening;
  bool get isProcessing => _conversationState == ConversationState.processing;
  bool get isIdle => _conversationState == ConversationState.idle;

  // Methods to update state
  void setConversationState(ConversationState state) {
    _conversationState = state;
    _updateStatusMessage();
    notifyListeners();
  }

  void setConnectionStatus(bool connected) {
    _isConnected = connected;
    _updateStatusMessage();
    notifyListeners();
  }

  // Natural conversation flow methods
  void startNaturalConversation() {
    _isAutoFlowActive = true;
    startSpeaking(); // Auto-start with user speaking
  }

  void stopNaturalConversation() {
    _isAutoFlowActive = false;
    _simulationTimer?.cancel();
    setConversationState(ConversationState.idle);
  }

  // Manual control methods (interrupt/force)
  void forceStartSpeaking() {
    _simulationTimer?.cancel();
    _isAutoFlowActive = true;
    setConversationState(ConversationState.speaking);
    _scheduleNextTransition();
  }

  void forceStartListening() {
    _simulationTimer?.cancel();
    _isAutoFlowActive = true;
    setConversationState(ConversationState.listening);
    _scheduleNextTransition();
  }

  void interruptConversation() {
    _simulationTimer?.cancel();
    _isAutoFlowActive = false;
    setConversationState(ConversationState.idle);
  }

  // Legacy methods for compatibility
  void startSpeaking() {
    setConversationState(ConversationState.speaking);
    if (_isAutoFlowActive) {
      _scheduleNextTransition();
    }
  }

  void startListening() {
    setConversationState(ConversationState.listening);
    if (_isAutoFlowActive) {
      _scheduleNextTransition();
    }
  }

  void startProcessing() {
    setConversationState(ConversationState.processing);
    if (_isAutoFlowActive) {
      _scheduleNextTransition();
    }
  }

  void stopConversation() {
    stopNaturalConversation();
  }

  // Private method to handle automatic transitions
  void _scheduleNextTransition() {
    _simulationTimer?.cancel();

    switch (_conversationState) {
      case ConversationState.speaking:
        // Simulate user speaking for 3-5 seconds, then process
        _simulationTimer = Timer(const Duration(seconds: 4), () {
          if (_isAutoFlowActive) {
            setConversationState(ConversationState.processing);
            _scheduleNextTransition();
          }
        });
        break;

      case ConversationState.processing:
        // Simulate AI processing for 2-3 seconds, then respond
        _simulationTimer = Timer(const Duration(seconds: 2), () {
          if (_isAutoFlowActive) {
            setConversationState(ConversationState.listening);
            _scheduleNextTransition();
          }
        });
        break;

      case ConversationState.listening:
        // Simulate AI speaking for 3-4 seconds, then wait for user
        _simulationTimer = Timer(const Duration(seconds: 3), () {
          if (_isAutoFlowActive) {
            setConversationState(ConversationState.speaking);
            _scheduleNextTransition();
          }
        });
        break;

      case ConversationState.idle:
        // Do nothing in idle state
        break;
    }
  }

  void _updateStatusMessage() {
    switch (_conversationState) {
      case ConversationState.idle:
        _statusMessage = _isConnected
            ? 'Tap to start conversation'
            : 'Connecting...';
        break;
      case ConversationState.speaking:
        _statusMessage = _isAutoFlowActive
            ? 'Listening to you...'
            : 'Speak now...';
        break;
      case ConversationState.listening:
        _statusMessage = _isAutoFlowActive
            ? 'AI is responding...'
            : 'Listening to AI response...';
        break;
      case ConversationState.processing:
        _statusMessage = 'Processing your message...';
        break;
    }
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}
