/// Dynamic IELTS Speaking Question Generator using Gemini AI
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/ielts_speaking_test_models.dart';
import '../config/app_config.dart';

class DynamicIELTSQuestionGenerator {
  final String? geminiApiKey;
  static final Random _random = Random();

  const DynamicIELTSQuestionGenerator({this.geminiApiKey});

  factory DynamicIELTSQuestionGenerator.instance() {
    return DynamicIELTSQuestionGenerator(
      geminiApiKey: AppConfig.activeGeminiApiKey,
    );
  }

  /// Generate a complete test with dynamic, thematically connected questions
  Future<List<SpeakingQuestion>> generateDynamicTest(
    SpeakingTestDuration duration,
  ) async {
    if (geminiApiKey == null || geminiApiKey!.isEmpty) {
      throw Exception('Gemini API key is not configured');
    }

    // Select a random theme for the session
    final theme = _selectRandomTheme();
    final examinerPersonality = _selectExaminerPersonality();

    print(
      'Generating test with theme: $theme, personality: $examinerPersonality',
    );

    // Generate questions based on duration
    switch (duration) {
      case SpeakingTestDuration.short:
        return await _generatePart1Questions(
          theme,
          examinerPersonality,
          count: 6,
        );

      case SpeakingTestDuration.medium:
        final part1 = await _generatePart1Questions(
          theme,
          examinerPersonality,
          count: 4,
        );
        final part2 = await _generatePart2Question(theme, examinerPersonality);
        return [...part1, part2];

      case SpeakingTestDuration.full:
        final part1 = await _generatePart1Questions(
          theme,
          examinerPersonality,
          count: 4,
        );
        final part2 = await _generatePart2Question(theme, examinerPersonality);
        final part3 = await _generatePart3Questions(
          theme,
          examinerPersonality,
          count: 4,
        );
        return [...part1, part2, ...part3];
    }
  }

  /// Generate Part 1 questions dynamically
  Future<List<SpeakingQuestion>> _generatePart1Questions(
    String theme,
    String personality, {
    int count = 4,
  }) async {
    final prompt =
        '''
You are an IELTS speaking examiner with a $personality personality. Generate $count Part 1 questions on the theme of "$theme".

Part 1 questions should be:
- Personal and conversational
- Easy to answer based on personal experience
- Progressive (starting simple, becoming slightly more detailed)
- Natural and engaging
- Related to the theme but varied

Return ONLY a JSON array of questions in this exact format:
[
  "Question text here?",
  "Another question here?",
  "Third question here?",
  "Fourth question here?"
]

Make the questions sound natural and conversational, as if asked by a real examiner.
''';

    try {
      final response = await _callGeminiAPI(prompt);
      final questions = _parseQuestionList(response);

      return questions
          .take(count)
          .map(
            (q) => SpeakingQuestion(
              part: SpeakingTestPart.part1,
              question: q,
              speakingTimeSeconds: 30,
            ),
          )
          .toList();
    } catch (e) {
      print('Error generating Part 1 questions: $e');
      // Fallback to default questions
      return _getFallbackPart1Questions(count);
    }
  }

  /// Generate Part 2 question dynamically
  Future<SpeakingQuestion> _generatePart2Question(
    String theme,
    String personality,
  ) async {
    final prompt =
        '''
You are an IELTS speaking examiner with a $personality personality. Generate a Part 2 cue card task on the theme of "$theme".

The cue card should:
- Have a clear topic related to $theme
- Include 3-4 bullet points for the candidate to cover
- Be typical of IELTS Part 2 format
- Allow for 1-2 minutes of speaking

Return ONLY a JSON object in this exact format:
{
  "topic": "Describe a [something related to $theme]",
  "bulletPoints": [
    "What it is/was",
    "How you know about it",
    "Why it is important",
    "How you feel about it"
  ]
}

Make it engaging and allow for personal storytelling.
''';

    try {
      final response = await _callGeminiAPI(prompt);
      final data = _parseJson(response);

      return SpeakingQuestion(
        part: SpeakingTestPart.part2,
        question: data['topic'],
        bulletPoints: List<String>.from(data['bulletPoints']),
        preparationTimeSeconds: 60,
        speakingTimeSeconds: 120,
      );
    } catch (e) {
      print('Error generating Part 2 question: $e');
      return _getFallbackPart2Question();
    }
  }

  /// Generate Part 3 questions dynamically
  Future<List<SpeakingQuestion>> _generatePart3Questions(
    String theme,
    String personality, {
    int count = 4,
  }) async {
    final prompt =
        '''
You are an IELTS speaking examiner with a $personality personality. Generate $count Part 3 questions related to the theme of "$theme".

Part 3 questions should be:
- Abstract and analytical
- Related to broader implications of $theme
- Require critical thinking
- Allow for extended discussion
- Progress from personal to societal perspectives

Return ONLY a JSON array of questions in this exact format:
[
  "How has $theme changed in your country over the years?",
  "What impact does [aspect of $theme] have on society?",
  "Do you think [prediction about $theme]?",
  "What role should governments play in [aspect of $theme]?"
]

Make them thought-provoking and suitable for academic discussion.
''';

    try {
      final response = await _callGeminiAPI(prompt);
      final questions = _parseQuestionList(response);

      return questions
          .take(count)
          .map(
            (q) => SpeakingQuestion(
              part: SpeakingTestPart.part3,
              question: q,
              speakingTimeSeconds: 60,
            ),
          )
          .toList();
    } catch (e) {
      print('Error generating Part 3 questions: $e');
      return _getFallbackPart3Questions(count);
    }
  }

  /// Generate natural spoken question text
  Future<String> generateSpokenQuestion(SpeakingQuestion question) async {
    final prompt =
        '''
You are an IELTS speaking examiner. Say the following question naturally as you would in a real exam.
Make it sound conversational and friendly, not robotic.

Question: ${question.question}

${question.part == SpeakingTestPart.part2 ? '''
This is Part 2, so introduce it by saying "Now I'm going to give you a topic and I'd like you to talk about it for one to two minutes. You have one minute to think about what you're going to say. You can make some notes if you wish."

Then read the cue card:
${question.question}
${question.bulletPoints?.map((p) => '- $p').join('\n') ?? ''}

End with: "Alright? Remember you have one to two minutes for this, so don't worry if I stop you. I'll tell you when the time is up."
''' : ''}

Return ONLY the spoken text, nothing else. Make it sound natural and warm.
''';

    try {
      final response = await _callGeminiAPI(prompt);
      return response.trim();
    } catch (e) {
      print('Error generating spoken question: $e');
      // Fallback to original question
      return question.question;
    }
  }

  /// Call Gemini API
  Future<String> _callGeminiAPI(String prompt) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$geminiApiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.8, // Higher for more creative questions
          'maxOutputTokens': 1000,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (text != null) return text.trim();
    }

    throw Exception('Failed to generate content: ${response.statusCode}');
  }

  /// Parse JSON from response (handle markdown code blocks)
  Map<String, dynamic> _parseJson(String response) {
    String jsonText = response.trim();

    // Remove markdown code blocks if present
    if (jsonText.startsWith('```json')) {
      jsonText = jsonText.substring(7, jsonText.length - 3).trim();
    } else if (jsonText.startsWith('```')) {
      jsonText = jsonText.substring(3, jsonText.length - 3).trim();
    }

    return jsonDecode(jsonText) as Map<String, dynamic>;
  }

  /// Parse question list from response
  List<String> _parseQuestionList(String response) {
    try {
      String jsonText = response.trim();

      // Remove markdown code blocks if present
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7, jsonText.length - 3).trim();
      } else if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3, jsonText.length - 3).trim();
      }

      final parsed = jsonDecode(jsonText);
      return List<String>.from(parsed);
    } catch (e) {
      print('Error parsing question list: $e');
      print('Response was: $response');
      throw Exception('Failed to parse questions');
    }
  }

  /// Select random theme for the session
  String _selectRandomTheme() {
    final themes = [
      'Technology and Innovation',
      'Travel and Cultural Experiences',
      'Education and Learning',
      'Work and Career Development',
      'Environment and Sustainability',
      'Health and Wellbeing',
      'Arts and Creativity',
      'Social Relationships and Community',
      'Food and Culinary Traditions',
      'Sports and Physical Activities',
      'Media and Entertainment',
      'Urban Life and Architecture',
    ];

    return themes[_random.nextInt(themes.length)];
  }

  /// Select examiner personality for variation
  String _selectExaminerPersonality() {
    final personalities = [
      'friendly and encouraging',
      'professional and formal',
      'warm and conversational',
      'enthusiastic and engaging',
      'calm and supportive',
      'curious and interested',
    ];

    return personalities[_random.nextInt(personalities.length)];
  }

  /// Fallback Part 1 questions
  List<SpeakingQuestion> _getFallbackPart1Questions(int count) {
    final questions = [
      "Let's talk about your daily routine. What do you usually do in the mornings?",
      "Do you prefer to plan your day in advance or be spontaneous?",
      "How has your routine changed over the past few years?",
      "What's your favorite part of the day? Why?",
      "Do you think having a routine is important? Why or why not?",
      "If you could change one thing about your daily schedule, what would it be?",
    ];

    return questions
        .take(count)
        .map(
          (q) => SpeakingQuestion(
            part: SpeakingTestPart.part1,
            question: q,
            speakingTimeSeconds: 30,
          ),
        )
        .toList();
  }

  /// Fallback Part 2 question
  SpeakingQuestion _getFallbackPart2Question() {
    return SpeakingQuestion(
      part: SpeakingTestPart.part2,
      question: 'Describe a memorable experience you had recently',
      bulletPoints: [
        'What the experience was',
        'When and where it happened',
        'Who was involved',
        'Why it was memorable to you',
      ],
      preparationTimeSeconds: 60,
      speakingTimeSeconds: 120,
    );
  }

  /// Fallback Part 3 questions
  List<SpeakingQuestion> _getFallbackPart3Questions(int count) {
    final questions = [
      "How do you think daily routines will change in the future?",
      "What role does technology play in organizing people's lives today?",
      "Do you think modern life is more stressful than in the past? Why?",
      "How important is work-life balance in today's society?",
    ];

    return questions
        .take(count)
        .map(
          (q) => SpeakingQuestion(
            part: SpeakingTestPart.part3,
            question: q,
            speakingTimeSeconds: 60,
          ),
        )
        .toList();
  }
}
