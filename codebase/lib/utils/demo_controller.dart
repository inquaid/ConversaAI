import 'dart:async';
import '../providers/voice_provider.dart';

class DemoController {
  final VoiceProvider voiceProvider;
  Timer? _demoTimer;
  int _demoStep = 0;

  DemoController(this.voiceProvider);

  void startDemo() {
    _demoStep = 0;
    _runDemoSequence();
  }

  void stopDemo() {
    _demoTimer?.cancel();
    voiceProvider.resetConversation();
  }

  void _runDemoSequence() {
    _demoTimer?.cancel();

    switch (_demoStep) {
      case 0:
        // Start listening
        voiceProvider.startListening();
        _demoTimer = Timer(const Duration(seconds: 3), () {
          _demoStep = 1;
          _runDemoSequence();
        });
        break;

      case 1:
        // Stop listening and process
        voiceProvider.stopListening();
        _demoTimer = Timer(const Duration(seconds: 2), () {
          _demoStep = 2;
          _runDemoSequence();
        });
        break;

      case 2:
        // Simulate AI response
        voiceProvider.setCustomResponse(
          "Hello! I noticed you'd like to practice English. That's wonderful! Let's have a conversation about your favorite hobbies.",
        );
        _demoTimer = Timer(const Duration(seconds: 4), () {
          _demoStep = 3;
          _runDemoSequence();
        });
        break;

      case 3:
        // Return to idle
        voiceProvider.resetConversation();
        _demoStep = 0;
        break;
    }
  }
}

extension VoiceProviderDemo on VoiceProvider {
  void setCustomResponse(String response) {
    // Add a user message for demo purposes
    addUserMessage("Hi, I want to practice speaking English.");

    // Add the assistant response
    addAssistantMessage(response);

    // No need to manually manage state - the audio service handles this
  }
}
