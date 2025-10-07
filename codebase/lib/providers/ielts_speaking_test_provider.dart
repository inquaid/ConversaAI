/// Provider for managing IELTS Speaking Test state
import 'package:flutter/foundation.dart';
import '../models/ielts_speaking_test_models.dart';
import '../services/ielts_speaking_question_bank.dart';
import '../services/ielts_speaking_evaluation_service.dart';
import '../services/dynamic_ielts_question_generator.dart';

class IELTSSpeakingTestProvider with ChangeNotifier {
  SpeakingTestSession? _currentSession;
  bool _isLoading = false;
  String? _error;
  final IELTSSpeakingEvaluationService _evaluationService =
      IELTSSpeakingEvaluationService.instance();
  final DynamicIELTSQuestionGenerator _questionGenerator =
      DynamicIELTSQuestionGenerator.instance();

  // History of completed tests
  final List<SpeakingTestSession> _completedTests = [];

  // Getters
  SpeakingTestSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<SpeakingTestSession> get completedTests =>
      List.unmodifiable(_completedTests);
  bool get hasActiveSession =>
      _currentSession != null && !_currentSession!.isCompleted;

  /// Start a new speaking test with dynamic AI-generated questions
  Future<void> startTest(SpeakingTestDuration duration) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      List<SpeakingQuestion> questions;

      try {
        // Try to generate dynamic questions first
        questions = await _questionGenerator.generateDynamicTest(duration);
        print('✅ Using AI-generated questions');
      } catch (e) {
        // Fallback to static questions if dynamic generation fails
        print('⚠️ Dynamic generation failed, using static questions: $e');
        questions = IELTSSpeakingQuestionBank.generateTest(duration);
      }

      // Create new session
      _currentSession = SpeakingTestSession(
        duration: duration,
        startedAt: DateTime.now(),
        questions: questions,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to start test: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submit response for current question
  Future<String?> submitResponse(
    String transcribedText,
    int durationSeconds,
  ) async {
    if (_currentSession == null || _currentSession!.currentQuestion == null) {
      return null;
    }

    final currentQuestion = _currentSession!.currentQuestion!;

    final response = SpeakingResponse(
      questionId: currentQuestion.id,
      transcribedText: transcribedText,
      durationSeconds: durationSeconds,
      timestamp: DateTime.now(),
    );

    _currentSession!.addResponse(response);

    // Get quick feedback for the response
    String? feedback;
    try {
      feedback = await _evaluationService.getQuickFeedback(
        currentQuestion,
        response,
      );
    } catch (e) {
      print('Failed to get quick feedback: $e');
    }

    notifyListeners();
    return feedback;
  }

  /// Move to next question
  void nextQuestion() {
    if (_currentSession != null) {
      _currentSession!.nextQuestion();
      notifyListeners();
    }
  }

  /// Complete the test and get evaluation
  Future<void> completeTest() async {
    if (_currentSession == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Mark as completed
      _currentSession!.completedAt = DateTime.now();

      // Get comprehensive evaluation
      final evaluation = await _evaluationService.evaluateTest(
        _currentSession!,
      );
      _currentSession!.evaluation = evaluation;

      // Add to history
      _completedTests.insert(0, _currentSession!);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to evaluate test: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Cancel current test
  void cancelTest() {
    _currentSession = null;
    _error = null;
    notifyListeners();
  }

  /// Get test by ID from history
  SpeakingTestSession? getTestById(String id) {
    try {
      return _completedTests.firstWhere((test) => test.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get average band score from history
  double? get averageBandScore {
    if (_completedTests.isEmpty) return null;

    final scores = _completedTests
        .where((test) => test.evaluation != null)
        .map((test) => test.evaluation!.criteria.overallBand)
        .toList();

    if (scores.isEmpty) return null;

    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// Get highest band score from history
  double? get highestBandScore {
    if (_completedTests.isEmpty) return null;

    final scores = _completedTests
        .where((test) => test.evaluation != null)
        .map((test) => test.evaluation!.criteria.overallBand)
        .toList();

    if (scores.isEmpty) return null;

    return scores.reduce((a, b) => a > b ? a : b);
  }

  /// Get total tests completed
  int get totalTestsCompleted => _completedTests.length;

  /// Clear all test history
  void clearHistory() {
    _completedTests.clear();
    notifyListeners();
  }
}
