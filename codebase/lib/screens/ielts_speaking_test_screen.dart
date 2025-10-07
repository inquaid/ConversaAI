/// IELTS Speaking Test Screen - Main test interface with voice narration
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/ielts_speaking_test_models.dart';
import '../providers/ielts_speaking_test_provider.dart';
import '../providers/voice_provider.dart';
import '../services/tts_service.dart';
import '../services/dynamic_ielts_question_generator.dart';
import 'ielts_speaking_test_results_screen.dart';

class IELTSSpeakingTestScreen extends StatefulWidget {
  const IELTSSpeakingTestScreen({Key? key}) : super(key: key);

  @override
  State<IELTSSpeakingTestScreen> createState() =>
      _IELTSSpeakingTestScreenState();
}

class _IELTSSpeakingTestScreenState extends State<IELTSSpeakingTestScreen> {
  Timer? _questionTimer;
  int _elapsedSeconds = 0;
  int _preparationSeconds = 0;
  bool _isPreparation = false;
  String _currentTranscript = '';
  bool _isRecording = false;
  bool _isSpeakingQuestion = false;
  bool _questionSpoken = false;

  final TtsService _ttsService = TtsService();
  final DynamicIELTSQuestionGenerator _questionGenerator =
      DynamicIELTSQuestionGenerator.instance();

  @override
  void initState() {
    super.initState();
    _initializeTTS();
    _startQuestionTimer();
    // Auto-speak the first question when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentQuestion();
    });
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _initializeTTS() async {
    try {
      await _ttsService.initialize();
    } catch (e) {
      print('TTS initialization failed: $e');
    }
  }

  /// Speak the current question using TTS
  Future<void> _speakCurrentQuestion() async {
    if (_questionSpoken) return; // Don't speak again if already spoken

    final testProvider = Provider.of<IELTSSpeakingTestProvider>(
      context,
      listen: false,
    );
    final currentQuestion = testProvider.currentSession?.currentQuestion;
    if (currentQuestion == null) return;

    setState(() {
      _isSpeakingQuestion = true;
    });

    try {
      String textToSpeak;

      // Generate natural spoken question
      if (currentQuestion.part == SpeakingTestPart.part2) {
        textToSpeak = await _questionGenerator.generateSpokenQuestion(
          currentQuestion,
        );
      } else {
        textToSpeak = currentQuestion.question;
      }

      await _ttsService.speak(textToSpeak);
      setState(() {
        _questionSpoken = true;
      });
    } catch (e) {
      print('Error speaking question: $e');
    } finally {
      setState(() {
        _isSpeakingQuestion = false;
      });
    }
  }

  /// Replay the current question
  Future<void> _replayQuestion() async {
    setState(() {
      _questionSpoken = false; // Allow replay
    });
    await _speakCurrentQuestion();
  }

  void _startQuestionTimer() {
    _elapsedSeconds = 0;
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _startPreparationTimer() {
    _preparationSeconds = 60; // 1 minute preparation for Part 2
    _isPreparation = true;
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _preparationSeconds--;
          if (_preparationSeconds <= 0) {
            _isPreparation = false;
            timer.cancel();
            _startQuestionTimer();
            // Speak the question when preparation time is over
            _speakCurrentQuestion();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF1565C0), const Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: Consumer2<IELTSSpeakingTestProvider, VoiceProvider>(
            builder: (context, testProvider, voiceProvider, child) {
              final session = testProvider.currentSession;
              final currentQuestion = session?.currentQuestion;

              if (session == null || currentQuestion == null) {
                return _buildNoSessionView();
              }

              return Column(
                children: [
                  // Header with progress
                  _buildHeader(context, session),

                  // Main content
                  Expanded(
                    child: _isPreparation
                        ? _buildPreparationView(currentQuestion)
                        : _buildQuestionView(
                            context,
                            session,
                            currentQuestion,
                            voiceProvider,
                          ),
                  ),

                  // Bottom controls
                  _buildBottomControls(
                    context,
                    testProvider,
                    voiceProvider,
                    currentQuestion,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNoSessionView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.white70),
          const SizedBox(height: 20),
          const Text(
            'No active test session',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SpeakingTestSession session) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _showExitDialog(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      session.currentPart.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Question ${session.currentQuestionIndex + 1} of ${session.questions.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.white, size: 18),
                    const SizedBox(width: 5),
                    Text(
                      _formatTime(_elapsedSeconds),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: session.progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.greenAccent,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreparationView(SpeakingQuestion question) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.edit_note, size: 80, color: Color(0xFF1565C0)),
          const SizedBox(height: 30),
          const Text(
            'Preparation Time',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _formatTime(_preparationSeconds),
            style: const TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Use this time to prepare your answer',
            style: TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                if (question.bulletPoints != null) ...[
                  const SizedBox(height: 15),
                  ...question.bulletPoints!.map((point) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              point,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionView(
    BuildContext context,
    SpeakingTestSession session,
    SpeakingQuestion question,
    VoiceProvider voiceProvider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question card
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.blue.shade50],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.question_answer,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          question.part.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  // Replay question button
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: _isSpeakingQuestion ? null : _replayQuestion,
                    icon: Icon(
                      _isSpeakingQuestion ? Icons.volume_up : Icons.replay,
                    ),
                    label: Text(
                      _isSpeakingQuestion ? 'Speaking...' : 'Replay Question',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSpeakingQuestion
                          ? Colors.grey.shade400
                          : const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  if (question.bulletPoints != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: question.bulletPoints!.map((point) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: Color(0xFF1565C0),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    point,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  if (question.part == SpeakingTestPart.part2) ...[
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Speak for 1-2 minutes',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Recording indicator and transcript
          if (_isRecording || _currentTranscript.isNotEmpty)
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (_isRecording)
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade300,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        if (_isRecording) const SizedBox(width: 10),
                        Text(
                          _isRecording ? 'Recording...' : 'Your Response',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                      ],
                    ),
                    if (_currentTranscript.isNotEmpty) ...[
                      const SizedBox(height: 15),
                      Text(
                        _currentTranscript,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(
    BuildContext context,
    IELTSSpeakingTestProvider testProvider,
    VoiceProvider voiceProvider,
    SpeakingQuestion question,
  ) {
    final session = testProvider.currentSession!;
    final isLastQuestion =
        session.currentQuestionIndex == session.questions.length - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isPreparation) ...[
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isPreparation = false;
                  _questionTimer?.cancel();
                  _startQuestionTimer();
                });
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Speaking Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ] else ...[
            // Record button
            GestureDetector(
              onTapDown: (_) => _startRecording(voiceProvider),
              onTapUp: (_) => _stopRecording(voiceProvider, testProvider),
              onTapCancel: () => _stopRecording(voiceProvider, testProvider),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.red : const Color(0xFF1565C0),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_isRecording ? Colors.red : const Color(0xFF1565C0))
                              .withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _isRecording ? Icons.mic : Icons.mic_none,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              _isRecording
                  ? 'Hold to record your answer'
                  : 'Tap and hold to record',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 20),

            // Next button
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showExitDialog(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Color(0xFF1565C0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('Exit'),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _handleNext(context, testProvider, isLastQuestion),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      isLastQuestion ? 'Finish Test' : 'Next Question',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _startRecording(VoiceProvider voiceProvider) {
    setState(() {
      _isRecording = true;
      _currentTranscript = '';
    });
    voiceProvider.startListening();

    // Listen to real-time transcript
    voiceProvider.addListener(_updateTranscript);
  }

  void _updateTranscript() {
    final voiceProvider = Provider.of<VoiceProvider>(context, listen: false);
    if (mounted && voiceProvider.lastRecognizedText.isNotEmpty) {
      setState(() {
        _currentTranscript = voiceProvider.lastRecognizedText;
      });
    }
  }

  Future<void> _stopRecording(
    VoiceProvider voiceProvider,
    IELTSSpeakingTestProvider testProvider,
  ) async {
    voiceProvider.removeListener(_updateTranscript);
    await voiceProvider.stopListening();

    setState(() {
      _isRecording = false;
    });

    // Submit response
    if (_currentTranscript.isNotEmpty) {
      final feedback = await testProvider.submitResponse(
        _currentTranscript,
        _elapsedSeconds,
      );

      if (feedback != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(feedback),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleNext(
    BuildContext context,
    IELTSSpeakingTestProvider testProvider,
    bool isLastQuestion,
  ) {
    if (isLastQuestion) {
      _finishTest(context, testProvider);
    } else {
      final nextQuestion = testProvider
          .currentSession!
          .questions[testProvider.currentSession!.currentQuestionIndex + 1];

      // Check if next question is Part 2 and needs preparation
      if (nextQuestion.part == SpeakingTestPart.part2 &&
          nextQuestion.preparationTimeSeconds != null) {
        _startPreparationTimer();
      } else {
        _startQuestionTimer();
      }

      testProvider.nextQuestion();
      setState(() {
        _currentTranscript = '';
        _questionSpoken = false; // Reset for new question
      });

      // Speak the new question (unless it's Part 2 with preparation)
      if (nextQuestion.part != SpeakingTestPart.part2) {
        _speakCurrentQuestion();
      }
    }
  }

  Future<void> _finishTest(
    BuildContext context,
    IELTSSpeakingTestProvider testProvider,
  ) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      await testProvider.completeTest();

      if (!mounted) return;

      // Close loading
      Navigator.pop(context);

      // Navigate to results
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => IELTSSpeakingTestResultsScreen(
            testSession: testProvider.currentSession!,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Close loading
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete test: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Test?'),
        content: const Text(
          'Are you sure you want to exit? Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final provider = Provider.of<IELTSSpeakingTestProvider>(
                context,
                listen: false,
              );
              provider.cancelTest();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close test screen
            },
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
