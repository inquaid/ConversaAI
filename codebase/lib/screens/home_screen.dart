import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/voice_interface.dart';
import '../widgets/app_header.dart';
import '../widgets/conversation_feedback.dart';
import '../widgets/animated_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer2<VoiceProvider, ThemeProvider>(
          builder: (context, voiceProvider, themeProvider, child) {
            return Container(
              decoration: _buildGradientBackground(
                context,
                themeProvider.isDarkMode,
              ),
              child: Column(
                children: [
                  // Header with app title and theme toggle
                  AppHeader(
                    onThemeToggle: () => themeProvider.toggleTheme(),
                    isDarkMode: themeProvider.isDarkMode,
                    onDemoPressed: () => _startDemo(voiceProvider),
                  ),

                  // Main content area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          // Conversation feedback area
                          Expanded(
                            flex: 2,
                            child: ConversationFeedback(
                              voiceState: voiceProvider.currentState,
                              transcribedText: voiceProvider.transcribedText,
                              responseText: voiceProvider.responseText,
                            ),
                          ),

                          // Voice interface (main interaction area)
                          Expanded(
                            flex: 3,
                            child: VoiceInterface(
                              voiceState: voiceProvider.currentState,
                              volumeLevel: voiceProvider.volumeLevel,
                              onMicPressed: () =>
                                  _handleMicPressed(voiceProvider),
                              isRecording: voiceProvider.isRecording,
                            ),
                          ),

                          // Bottom spacing
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  BoxDecoration _buildGradientBackground(
    BuildContext context,
    bool isDarkMode,
  ) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDarkMode
            ? [
                const Color(0xFF1C1C1E),
                const Color(0xFF2C2C2E),
                const Color(0xFF1C1C1E),
              ]
            : [Colors.white, const Color(0xFFF8F9FA), Colors.white],
      ),
    );
  }

  void _handleMicPressed(VoiceProvider voiceProvider) {
    switch (voiceProvider.currentState) {
      case VoiceState.idle:
        voiceProvider.startListening();
        break;
      case VoiceState.listening:
        voiceProvider.stopListening();
        break;
      case VoiceState.speaking:
      case VoiceState.processing:
        // Do nothing during these states
        break;
      case VoiceState.error:
        voiceProvider.resetConversation();
        break;
    }
  }

  void _startDemo(VoiceProvider voiceProvider) {
    // Simple demo sequence
    voiceProvider.resetConversation();

    // Start listening after a brief delay
    Future.delayed(const Duration(milliseconds: 500), () {
      voiceProvider.startListening();

      // Simulate user speaking for 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        voiceProvider.stopListening();

        // Show AI response after processing
        Future.delayed(const Duration(seconds: 1), () {
          // This would be replaced with actual AI integration
          voiceProvider.resetConversation();
        });
      });
    });
  }
}
