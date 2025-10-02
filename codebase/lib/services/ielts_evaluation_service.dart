import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/ielts_models.dart';

/// IELTS evaluation service extending the existing AI backend
class IELTSEvaluationService {
  final String? geminiApiKey;

  const IELTSEvaluationService({this.geminiApiKey});

  /// Factory constructor that uses the API key from AppConfig
  factory IELTSEvaluationService.withDefaultKey() {
    return IELTSEvaluationService(geminiApiKey: AppConfig.activeGeminiApiKey);
  }

  /// Evaluates a speaking response for an IELTS exam
  /// Returns a SpeakingAssessmentResult with detailed scoring and feedback
  Future<SpeakingAssessmentResult> evaluateSpeakingResponse({
    required String prompt,
    required String audioTranscript,
    required SpeakingAssessmentCriteria criteria,
  }) async {
    if (geminiApiKey == null) {
      throw Exception('Gemini API key is not configured');
    }

    final evaluationPrompt = _generateSpeakingEvaluationPrompt(
      prompt: prompt,
      audioTranscript: audioTranscript,
      criteria: criteria,
    );

    final response = await _sendGeminiRequest(evaluationPrompt);
    return _parseSpeakingAssessmentResult(response, criteria);
  }

  /// Evaluates a writing response for an IELTS exam
  /// Returns a WritingAssessmentResult with detailed scoring and feedback
  Future<WritingAssessmentResult> evaluateWritingResponse({
    required String prompt,
    required String writtenResponse,
    required WritingAssessmentCriteria criteria,
  }) async {
    if (geminiApiKey == null) {
      throw Exception('Gemini API key is not configured');
    }

    final evaluationPrompt = _generateWritingEvaluationPrompt(
      prompt: prompt,
      writtenResponse: writtenResponse,
      criteria: criteria,
    );

    final response = await _sendGeminiRequest(evaluationPrompt);
    return _parseWritingAssessmentResult(response, criteria);
  }

  /// Evaluates a reading response in an IELTS exam
  /// Uses objective scoring based on correct answers
  double evaluateReadingResponse({
    required List<String> userAnswers,
    required List<String> correctAnswers,
  }) {
    if (userAnswers.length != correctAnswers.length) {
      throw ArgumentError(
        'User answers and correct answers must have the same length',
      );
    }

    int correctCount = 0;
    for (int i = 0; i < userAnswers.length; i++) {
      if (userAnswers[i].trim().toLowerCase() ==
          correctAnswers[i].trim().toLowerCase()) {
        correctCount++;
      }
    }

    // Convert to IELTS band score based on percentage correct
    return _convertToIELTSBandScore(correctCount / correctAnswers.length);
  }

  /// Evaluates a listening response in an IELTS exam
  /// Uses objective scoring based on correct answers
  double evaluateListeningResponse({
    required List<String> userAnswers,
    required List<String> correctAnswers,
  }) {
    if (userAnswers.length != correctAnswers.length) {
      throw ArgumentError(
        'User answers and correct answers must have the same length',
      );
    }

    int correctCount = 0;
    for (int i = 0; i < userAnswers.length; i++) {
      if (userAnswers[i].trim().toLowerCase() ==
          correctAnswers[i].trim().toLowerCase()) {
        correctCount++;
      }
    }

    // Convert to IELTS band score based on percentage correct
    return _convertToIELTSBandScore(correctCount / correctAnswers.length);
  }

  /// Helper method to send a request to the Gemini API
  Future<String> _sendGeminiRequest(String prompt) async {
    if (geminiApiKey == null) {
      throw Exception('Gemini API key is not configured');
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$geminiApiKey',
    );

    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.2,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 8192,
      },
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get response from Gemini API: ${response.body}',
      );
    }

    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['candidates'][0]['content']['parts'][0]['text'];
  }

  /// Converts a percentage to an IELTS band score
  double _convertToIELTSBandScore(double percentage) {
    // IELTS conversion table (approximate)
    if (percentage >= 0.98) return 9.0;
    if (percentage >= 0.95) return 8.5;
    if (percentage >= 0.90) return 8.0;
    if (percentage >= 0.85) return 7.5;
    if (percentage >= 0.80) return 7.0;
    if (percentage >= 0.75) return 6.5;
    if (percentage >= 0.70) return 6.0;
    if (percentage >= 0.65) return 5.5;
    if (percentage >= 0.60) return 5.0;
    if (percentage >= 0.55) return 4.5;
    if (percentage >= 0.50) return 4.0;
    if (percentage >= 0.40) return 3.5;
    if (percentage >= 0.30) return 3.0;
    if (percentage >= 0.20) return 2.5;
    if (percentage >= 0.10) return 2.0;
    if (percentage >= 0.05) return 1.5;
    return 1.0;
  }

  /// Generates a prompt for speaking evaluation
  String _generateSpeakingEvaluationPrompt({
    required String prompt,
    required String audioTranscript,
    required SpeakingAssessmentCriteria criteria,
  }) {
    return '''
You are an IELTS speaking examiner with extensive experience evaluating candidates. 
You are assessing a candidate's speaking response based on the official IELTS speaking assessment criteria.

The candidate was given the following prompt:
$prompt

The candidate's transcribed response is:
$audioTranscript

Please evaluate this response using the IELTS speaking assessment criteria:

1. Fluency and Coherence (score from 0 to 9)
2. Lexical Resource (score from 0 to 9)
3. Grammatical Range and Accuracy (score from 0 to 9)
4. Pronunciation (score from 0 to 9)

For each criterion, provide:
- A band score (from 0 to 9, with 0.5 increments)
- Detailed feedback with specific examples from the response
- Strengths and weaknesses

Then provide:
- An overall band score (average of the four criteria, rounded to the nearest 0.5)
- Overall feedback summary
- 3-5 key strengths
- 3-5 areas for improvement
- Suggested practice activities

Format your response as a valid JSON object with the following structure:
{
  "fluencyScore": 0.0,
  "lexicalResourceScore": 0.0,
  "grammaticalRangeScore": 0.0,
  "pronunciationScore": 0.0,
  "fluencyFeedback": "",
  "lexicalResourceFeedback": "",
  "grammaticalRangeFeedback": "",
  "pronunciationFeedback": "",
  "overallScore": 0.0,
  "overallFeedback": "",
  "strengths": ["", "", ""],
  "areasForImprovement": ["", "", ""],
  "suggestedPractice": ["", "", ""]
}
''';
  }

  /// Generates a prompt for writing evaluation
  String _generateWritingEvaluationPrompt({
    required String prompt,
    required String writtenResponse,
    required WritingAssessmentCriteria criteria,
  }) {
    return '''
You are an IELTS writing examiner with extensive experience evaluating candidates. 
You are assessing a candidate's writing response based on the official IELTS writing assessment criteria.

The candidate was given the following prompt:
$prompt

The candidate's written response is:
$writtenResponse

Please evaluate this response using the IELTS writing assessment criteria:

1. Task Achievement/Task Response (score from 0 to 9)
2. Coherence and Cohesion (score from 0 to 9)
3. Lexical Resource (score from 0 to 9)
4. Grammatical Range and Accuracy (score from 0 to 9)

For each criterion, provide:
- A band score (from 0 to 9, with 0.5 increments)
- Detailed feedback with specific examples from the response
- Strengths and weaknesses

Then provide:
- An overall band score (average of the four criteria, rounded to the nearest 0.5)
- Overall feedback summary
- 3-5 key strengths
- 3-5 areas for improvement
- Suggested practice activities
- An improved version of the response (if below band 7)

Format your response as a valid JSON object with the following structure:
{
  "taskAchievementScore": 0.0,
  "coherenceScore": 0.0,
  "lexicalResourceScore": 0.0,
  "grammaticalRangeScore": 0.0,
  "taskAchievementFeedback": "",
  "coherenceFeedback": "",
  "lexicalResourceFeedback": "",
  "grammaticalRangeFeedback": "",
  "overallScore": 0.0,
  "overallFeedback": "",
  "strengths": ["", "", ""],
  "areasForImprovement": ["", "", ""],
  "suggestedPractice": ["", "", ""],
  "improvedVersion": ""
}
''';
  }

  /// Parses the response from the AI into a SpeakingAssessmentResult
  SpeakingAssessmentResult _parseSpeakingAssessmentResult(
    String response,
    SpeakingAssessmentCriteria criteria,
  ) {
    try {
      final jsonResponse = jsonDecode(response);

      final speakingCriteria = SpeakingAssessmentCriteria(
        fluencyScore: jsonResponse['fluencyScore'] as double,
        lexicalResourceScore: jsonResponse['lexicalResourceScore'] as double,
        grammaticalRangeScore: jsonResponse['grammaticalRangeScore'] as double,
        pronunciationScore: jsonResponse['pronunciationScore'] as double,
        fluencyFeedback: jsonResponse['fluencyFeedback'] as String,
        lexicalResourceFeedback:
            jsonResponse['lexicalResourceFeedback'] as String,
        grammaticalRangeFeedback:
            jsonResponse['grammaticalRangeFeedback'] as String,
        pronunciationFeedback: jsonResponse['pronunciationFeedback'] as String,
      );

      return SpeakingAssessmentResult(
        criteria: speakingCriteria,
        overallScore: jsonResponse['overallScore'] as double,
        overallFeedback: jsonResponse['overallFeedback'] as String,
        strengths: (jsonResponse['strengths'] as List).cast<String>(),
        areasForImprovement: (jsonResponse['areasForImprovement'] as List)
            .cast<String>(),
        suggestedPractice: (jsonResponse['suggestedPractice'] as List)
            .cast<String>(),
      );
    } catch (e) {
      throw Exception('Failed to parse speaking assessment result: $e');
    }
  }

  /// Parses the response from the AI into a WritingAssessmentResult
  WritingAssessmentResult _parseWritingAssessmentResult(
    String response,
    WritingAssessmentCriteria criteria,
  ) {
    try {
      final jsonResponse = jsonDecode(response);

      final writingCriteria = WritingAssessmentCriteria(
        taskAchievementScore: jsonResponse['taskAchievementScore'] as double,
        coherenceScore: jsonResponse['coherenceScore'] as double,
        lexicalResourceScore: jsonResponse['lexicalResourceScore'] as double,
        grammaticalRangeScore: jsonResponse['grammaticalRangeScore'] as double,
        taskAchievementFeedback:
            jsonResponse['taskAchievementFeedback'] as String,
        coherenceFeedback: jsonResponse['coherenceFeedback'] as String,
        lexicalResourceFeedback:
            jsonResponse['lexicalResourceFeedback'] as String,
        grammaticalRangeFeedback:
            jsonResponse['grammaticalRangeFeedback'] as String,
      );

      return WritingAssessmentResult(
        criteria: writingCriteria,
        overallScore: jsonResponse['overallScore'] as double,
        overallFeedback: jsonResponse['overallFeedback'] as String,
        strengths: (jsonResponse['strengths'] as List).cast<String>(),
        areasForImprovement: (jsonResponse['areasForImprovement'] as List)
            .cast<String>(),
        suggestedPractice: (jsonResponse['suggestedPractice'] as List)
            .cast<String>(),
        improvedVersion: jsonResponse['improvedVersion'] as String?,
      );
    } catch (e) {
      throw Exception('Failed to parse writing assessment result: $e');
    }
  }
}
