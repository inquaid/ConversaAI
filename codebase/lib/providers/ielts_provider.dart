import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/ielts_models.dart';
import '../services/ielts_evaluation_service.dart';

/// Provider class for managing IELTS exams and attempts
class IELTSProvider extends ChangeNotifier {
  final IELTSEvaluationService _evaluationService;
  final List<IELTSExam> _exams = [];
  final List<IELTSAttempt> _userAttempts = [];
  IELTSUserProfile? _userProfile;
  IELTSAttempt? _currentAttempt;
  IELTSExam? _currentExam;
  bool _isLoading = false;

  IELTSProvider({IELTSEvaluationService? evaluationService})
    : _evaluationService =
          evaluationService ?? IELTSEvaluationService.withDefaultKey();

  // Getters
  List<IELTSExam> get exams => _exams;
  List<IELTSAttempt> get userAttempts => _userAttempts;
  IELTSUserProfile? get userProfile => _userProfile;
  IELTSAttempt? get currentAttempt => _currentAttempt;
  IELTSExam? get currentExam => _currentExam;
  bool get isLoading => _isLoading;

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Initialize the user profile
  Future<void> initializeUserProfile(String userId) async {
    _setLoading(true);
    try {
      // In a real app, this would load from a database
      _userProfile = IELTSUserProfile(userId: userId, attempts: []);

      // For testing, load some sample exams
      await _loadSampleExams();

      // Load attempts from storage
      await _loadUserAttempts();
    } catch (e) {
      debugPrint('Error initializing user profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load sample IELTS exams
  Future<void> _loadSampleExams() async {
    // In a real app, these would come from a database
    final listeningContent = [
      {
        'type': 'audio',
        'url': 'assets/audio/listening_section1.mp3',
        'questions': [
          {
            'id': 'L1_Q1',
            'text': 'What is the woman\'s name?',
            'answer': 'Sarah Johnson',
          },
          // More questions...
        ],
      },
    ];

    final readingContent = [
      {
        'type': 'passage',
        'text': 'The impact of climate change on global agriculture...',
        'questions': [
          {
            'id': 'R1_Q1',
            'text':
                'According to the passage, what is the main effect of climate change on crop yields?',
            'options': [
              'Increased yields',
              'Decreased yields',
              'No change',
              'Varies by region',
            ],
            'answer': 'Decreased yields',
          },
          // More questions...
        ],
      },
    ];

    final writingContent = [
      {
        'type': 'task1',
        'description':
            'The graph below shows the percentage of people who used public transportation in a city over a 10-year period. Summarize the information by selecting and reporting the main features, and make comparisons where relevant.',
        'imageUrl': 'assets/images/writing_task1_graph.png',
        'wordCount': 150,
        'timeMinutes': 20,
      },
      {
        'type': 'task2',
        'description':
            'Some people believe that technology has made our lives too complex and that we should return to a simpler way of living. To what extent do you agree or disagree?',
        'wordCount': 250,
        'timeMinutes': 40,
      },
    ];

    final speakingContent = [
      {
        'type': 'part1',
        'topics': [
          {
            'name': 'Work/Study',
            'questions': [
              'What do you do? Do you work or are you a student?',
              'Why did you choose this job/subject?',
              'What do you like most about your job/studies?',
            ],
          },
          // More topics...
        ],
        'timeMinutes': 4,
      },
      {
        'type': 'part2',
        'topics': [
          {
            'name': 'Describe a place',
            'description':
                'Describe a place you have visited that made a strong impression on you.',
            'points': [
              'Where it is',
              'When you went there',
              'What you did there',
              'Why it made a strong impression on you',
            ],
          },
          // More topics...
        ],
        'prepTimeMinutes': 1,
        'speakTimeMinutes': 2,
      },
      {
        'type': 'part3',
        'topics': [
          {
            'name': 'Places and travel',
            'questions': [
              'Why do people like to travel to different places?',
              'How has travel changed in the last few decades?',
              "Do you think it's better to travel alone or with other people?",
            ],
          },
          // More topics...
        ],
        'timeMinutes': 5,
      },
    ];

    final sampleExam = IELTSExam(
      id: 'exam1',
      title: 'IELTS Academic Test - Sample 1',
      type: IELTSExamType.academic,
      content: {
        IELTSSection.listening: listeningContent,
        IELTSSection.reading: readingContent,
        IELTSSection.writing: writingContent,
        IELTSSection.speaking: speakingContent,
      },
      createdAt: DateTime.now(),
      isPractice: true,
      isOfficial: true,
    );

    _exams.add(sampleExam);
    notifyListeners();
  }

  /// Load user's previous attempts
  Future<void> _loadUserAttempts() async {
    // In a real app, this would load from a database
    if (_userProfile != null) {
      _userAttempts.addAll(_userProfile!.attempts);
      notifyListeners();
    }
  }

  /// Start a new IELTS exam attempt
  Future<IELTSAttempt?> startExam(String examId) async {
    _setLoading(true);
    try {
      final exam = _exams.firstWhere((e) => e.id == examId);

      final newAttempt = IELTSAttempt(
        id: const Uuid().v4(),
        examId: exam.id,
        startedAt: DateTime.now(),
        type: exam.type,
        sectionData: {
          for (var section in IELTSSection.values)
            section: {'answers': [], 'timeSpent': 0},
        },
        completedSections: {
          for (var section in IELTSSection.values) section: false,
        },
      );

      _currentAttempt = newAttempt;
      _currentExam = exam;
      _userAttempts.add(newAttempt);

      if (_userProfile != null) {
        _userProfile!.attempts.add(newAttempt);
      }

      notifyListeners();
      return newAttempt;
    } catch (e) {
      debugPrint('Error starting exam: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Save user's answers for a section
  Future<void> saveSectionAnswers({
    required IELTSSection section,
    required Map<String, dynamic> answers,
    required int timeSpentSeconds,
  }) async {
    if (_currentAttempt == null) return;

    _setLoading(true);
    try {
      _currentAttempt!.sectionData[section] = {
        'answers': answers,
        'timeSpent': timeSpentSeconds,
      };

      _currentAttempt!.completedSections[section] = true;

      notifyListeners();
    } catch (e) {
      debugPrint('Error saving section answers: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Complete the current exam attempt and calculate scores
  Future<IELTSBandScore?> completeExam() async {
    if (_currentAttempt == null || _currentExam == null) return null;

    _setLoading(true);
    try {
      // Set completion timestamp
      _currentAttempt = _currentAttempt!.copyWith(completedAt: DateTime.now());

      // Calculate scores for each section
      final listeningScore = await _calculateListeningScore();
      final readingScore = await _calculateReadingScore();
      final writingScore = await _calculateWritingScore();
      final speakingScore = await _calculateSpeakingScore();

      // Create overall band score
      final bandScore = IELTSBandScore.fromSections(
        listening: listeningScore,
        reading: readingScore,
        writing: writingScore,
        speaking: speakingScore,
      );

      // Update the attempt with the score
      _currentAttempt = _currentAttempt!.copyWith(score: bandScore);

      // Update user profile with new highest score if applicable
      if (_userProfile != null) {
        final highestScore = _userProfile!.calculateHighestScore();
        _userProfile = _userProfile!.copyWith(highestScore: highestScore);
      }

      notifyListeners();
      return bandScore;
    } catch (e) {
      debugPrint('Error completing exam: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Calculate listening section score
  Future<double> _calculateListeningScore() async {
    if (_currentAttempt == null || _currentExam == null) return 0.0;

    try {
      final sectionData = _currentAttempt!.sectionData[IELTSSection.listening];
      final examContent = _currentExam!.content[IELTSSection.listening];

      if (sectionData == null || examContent == null) return 0.0;

      final answers = sectionData['answers'] as List<dynamic>;

      // Extract correct answers from exam content
      final List<String> correctAnswers = [];
      for (final part in examContent) {
        final questions = part['questions'] as List<dynamic>;
        for (final question in questions) {
          correctAnswers.add(question['answer']);
        }
      }

      // Extract user answers
      final List<String> userAnswers = answers
          .map((a) => a.toString())
          .toList();

      // Evaluate with the evaluation service
      return _evaluationService.evaluateListeningResponse(
        userAnswers: userAnswers,
        correctAnswers: correctAnswers,
      );
    } catch (e) {
      debugPrint('Error calculating listening score: $e');
      return 0.0;
    }
  }

  /// Calculate reading section score
  Future<double> _calculateReadingScore() async {
    if (_currentAttempt == null || _currentExam == null) return 0.0;

    try {
      final sectionData = _currentAttempt!.sectionData[IELTSSection.reading];
      final examContent = _currentExam!.content[IELTSSection.reading];

      if (sectionData == null || examContent == null) return 0.0;

      final answers = sectionData['answers'] as List<dynamic>;

      // Extract correct answers from exam content
      final List<String> correctAnswers = [];
      for (final part in examContent) {
        final questions = part['questions'] as List<dynamic>;
        for (final question in questions) {
          correctAnswers.add(question['answer']);
        }
      }

      // Extract user answers
      final List<String> userAnswers = answers
          .map((a) => a.toString())
          .toList();

      // Evaluate with the evaluation service
      return _evaluationService.evaluateReadingResponse(
        userAnswers: userAnswers,
        correctAnswers: correctAnswers,
      );
    } catch (e) {
      debugPrint('Error calculating reading score: $e');
      return 0.0;
    }
  }

  /// Calculate writing section score
  Future<double> _calculateWritingScore() async {
    if (_currentAttempt == null || _currentExam == null) return 0.0;

    try {
      final sectionData = _currentAttempt!.sectionData[IELTSSection.writing];
      final examContent = _currentExam!.content[IELTSSection.writing];

      if (sectionData == null || examContent == null) return 0.0;

      final answers = sectionData['answers'] as Map<String, dynamic>;

      // Extract user's writing responses
      final task1Response = answers['task1'] as String;
      final task2Response = answers['task2'] as String;

      // Extract prompts
      final task1Prompt = examContent[0]['description'] as String;
      final task2Prompt = examContent[1]['description'] as String;

      // Create empty criteria objects to be filled by the evaluation service
      final task1Criteria = WritingAssessmentCriteria(
        taskAchievementScore: 0.0,
        coherenceScore: 0.0,
        lexicalResourceScore: 0.0,
        grammaticalRangeScore: 0.0,
        taskAchievementFeedback: '',
        coherenceFeedback: '',
        lexicalResourceFeedback: '',
        grammaticalRangeFeedback: '',
      );

      final task2Criteria = WritingAssessmentCriteria(
        taskAchievementScore: 0.0,
        coherenceScore: 0.0,
        lexicalResourceScore: 0.0,
        grammaticalRangeScore: 0.0,
        taskAchievementFeedback: '',
        coherenceFeedback: '',
        lexicalResourceFeedback: '',
        grammaticalRangeFeedback: '',
      );

      // Evaluate task 1
      final task1Result = await _evaluationService.evaluateWritingResponse(
        prompt: task1Prompt,
        writtenResponse: task1Response,
        criteria: task1Criteria,
      );

      // Evaluate task 2
      final task2Result = await _evaluationService.evaluateWritingResponse(
        prompt: task2Prompt,
        writtenResponse: task2Response,
        criteria: task2Criteria,
      );

      // Task 2 is weighted more heavily than task 1 (usually 2/3 vs 1/3)
      return (task1Result.overallScore + (task2Result.overallScore * 2)) / 3;
    } catch (e) {
      debugPrint('Error calculating writing score: $e');
      return 0.0;
    }
  }

  /// Calculate speaking section score
  Future<double> _calculateSpeakingScore() async {
    if (_currentAttempt == null || _currentExam == null) return 0.0;

    try {
      final sectionData = _currentAttempt!.sectionData[IELTSSection.speaking];
      final examContent = _currentExam!.content[IELTSSection.speaking];

      if (sectionData == null || examContent == null) return 0.0;

      final responses = sectionData['answers'] as Map<String, dynamic>;

      // Create an empty criteria object to be filled by the evaluation service
      final criteria = SpeakingAssessmentCriteria(
        fluencyScore: 0.0,
        lexicalResourceScore: 0.0,
        grammaticalRangeScore: 0.0,
        pronunciationScore: 0.0,
        fluencyFeedback: '',
        lexicalResourceFeedback: '',
        grammaticalRangeFeedback: '',
        pronunciationFeedback: '',
      );

      // Combine all parts for a comprehensive evaluation
      final promptsAndResponses = <Map<String, String>>[];

      // Extract part 1 responses
      if (responses.containsKey('part1') && examContent[0]['type'] == 'part1') {
        final part1Responses = responses['part1'] as Map<String, String>;
        final part1Topics = examContent[0]['topics'] as List<dynamic>;

        for (final topic in part1Topics) {
          final questions = topic['questions'] as List<dynamic>;
          for (final question in questions) {
            final questionId = question.toString().hashCode.toString();
            if (part1Responses.containsKey(questionId)) {
              promptsAndResponses.add({
                'prompt': question.toString(),
                'response': part1Responses[questionId]!,
              });
            }
          }
        }
      }

      // Extract part 2 responses
      if (responses.containsKey('part2') && examContent[1]['type'] == 'part2') {
        final part2Response = responses['part2'] as String;
        final part2Topics = examContent[1]['topics'] as List<dynamic>;

        // Use the first topic for simplicity
        final topic = part2Topics[0];
        final prompt =
            'Part 2: ${topic['description']}\n' +
            (topic['points'] as List<dynamic>).map((p) => '- $p').join('\n');

        promptsAndResponses.add({'prompt': prompt, 'response': part2Response});
      }

      // Extract part 3 responses
      if (responses.containsKey('part3') && examContent[2]['type'] == 'part3') {
        final part3Responses = responses['part3'] as Map<String, String>;
        final part3Topics = examContent[2]['topics'] as List<dynamic>;

        for (final topic in part3Topics) {
          final questions = topic['questions'] as List<dynamic>;
          for (final question in questions) {
            final questionId = question.toString().hashCode.toString();
            if (part3Responses.containsKey(questionId)) {
              promptsAndResponses.add({
                'prompt': question.toString(),
                'response': part3Responses[questionId]!,
              });
            }
          }
        }
      }

      // Evaluate each prompt and response, then average the scores
      double totalScore = 0.0;
      int count = 0;

      for (final item in promptsAndResponses) {
        final result = await _evaluationService.evaluateSpeakingResponse(
          prompt: item['prompt']!,
          audioTranscript: item['response']!,
          criteria: criteria,
        );

        totalScore += result.overallScore;
        count++;
      }

      return count > 0 ? totalScore / count : 0.0;
    } catch (e) {
      debugPrint('Error calculating speaking score: $e');
      return 0.0;
    }
  }
}

/// Extension to provide copying functionality for IELTSAttempt
extension IELTSAttemptCopyWith on IELTSAttempt {
  /// Create a copy with optional new values
  IELTSAttempt copyWith({
    String? id,
    String? examId,
    DateTime? startedAt,
    DateTime? completedAt,
    IELTSExamType? type,
    IELTSBandScore? score,
    Map<IELTSSection, Map<String, dynamic>>? sectionData,
    Map<IELTSSection, bool>? completedSections,
  }) {
    return IELTSAttempt(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      type: type ?? this.type,
      score: score ?? this.score,
      sectionData: sectionData ?? this.sectionData,
      completedSections: completedSections ?? this.completedSections,
    );
  }
}

/// Extension to provide copying functionality for IELTSUserProfile
extension IELTSUserProfileCopyWith on IELTSUserProfile {
  /// Create a copy with optional new values
  IELTSUserProfile copyWith({
    String? userId,
    List<IELTSAttempt>? attempts,
    IELTSBandScore? highestScore,
    IELTSBandScore? targetScore,
    Map<String, dynamic>? preferences,
  }) {
    return IELTSUserProfile(
      userId: userId ?? this.userId,
      attempts: attempts ?? this.attempts,
      highestScore: highestScore ?? this.highestScore,
      targetScore: targetScore ?? this.targetScore,
      preferences: preferences ?? this.preferences,
    );
  }
}
