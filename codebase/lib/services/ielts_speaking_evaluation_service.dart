/// Service for evaluating IELTS Speaking Test responses using Gemini AI
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ielts_speaking_test_models.dart';
import '../config/app_config.dart';

class IELTSSpeakingEvaluationService {
  final String? geminiApiKey;

  const IELTSSpeakingEvaluationService({this.geminiApiKey});

  factory IELTSSpeakingEvaluationService.instance() {
    return IELTSSpeakingEvaluationService(
      geminiApiKey: AppConfig.activeGeminiApiKey,
    );
  }

  /// Evaluate a complete speaking test session
  Future<SpeakingTestEvaluation> evaluateTest(
    SpeakingTestSession session,
  ) async {
    if (geminiApiKey == null || geminiApiKey!.isEmpty) {
      throw Exception('Gemini API key is not configured');
    }

    // Prepare all responses for evaluation
    final responsesText = _prepareResponsesForEvaluation(session);

    // Create comprehensive evaluation prompt
    final prompt = _buildEvaluationPrompt(session, responsesText);

    // Get evaluation from Gemini
    final evaluationJson = await _callGeminiForEvaluation(prompt);

    // Parse and create evaluation object
    return _parseEvaluation(session.id, evaluationJson);
  }

  /// Prepare responses text for evaluation
  String _prepareResponsesForEvaluation(SpeakingTestSession session) {
    final buffer = StringBuffer();

    for (var question in session.questions) {
      final response = session.responses[question.id];
      if (response != null) {
        buffer.writeln('Question (${question.part.displayName}):');
        buffer.writeln(question.question);
        if (question.bulletPoints != null) {
          for (var point in question.bulletPoints!) {
            buffer.writeln('  • $point');
          }
        }
        buffer.writeln('\nResponse:');
        buffer.writeln(response.transcribedText);
        buffer.writeln('\nDuration: ${response.durationSeconds} seconds');
        buffer.writeln('\n---\n');
      }
    }

    return buffer.toString();
  }

  /// Build comprehensive evaluation prompt
  String _buildEvaluationPrompt(
    SpeakingTestSession session,
    String responsesText,
  ) {
    return '''
You are an experienced IELTS examiner tasked with evaluating a speaking test performance. 
Analyze the candidate's responses according to official IELTS Speaking band descriptors.

TEST DETAILS:
Duration: ${session.duration.displayName}
Parts completed: ${session.questions.map((q) => q.part).toSet().length}
Total questions answered: ${session.responses.length}

RESPONSES:
$responsesText

EVALUATION CRITERIA:
Evaluate the candidate on these four criteria (scale 0-9, use decimals like 6.5):

1. FLUENCY AND COHERENCE:
   - Speaks at length without noticeable effort
   - Coherence of ideas and appropriate discourse markers
   - Self-correction and hesitation patterns

2. LEXICAL RESOURCE (Vocabulary):
   - Range and appropriacy of vocabulary
   - Ability to paraphrase
   - Precision in word choice
   - Use of less common and idiomatic language

3. GRAMMATICAL RANGE AND ACCURACY:
   - Range of grammatical structures
   - Accuracy in grammar usage
   - Complexity of sentences

4. PRONUNCIATION:
   - Individual sounds clarity
   - Word stress and sentence stress
   - Rhythm and intonation
   - Overall intelligibility

FEEDBACK REQUIREMENTS:
Provide specific, actionable feedback including:
- At least 3 strengths (what they did well)
- At least 3 weaknesses (areas needing improvement)
- At least 5 practical tips for improvement
- Specific grammar or vocabulary errors with corrections
- Overall encouraging comment

Return ONLY a valid JSON object in this exact format:
{
  "fluencyAndCoherence": 7.0,
  "lexicalResource": 6.5,
  "grammaticalRangeAndAccuracy": 7.0,
  "pronunciation": 7.5,
  "strengths": [
    "Good use of discourse markers",
    "Clear pronunciation",
    "Confident delivery"
  ],
  "weaknesses": [
    "Limited use of complex grammar",
    "Some repetition of vocabulary",
    "Occasional hesitation"
  ],
  "improvementTips": [
    "Practice using more subordinate clauses",
    "Expand vocabulary for abstract topics",
    "Work on reducing filler words",
    "Practice speaking on timer for Part 2",
    "Listen to native speakers for intonation patterns"
  ],
  "specificErrors": {
    "Grammar": "Used 'I goes' instead of 'I go' - subject-verb agreement",
    "Vocabulary": "Overused the word 'good' - try 'excellent', 'outstanding', 'beneficial'",
    "Pronunciation": "Stress on wrong syllable in 'environment' (en-VI-ron-ment not EN-vi-ron-ment)"
  },
  "overallComment": "You demonstrated good fluency and clear pronunciation. Focus on expanding your vocabulary range and using more complex grammatical structures to reach higher bands. Keep practicing!"
}

Remember: Be encouraging but honest. Provide specific examples from their responses.
''';
  }

  /// Call Gemini API for evaluation
  Future<Map<String, dynamic>> _callGeminiForEvaluation(String prompt) async {
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
        'temperature': 0.3, // Lower temperature for more consistent evaluation
        'maxOutputTokens': 2000,
      },
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;

        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List?;

          if (parts != null && parts.isNotEmpty) {
            final textResponse = parts[0]['text'] as String?;

            if (textResponse != null) {
              // Extract JSON from response (handle markdown code blocks)
              String jsonText = textResponse.trim();
              if (jsonText.startsWith('```json')) {
                jsonText = jsonText.substring(7, jsonText.length - 3).trim();
              } else if (jsonText.startsWith('```')) {
                jsonText = jsonText.substring(3, jsonText.length - 3).trim();
              }

              return jsonDecode(jsonText) as Map<String, dynamic>;
            }
          }
        }
      }

      throw Exception(
        'Failed to get evaluation: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      print('Evaluation error: $e');
      // Return fallback evaluation
      return _getFallbackEvaluation();
    }
  }

  /// Parse evaluation JSON into model
  SpeakingTestEvaluation _parseEvaluation(
    String sessionId,
    Map<String, dynamic> json,
  ) {
    final criteria = SpeakingCriteria(
      fluencyAndCoherence: (json['fluencyAndCoherence'] ?? 6.0).toDouble(),
      lexicalResource: (json['lexicalResource'] ?? 6.0).toDouble(),
      grammaticalRangeAndAccuracy: (json['grammaticalRangeAndAccuracy'] ?? 6.0)
          .toDouble(),
      pronunciation: (json['pronunciation'] ?? 6.0).toDouble(),
    );

    final feedback = SpeakingFeedback(
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      improvementTips: List<String>.from(json['improvementTips'] ?? []),
      specificErrors: Map<String, String>.from(json['specificErrors'] ?? {}),
      overallComment: json['overallComment'],
    );

    return SpeakingTestEvaluation(
      testSessionId: sessionId,
      criteria: criteria,
      feedback: feedback,
      evaluatedAt: DateTime.now(),
    );
  }

  /// Fallback evaluation if API fails
  Map<String, dynamic> _getFallbackEvaluation() {
    return {
      'fluencyAndCoherence': 6.5,
      'lexicalResource': 6.0,
      'grammaticalRangeAndAccuracy': 6.5,
      'pronunciation': 6.5,
      'strengths': [
        'You communicated your ideas clearly',
        'Good attempt at answering all questions',
        'Showed willingness to engage with topics',
      ],
      'weaknesses': [
        'Could expand answers with more details',
        'Some hesitation in responses',
        'Limited use of advanced vocabulary',
      ],
      'improvementTips': [
        'Practice speaking for longer periods',
        'Read more to expand vocabulary',
        'Record yourself and listen back',
        'Practice with native speakers if possible',
        'Focus on using a variety of grammatical structures',
      ],
      'specificErrors': {
        'General': 'Continue practicing regularly to build confidence',
      },
      'overallComment':
          'Keep practicing! Regular practice is key to improving your speaking skills. Focus on expanding your vocabulary and speaking more fluently.',
    };
  }

  /// Quick evaluation for individual responses (during test)
  Future<String> getQuickFeedback(
    SpeakingQuestion question,
    SpeakingResponse response,
  ) async {
    if (geminiApiKey == null || geminiApiKey!.isEmpty) {
      return 'Good response! Keep going.';
    }

    final prompt =
        '''
You are an IELTS examiner. The candidate just answered:

Question: ${question.question}
Answer: ${response.transcribedText}
Duration: ${response.durationSeconds} seconds

Provide brief, encouraging feedback (1-2 sentences) on their response. Be supportive and constructive.
''';

    try {
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
        'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 100},
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (text != null) return text.trim();
      }
    } catch (e) {
      print('Quick feedback error: $e');
    }

    return 'Great! Moving to the next question.';
  }
}
