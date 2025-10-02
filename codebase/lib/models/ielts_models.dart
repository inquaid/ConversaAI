// Models for IELTS exam structure and scoring

import 'dart:convert';

/// Enum representing the four sections of the IELTS exam
enum IELTSSection { listening, reading, writing, speaking }

/// Extension to add properties to IELTSSection enum
extension IELTSSectionProps on IELTSSection {
  String get name {
    switch (this) {
      case IELTSSection.listening:
        return 'Listening';
      case IELTSSection.reading:
        return 'Reading';
      case IELTSSection.writing:
        return 'Writing';
      case IELTSSection.speaking:
        return 'Speaking';
    }
  }

  int get durationMinutes {
    switch (this) {
      case IELTSSection.listening:
        return 30; // 30 minutes for listening
      case IELTSSection.reading:
        return 60; // 60 minutes for reading
      case IELTSSection.writing:
        return 60; // 60 minutes for writing
      case IELTSSection.speaking:
        return 14; // 14 minutes for speaking
    }
  }
}

/// Enum representing academic vs general training modules
enum IELTSExamType { academic, generalTraining }

/// Extension to add properties to IELTSExamType enum
extension IELTSExamTypeProps on IELTSExamType {
  String get name {
    switch (this) {
      case IELTSExamType.academic:
        return 'Academic';
      case IELTSExamType.generalTraining:
        return 'General Training';
    }
  }
}

/// Class representing the IELTS Band Score (1-9 scale with 0.5 increments)
class IELTSBandScore {
  final double overall;
  final double? listening;
  final double? reading;
  final double? writing;
  final double? speaking;

  // Scores range from 0.0 to 9.0 with 0.5 increments
  IELTSBandScore({
    required this.overall,
    this.listening,
    this.reading,
    this.writing,
    this.speaking,
  }) {
    if (overall < 0 || overall > 9) {
      throw ArgumentError('Band scores must be between 0 and 9');
    }
  }

  /// Create from individual section scores
  factory IELTSBandScore.fromSections({
    required double listening,
    required double reading,
    required double writing,
    required double speaking,
  }) {
    // Calculate overall score by averaging the four sections
    final overall = ((listening + reading + writing + speaking) / 4)
        .roundToNearestHalf();

    return IELTSBandScore(
      overall: overall,
      listening: listening,
      reading: reading,
      writing: writing,
      speaking: speaking,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'overall': overall,
      'listening': listening,
      'reading': reading,
      'writing': writing,
      'speaking': speaking,
    };
  }

  /// Create from JSON
  factory IELTSBandScore.fromJson(Map<String, dynamic> json) {
    return IELTSBandScore(
      overall: json['overall'] as double,
      listening: json['listening'] as double?,
      reading: json['reading'] as double?,
      writing: json['writing'] as double?,
      speaking: json['speaking'] as double?,
    );
  }
}

/// Class representing a single IELTS exam
class IELTSExam {
  final String id;
  final String title;
  final IELTSExamType type;
  final Map<IELTSSection, List<dynamic>> content;
  final DateTime createdAt;
  final bool isPractice; // Full test or practice section
  final bool isOfficial; // Official test or community created

  IELTSExam({
    required this.id,
    required this.title,
    required this.type,
    required this.content,
    required this.createdAt,
    this.isPractice = true,
    this.isOfficial = false,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.index,
      'content': content.map(
        (key, value) => MapEntry(key.index.toString(), jsonEncode(value)),
      ),
      'createdAt': createdAt.toIso8601String(),
      'isPractice': isPractice,
      'isOfficial': isOfficial,
    };
  }

  /// Create from JSON
  factory IELTSExam.fromJson(Map<String, dynamic> json) {
    final contentMap = <IELTSSection, List<dynamic>>{};
    (json['content'] as Map<String, dynamic>).forEach((key, value) {
      final section = IELTSSection.values[int.parse(key)];
      contentMap[section] = jsonDecode(value) as List<dynamic>;
    });

    return IELTSExam(
      id: json['id'] as String,
      title: json['title'] as String,
      type: IELTSExamType.values[json['type'] as int],
      content: contentMap,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isPractice: json['isPractice'] as bool,
      isOfficial: json['isOfficial'] as bool,
    );
  }
}

/// Class representing a user's attempt at an IELTS exam or section
class IELTSAttempt {
  final String id;
  final String examId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final IELTSExamType type;
  final IELTSBandScore? score;
  final Map<IELTSSection, Map<String, dynamic>>
  sectionData; // Section specific data
  final Map<IELTSSection, bool> completedSections;

  IELTSAttempt({
    required this.id,
    required this.examId,
    required this.startedAt,
    this.completedAt,
    required this.type,
    this.score,
    required this.sectionData,
    required this.completedSections,
  });

  /// Check if the entire attempt is completed
  bool get isCompleted => completedAt != null;

  /// Calculate time spent
  Duration get timeSpent {
    if (completedAt != null) {
      return completedAt!.difference(startedAt);
    }
    return DateTime.now().difference(startedAt);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'examId': examId,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'type': type.index,
      'score': score?.toJson(),
      'sectionData': sectionData.map(
        (key, value) => MapEntry(key.index.toString(), jsonEncode(value)),
      ),
      'completedSections': completedSections.map(
        (key, value) => MapEntry(key.index.toString(), value),
      ),
    };
  }

  /// Create from JSON
  factory IELTSAttempt.fromJson(Map<String, dynamic> json) {
    final sectionDataMap = <IELTSSection, Map<String, dynamic>>{};
    (json['sectionData'] as Map<String, dynamic>).forEach((key, value) {
      final section = IELTSSection.values[int.parse(key)];
      sectionDataMap[section] = jsonDecode(value) as Map<String, dynamic>;
    });

    final completedSectionsMap = <IELTSSection, bool>{};
    (json['completedSections'] as Map<String, dynamic>).forEach((key, value) {
      final section = IELTSSection.values[int.parse(key)];
      completedSectionsMap[section] = value as bool;
    });

    return IELTSAttempt(
      id: json['id'] as String,
      examId: json['examId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      type: IELTSExamType.values[json['type'] as int],
      score: json['score'] != null
          ? IELTSBandScore.fromJson(json['score'] as Map<String, dynamic>)
          : null,
      sectionData: sectionDataMap,
      completedSections: completedSectionsMap,
    );
  }
}

/// Class representing a user's IELTS profile with historical performance
class IELTSUserProfile {
  final String userId;
  final List<IELTSAttempt> attempts;
  final IELTSBandScore? highestScore;
  final IELTSBandScore? targetScore;
  final Map<String, dynamic>? preferences;

  IELTSUserProfile({
    required this.userId,
    required this.attempts,
    this.highestScore,
    this.targetScore,
    this.preferences,
  });

  /// Calculate highest score from attempts
  IELTSBandScore calculateHighestScore() {
    if (attempts.isEmpty) {
      return IELTSBandScore(overall: 0.0);
    }

    // Get attempts with scores
    final scoredAttempts = attempts
        .where((attempt) => attempt.score != null)
        .map((attempt) => attempt.score!)
        .toList();

    if (scoredAttempts.isEmpty) {
      return IELTSBandScore(overall: 0.0);
    }

    // Find highest section scores
    double highestListening = 0.0;
    double highestReading = 0.0;
    double highestWriting = 0.0;
    double highestSpeaking = 0.0;
    double highestOverall = 0.0;

    for (final score in scoredAttempts) {
      if (score.listening != null && score.listening! > highestListening) {
        highestListening = score.listening!;
      }
      if (score.reading != null && score.reading! > highestReading) {
        highestReading = score.reading!;
      }
      if (score.writing != null && score.writing! > highestWriting) {
        highestWriting = score.writing!;
      }
      if (score.speaking != null && score.speaking! > highestSpeaking) {
        highestSpeaking = score.speaking!;
      }
      if (score.overall > highestOverall) {
        highestOverall = score.overall;
      }
    }

    return IELTSBandScore(
      overall: highestOverall,
      listening: highestListening > 0 ? highestListening : null,
      reading: highestReading > 0 ? highestReading : null,
      writing: highestWriting > 0 ? highestWriting : null,
      speaking: highestSpeaking > 0 ? highestSpeaking : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'attempts': attempts.map((attempt) => attempt.toJson()).toList(),
      'highestScore': highestScore?.toJson(),
      'targetScore': targetScore?.toJson(),
      'preferences': preferences,
    };
  }

  /// Create from JSON
  factory IELTSUserProfile.fromJson(Map<String, dynamic> json) {
    final attemptsList = (json['attempts'] as List)
        .map((item) => IELTSAttempt.fromJson(item as Map<String, dynamic>))
        .toList();

    return IELTSUserProfile(
      userId: json['userId'] as String,
      attempts: attemptsList,
      highestScore: json['highestScore'] != null
          ? IELTSBandScore.fromJson(
              json['highestScore'] as Map<String, dynamic>,
            )
          : null,
      targetScore: json['targetScore'] != null
          ? IELTSBandScore.fromJson(json['targetScore'] as Map<String, dynamic>)
          : null,
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }
}

/// Extension for double to round to nearest 0.5
extension RoundHalf on double {
  double roundToNearestHalf() {
    return (this * 2).round() / 2;
  }
}

/// Speaking assessment criteria based on IELTS rubric
class SpeakingAssessmentCriteria {
  final double fluencyScore;
  final double lexicalResourceScore;
  final double grammaticalRangeScore;
  final double pronunciationScore;
  final String fluencyFeedback;
  final String lexicalResourceFeedback;
  final String grammaticalRangeFeedback;
  final String pronunciationFeedback;

  SpeakingAssessmentCriteria({
    required this.fluencyScore,
    required this.lexicalResourceScore,
    required this.grammaticalRangeScore,
    required this.pronunciationScore,
    required this.fluencyFeedback,
    required this.lexicalResourceFeedback,
    required this.grammaticalRangeFeedback,
    required this.pronunciationFeedback,
  });

  /// Calculate overall speaking score
  double get overallScore {
    return ((fluencyScore +
                lexicalResourceScore +
                grammaticalRangeScore +
                pronunciationScore) /
            4)
        .roundToNearestHalf();
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'fluencyScore': fluencyScore,
      'lexicalResourceScore': lexicalResourceScore,
      'grammaticalRangeScore': grammaticalRangeScore,
      'pronunciationScore': pronunciationScore,
      'fluencyFeedback': fluencyFeedback,
      'lexicalResourceFeedback': lexicalResourceFeedback,
      'grammaticalRangeFeedback': grammaticalRangeFeedback,
      'pronunciationFeedback': pronunciationFeedback,
    };
  }

  /// Create from JSON
  factory SpeakingAssessmentCriteria.fromJson(Map<String, dynamic> json) {
    return SpeakingAssessmentCriteria(
      fluencyScore: json['fluencyScore'] as double,
      lexicalResourceScore: json['lexicalResourceScore'] as double,
      grammaticalRangeScore: json['grammaticalRangeScore'] as double,
      pronunciationScore: json['pronunciationScore'] as double,
      fluencyFeedback: json['fluencyFeedback'] as String,
      lexicalResourceFeedback: json['lexicalResourceFeedback'] as String,
      grammaticalRangeFeedback: json['grammaticalRangeFeedback'] as String,
      pronunciationFeedback: json['pronunciationFeedback'] as String,
    );
  }
}

/// Writing assessment criteria based on IELTS rubric
class WritingAssessmentCriteria {
  final double taskAchievementScore;
  final double coherenceScore;
  final double lexicalResourceScore;
  final double grammaticalRangeScore;
  final String taskAchievementFeedback;
  final String coherenceFeedback;
  final String lexicalResourceFeedback;
  final String grammaticalRangeFeedback;

  WritingAssessmentCriteria({
    required this.taskAchievementScore,
    required this.coherenceScore,
    required this.lexicalResourceScore,
    required this.grammaticalRangeScore,
    required this.taskAchievementFeedback,
    required this.coherenceFeedback,
    required this.lexicalResourceFeedback,
    required this.grammaticalRangeFeedback,
  });

  /// Calculate overall writing score
  double get overallScore {
    return ((taskAchievementScore +
                coherenceScore +
                lexicalResourceScore +
                grammaticalRangeScore) /
            4)
        .roundToNearestHalf();
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'taskAchievementScore': taskAchievementScore,
      'coherenceScore': coherenceScore,
      'lexicalResourceScore': lexicalResourceScore,
      'grammaticalRangeScore': grammaticalRangeScore,
      'taskAchievementFeedback': taskAchievementFeedback,
      'coherenceFeedback': coherenceFeedback,
      'lexicalResourceFeedback': lexicalResourceFeedback,
      'grammaticalRangeFeedback': grammaticalRangeFeedback,
    };
  }

  /// Create from JSON
  factory WritingAssessmentCriteria.fromJson(Map<String, dynamic> json) {
    return WritingAssessmentCriteria(
      taskAchievementScore: json['taskAchievementScore'] as double,
      coherenceScore: json['coherenceScore'] as double,
      lexicalResourceScore: json['lexicalResourceScore'] as double,
      grammaticalRangeScore: json['grammaticalRangeScore'] as double,
      taskAchievementFeedback: json['taskAchievementFeedback'] as String,
      coherenceFeedback: json['coherenceFeedback'] as String,
      lexicalResourceFeedback: json['lexicalResourceFeedback'] as String,
      grammaticalRangeFeedback: json['grammaticalRangeFeedback'] as String,
    );
  }
}

/// Class to store the results of a speaking assessment
class SpeakingAssessmentResult {
  final SpeakingAssessmentCriteria criteria;
  final double overallScore;
  final String overallFeedback;
  final List<String>? strengths;
  final List<String>? areasForImprovement;
  final List<String>? suggestedPractice;

  SpeakingAssessmentResult({
    required this.criteria,
    required this.overallScore,
    required this.overallFeedback,
    this.strengths,
    this.areasForImprovement,
    this.suggestedPractice,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'criteria': criteria.toJson(),
      'overallScore': overallScore,
      'overallFeedback': overallFeedback,
      'strengths': strengths,
      'areasForImprovement': areasForImprovement,
      'suggestedPractice': suggestedPractice,
    };
  }

  /// Create from JSON
  factory SpeakingAssessmentResult.fromJson(Map<String, dynamic> json) {
    return SpeakingAssessmentResult(
      criteria: SpeakingAssessmentCriteria.fromJson(
        json['criteria'] as Map<String, dynamic>,
      ),
      overallScore: json['overallScore'] as double,
      overallFeedback: json['overallFeedback'] as String,
      strengths: json['strengths'] != null
          ? (json['strengths'] as List).cast<String>()
          : null,
      areasForImprovement: json['areasForImprovement'] != null
          ? (json['areasForImprovement'] as List).cast<String>()
          : null,
      suggestedPractice: json['suggestedPractice'] != null
          ? (json['suggestedPractice'] as List).cast<String>()
          : null,
    );
  }
}

/// Class to store the results of a writing assessment
class WritingAssessmentResult {
  final WritingAssessmentCriteria criteria;
  final double overallScore;
  final String overallFeedback;
  final List<String>? strengths;
  final List<String>? areasForImprovement;
  final List<String>? suggestedPractice;
  final String? improvedVersion;

  WritingAssessmentResult({
    required this.criteria,
    required this.overallScore,
    required this.overallFeedback,
    this.strengths,
    this.areasForImprovement,
    this.suggestedPractice,
    this.improvedVersion,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'criteria': criteria.toJson(),
      'overallScore': overallScore,
      'overallFeedback': overallFeedback,
      'strengths': strengths,
      'areasForImprovement': areasForImprovement,
      'suggestedPractice': suggestedPractice,
      'improvedVersion': improvedVersion,
    };
  }

  /// Create from JSON
  factory WritingAssessmentResult.fromJson(Map<String, dynamic> json) {
    return WritingAssessmentResult(
      criteria: WritingAssessmentCriteria.fromJson(
        json['criteria'] as Map<String, dynamic>,
      ),
      overallScore: json['overallScore'] as double,
      overallFeedback: json['overallFeedback'] as String,
      strengths: json['strengths'] != null
          ? (json['strengths'] as List).cast<String>()
          : null,
      areasForImprovement: json['areasForImprovement'] != null
          ? (json['areasForImprovement'] as List).cast<String>()
          : null,
      suggestedPractice: json['suggestedPractice'] != null
          ? (json['suggestedPractice'] as List).cast<String>()
          : null,
      improvedVersion: json['improvedVersion'] as String?,
    );
  }
}
