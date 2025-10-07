/// Models for IELTS Speaking Test
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Duration options for practice tests
enum SpeakingTestDuration {
  short, // 5 minutes
  medium, // 10 minutes
  full, // 14-15 minutes (standard IELTS)
}

extension SpeakingTestDurationProps on SpeakingTestDuration {
  String get displayName {
    switch (this) {
      case SpeakingTestDuration.short:
        return '5 Minutes';
      case SpeakingTestDuration.medium:
        return '10 Minutes';
      case SpeakingTestDuration.full:
        return '15 Minutes';
    }
  }

  int get durationMinutes {
    switch (this) {
      case SpeakingTestDuration.short:
        return 5;
      case SpeakingTestDuration.medium:
        return 10;
      case SpeakingTestDuration.full:
        return 15;
    }
  }

  String get description {
    switch (this) {
      case SpeakingTestDuration.short:
        return 'Quick practice - Part 1 only';
      case SpeakingTestDuration.medium:
        return 'Part 1 & Part 2';
      case SpeakingTestDuration.full:
        return 'Complete test - All 3 parts';
    }
  }
}

/// The three parts of IELTS Speaking Test
enum SpeakingTestPart {
  part1, // Introduction and interview (4-5 minutes)
  part2, // Individual long turn (3-4 minutes)
  part3, // Two-way discussion (4-5 minutes)
}

extension SpeakingTestPartProps on SpeakingTestPart {
  String get displayName {
    switch (this) {
      case SpeakingTestPart.part1:
        return 'Part 1: Introduction & Interview';
      case SpeakingTestPart.part2:
        return 'Part 2: Individual Long Turn';
      case SpeakingTestPart.part3:
        return 'Part 3: Two-way Discussion';
    }
  }

  String get description {
    switch (this) {
      case SpeakingTestPart.part1:
        return 'General questions about yourself and familiar topics';
      case SpeakingTestPart.part2:
        return 'Speak for 1-2 minutes on a given topic';
      case SpeakingTestPart.part3:
        return 'Discuss abstract ideas related to Part 2 topic';
    }
  }

  int get durationMinutes {
    switch (this) {
      case SpeakingTestPart.part1:
        return 5;
      case SpeakingTestPart.part2:
        return 4;
      case SpeakingTestPart.part3:
        return 5;
    }
  }
}

/// A single question in the speaking test
class SpeakingQuestion {
  final String id;
  final SpeakingTestPart part;
  final String question;
  final List<String>? bulletPoints; // For Part 2 cue card
  final int? preparationTimeSeconds; // For Part 2 (1 minute)
  final int? speakingTimeSeconds; // Expected speaking duration

  SpeakingQuestion({
    String? id,
    required this.part,
    required this.question,
    this.bulletPoints,
    this.preparationTimeSeconds,
    this.speakingTimeSeconds,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'part': part.name,
      'question': question,
      'bulletPoints': bulletPoints,
      'preparationTimeSeconds': preparationTimeSeconds,
      'speakingTimeSeconds': speakingTimeSeconds,
    };
  }

  factory SpeakingQuestion.fromJson(Map<String, dynamic> json) {
    return SpeakingQuestion(
      id: json['id'],
      part: SpeakingTestPart.values.firstWhere((e) => e.name == json['part']),
      question: json['question'],
      bulletPoints: json['bulletPoints'] != null
          ? List<String>.from(json['bulletPoints'])
          : null,
      preparationTimeSeconds: json['preparationTimeSeconds'],
      speakingTimeSeconds: json['speakingTimeSeconds'],
    );
  }
}

/// User's response to a question
class SpeakingResponse {
  final String questionId;
  final String transcribedText;
  final int durationSeconds;
  final DateTime timestamp;
  final String? audioPath; // Optional: path to recorded audio

  SpeakingResponse({
    required this.questionId,
    required this.transcribedText,
    required this.durationSeconds,
    required this.timestamp,
    this.audioPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'transcribedText': transcribedText,
      'durationSeconds': durationSeconds,
      'timestamp': timestamp.toIso8601String(),
      'audioPath': audioPath,
    };
  }

  factory SpeakingResponse.fromJson(Map<String, dynamic> json) {
    return SpeakingResponse(
      questionId: json['questionId'],
      transcribedText: json['transcribedText'],
      durationSeconds: json['durationSeconds'],
      timestamp: DateTime.parse(json['timestamp']),
      audioPath: json['audioPath'],
    );
  }
}

/// IELTS Speaking evaluation criteria
class SpeakingCriteria {
  final double fluencyAndCoherence; // 0-9
  final double lexicalResource; // 0-9 (vocabulary)
  final double grammaticalRangeAndAccuracy; // 0-9
  final double pronunciation; // 0-9

  SpeakingCriteria({
    required this.fluencyAndCoherence,
    required this.lexicalResource,
    required this.grammaticalRangeAndAccuracy,
    required this.pronunciation,
  });

  /// Calculate overall speaking band score (average of four criteria)
  double get overallBand {
    final sum =
        fluencyAndCoherence +
        lexicalResource +
        grammaticalRangeAndAccuracy +
        pronunciation;
    return (sum / 4).roundToDouble();
  }

  Map<String, dynamic> toJson() {
    return {
      'fluencyAndCoherence': fluencyAndCoherence,
      'lexicalResource': lexicalResource,
      'grammaticalRangeAndAccuracy': grammaticalRangeAndAccuracy,
      'pronunciation': pronunciation,
      'overallBand': overallBand,
    };
  }

  factory SpeakingCriteria.fromJson(Map<String, dynamic> json) {
    return SpeakingCriteria(
      fluencyAndCoherence: json['fluencyAndCoherence'].toDouble(),
      lexicalResource: json['lexicalResource'].toDouble(),
      grammaticalRangeAndAccuracy: json['grammaticalRangeAndAccuracy']
          .toDouble(),
      pronunciation: json['pronunciation'].toDouble(),
    );
  }
}

/// Detailed feedback for the user
class SpeakingFeedback {
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> improvementTips;
  final Map<String, String> specificErrors; // error type -> example
  final String? overallComment;

  SpeakingFeedback({
    required this.strengths,
    required this.weaknesses,
    required this.improvementTips,
    this.specificErrors = const {},
    this.overallComment,
  });

  Map<String, dynamic> toJson() {
    return {
      'strengths': strengths,
      'weaknesses': weaknesses,
      'improvementTips': improvementTips,
      'specificErrors': specificErrors,
      'overallComment': overallComment,
    };
  }

  factory SpeakingFeedback.fromJson(Map<String, dynamic> json) {
    return SpeakingFeedback(
      strengths: List<String>.from(json['strengths']),
      weaknesses: List<String>.from(json['weaknesses']),
      improvementTips: List<String>.from(json['improvementTips']),
      specificErrors: Map<String, String>.from(json['specificErrors'] ?? {}),
      overallComment: json['overallComment'],
    );
  }
}

/// Complete evaluation of the speaking test
class SpeakingTestEvaluation {
  final String testSessionId;
  final SpeakingCriteria criteria;
  final SpeakingFeedback feedback;
  final DateTime evaluatedAt;
  final Map<String, dynamic>? partScores; // Scores for each part

  SpeakingTestEvaluation({
    required this.testSessionId,
    required this.criteria,
    required this.feedback,
    required this.evaluatedAt,
    this.partScores,
  });

  Map<String, dynamic> toJson() {
    return {
      'testSessionId': testSessionId,
      'criteria': criteria.toJson(),
      'feedback': feedback.toJson(),
      'evaluatedAt': evaluatedAt.toIso8601String(),
      'partScores': partScores,
    };
  }

  factory SpeakingTestEvaluation.fromJson(Map<String, dynamic> json) {
    return SpeakingTestEvaluation(
      testSessionId: json['testSessionId'],
      criteria: SpeakingCriteria.fromJson(json['criteria']),
      feedback: SpeakingFeedback.fromJson(json['feedback']),
      evaluatedAt: DateTime.parse(json['evaluatedAt']),
      partScores: json['partScores'],
    );
  }
}

/// A complete speaking test session
class SpeakingTestSession {
  final String id;
  final SpeakingTestDuration duration;
  final DateTime startedAt;
  DateTime? completedAt;
  final List<SpeakingQuestion> questions;
  final Map<String, SpeakingResponse> responses; // questionId -> response
  SpeakingTestEvaluation? evaluation;
  SpeakingTestPart currentPart;
  int currentQuestionIndex;

  SpeakingTestSession({
    String? id,
    required this.duration,
    required this.startedAt,
    this.completedAt,
    required this.questions,
    Map<String, SpeakingResponse>? responses,
    this.evaluation,
    this.currentPart = SpeakingTestPart.part1,
    this.currentQuestionIndex = 0,
  }) : id = id ?? _uuid.v4(),
       responses = responses ?? {};

  /// Check if test is completed
  bool get isCompleted => completedAt != null;

  /// Get current question
  SpeakingQuestion? get currentQuestion {
    if (currentQuestionIndex < questions.length) {
      return questions[currentQuestionIndex];
    }
    return null;
  }

  /// Move to next question
  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
      // Update current part based on question
      currentPart = questions[currentQuestionIndex].part;
    }
  }

  /// Add response to current question
  void addResponse(SpeakingResponse response) {
    responses[response.questionId] = response;
  }

  /// Calculate test progress (0.0 to 1.0)
  double get progress {
    if (questions.isEmpty) return 0.0;
    return currentQuestionIndex / questions.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'duration': duration.name,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'responses': responses.map((k, v) => MapEntry(k, v.toJson())),
      'evaluation': evaluation?.toJson(),
      'currentPart': currentPart.name,
      'currentQuestionIndex': currentQuestionIndex,
    };
  }

  factory SpeakingTestSession.fromJson(Map<String, dynamic> json) {
    return SpeakingTestSession(
      id: json['id'],
      duration: SpeakingTestDuration.values.firstWhere(
        (e) => e.name == json['duration'],
      ),
      startedAt: DateTime.parse(json['startedAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      questions: (json['questions'] as List)
          .map((q) => SpeakingQuestion.fromJson(q))
          .toList(),
      responses: (json['responses'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, SpeakingResponse.fromJson(v)),
      ),
      evaluation: json['evaluation'] != null
          ? SpeakingTestEvaluation.fromJson(json['evaluation'])
          : null,
      currentPart: SpeakingTestPart.values.firstWhere(
        (e) => e.name == json['currentPart'],
      ),
      currentQuestionIndex: json['currentQuestionIndex'],
    );
  }
}

/// Extension for rounding to nearest half
extension DoubleRounding on double {
  double roundToNearestHalf() {
    return (this * 2).round() / 2;
  }
}
