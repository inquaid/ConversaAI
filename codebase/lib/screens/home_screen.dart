import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/voice_interface.dart';
import '../widgets/app_header.dart';
import '../widgets/conversation_list.dart';
import '../widgets/enhanced_voice_visualizer.dart';
import 'ielts_home_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const IELTSHomeScreen()),
          );
        },
        icon: const Icon(Icons.school),
        label: const Text('IELTS Exam'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: SafeArea(
        // Only depend on ThemeProvider at the top level to avoid rebuilding the whole tree on voice updates
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Container(
              decoration: _buildGradientBackground(
                context,
                themeProvider.isDarkMode,
              ),
              child: Column(
                children: [
                  // Header with app title and theme toggle
                  Consumer<VoiceProvider>(
                    child: AppHeader(
                      onThemeToggle: () => themeProvider.toggleTheme(),
                      isDarkMode: themeProvider.isDarkMode,
                      onDemoPressed: () => _startDemo(
                        // Will be replaced by parent Consumer value via builder
                        // but provided through the builder below
                        context.read<VoiceProvider>(),
                      ),
                    ),
                    builder: (context, voiceProvider, header) {
                      // Use provided header child; we only need voiceProvider for onDemoPressed
                      return AppHeader(
                        onThemeToggle: () => themeProvider.toggleTheme(),
                        isDarkMode: themeProvider.isDarkMode,
                        onDemoPressed: () => _startDemo(voiceProvider),
                      );
                    },
                  ),

                  // Main content area
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Column(
                        children: [
                          // Voice visualizer area with enhanced background
                          Selector<VoiceProvider, VoiceState>(
                            selector: (_, vp) => vp.currentState,
                            builder: (context, state, _) {
                              if (state == VoiceState.idle) {
                                return const SizedBox(height: 0);
                              }
                              return Container(
                                height: 180,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: themeProvider.isDarkMode
                                        ? [
                                            Colors.black.withOpacity(0.2),
                                            Colors.black.withOpacity(0.05),
                                          ]
                                        : [
                                            Colors.white.withOpacity(0.3),
                                            Colors.white.withOpacity(0.1),
                                          ],
                                  ),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.1),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.1),
                                      blurRadius: 20,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: RepaintBoundary(
                                    child: Selector<VoiceProvider, double>(
                                      selector: (_, vp) => vp.volumeLevel,
                                      builder: (context, volume, __) =>
                                          EnhancedVoiceVisualizer(
                                            voiceState: state,
                                            volumeLevel: volume,
                                          ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Conversation history
                          Expanded(
                            child: RepaintBoundary(
                              child: Consumer<VoiceProvider>(
                                builder: (context, vp, _) => ConversationList(
                                  messages: vp.currentMessages,
                                  isTyping: vp.isTyping,
                                  voiceState: vp.currentState,
                                  currentTranscript: vp.currentTranscript,
                                ),
                              ),
                            ),
                          ),

                          // Voice interface (bottom fixed)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).scaffoldBackgroundColor.withOpacity(0.9),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).shadowColor.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: RepaintBoundary(
                              child:
                                  Selector<
                                    VoiceProvider,
                                    (VoiceState, double, bool)
                                  >(
                                    selector: (_, vp) => (
                                      vp.currentState,
                                      vp.volumeLevel,
                                      vp.isRecording,
                                    ),
                                    builder: (context, tuple, __) =>
                                        VoiceInterface(
                                          voiceState: tuple.$1,
                                          volumeLevel: tuple.$2,
                                          onMicPressed: () => _handleMicPressed(
                                            context.read<VoiceProvider>(),
                                          ),
                                          isRecording: tuple.$3,
                                        ),
                                  ),
                            ),
                          ),
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
