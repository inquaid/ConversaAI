import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// AI Backend service with web and native support
class AiBackendService {
  final String pythonExecutable;
  final String engineScriptPath;
  final String? geminiApiKey;

  const AiBackendService({
    this.pythonExecutable = 'python3',
    this.engineScriptPath = 'lib/backend/voice_backend/engine_invoke.py',
    this.geminiApiKey,
  });

  Future<AiResponse> processUtterance(String audioPath) async {
    if (kIsWeb) {
      return _processWebUtterance(audioPath);
    } else {
      return _processNativeUtterance(audioPath);
    }
  }

  /// Process text directly without audio file
  Future<String> processText(String userText) async {
    return await _getWebReply(userText);
  }

  Future<AiResponse> _processWebUtterance(String audioPath) async {
    // For web, we'll simulate transcription and use direct Gemini API or fallback
    final simulatedTranscript = _getSimulatedTranscript();
    final reply = await _getWebReply(simulatedTranscript);

    return AiResponse(transcript: simulatedTranscript, reply: reply);
  }

  Future<AiResponse> _processNativeUtterance(String audioPath) async {
    try {
      final proc = await Process.start(pythonExecutable, [
        engineScriptPath,
        audioPath,
      ], runInShell: false);

      final stdoutFuture = proc.stdout.transform(utf8.decoder).join();
      final stderrFuture = proc.stderr.transform(utf8.decoder).join();
      final exitCode = await proc.exitCode;
      final out = await stdoutFuture;
      final err = await stderrFuture;

      if (exitCode != 0) {
        throw AiBackendException('Engine failed (code $exitCode): $err');
      }

      final decoded = json.decode(out) as Map<String, dynamic>;
      return AiResponse(
        transcript: (decoded['transcript'] ?? '').toString(),
        reply: (decoded['reply'] ?? '').toString(),
      );
    } catch (e) {
      if (e is AiBackendException) rethrow;
      throw AiBackendException('Backend error: $e');
    }
  }

  String _getSimulatedTranscript() {
    final transcripts = [
      "Hello, I want to practice English",
      "How are you today?",
      "I'm learning to speak better",
      "Can you help me with pronunciation?",
      "What's the weather like?",
      "I love learning new languages",
      "This is a great conversation app",
      "Thank you for helping me practice",
    ];

    return transcripts[DateTime.now().millisecond % transcripts.length];
  }

  Future<String> _getWebReply(String userText) async {
    print('AI Service: Processing request for: "$userText"');
    print(
      'AI Service: API key available: ${geminiApiKey != null && geminiApiKey!.isNotEmpty}',
    );
    print('AI Service: API key length: ${geminiApiKey?.length ?? 0}');

    // Try Gemini API if key is available
    if (geminiApiKey != null && geminiApiKey!.isNotEmpty) {
      try {
        print('AI Service: Calling Gemini API...');
        return await _callGeminiApi(userText);
      } catch (e) {
        print('Gemini API failed: $e');

        // Try alternative endpoint
        try {
          print('AI Service: Trying alternative Gemini endpoint...');
          return await _callGeminiApiV1(userText);
        } catch (e2) {
          print('Alternative Gemini API also failed: $e2');
          // Fall through to local reply
        }
      }
    } else {
      print('AI Service: No API key, using fallback');
    }

    // Local fallback reply
    return _getLocalReply(userText);
  }

  Future<String> _callGeminiApi(String userText) async {
    // Try different model variants that are actually available (October 2025)
    final modelVariants = [
      'gemini-flash-latest', // Always points to latest flash model
      'gemini-2.5-flash', // Fast and efficient
      'gemini-2.0-flash', // Alternative fast model
      'gemini-pro-latest', // Always points to latest pro model
    ];

    String? errorMessage;

    // Try each model variant
    for (final model in modelVariants) {
      try {
        final baseUrl =
            'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';
        final url = '$baseUrl?key=$geminiApiKey';

        print('AI Service: Trying model: $model');

        final prompt =
            '''
You are an interactive English-speaking companion. Your main goal is to help the user practice English speaking fluency. Always respond in a conversational, natural, and engaging way. Don't just answer—also ask relevant follow-up questions so the conversation flows naturally and lasts longer. Adjust your tone to be friendly and supportive, like a human speaking partner. If the user makes mistakes, gently correct grammar, word choice, or phrasing, but keep the flow natural. Encourage the user to explain thoughts, share stories, or express opinions. Sometimes introduce new words or phrases, explain their meaning, and encourage the user to use them. Keep replies short enough for spoken interaction (2–5 sentences), not long essays.

User said: "$userText"
''';

        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'contents': [
              {
                'parts': [
                  {'text': prompt},
                ],
              },
            ],
            'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 200},
          }),
        );

        print('AI Service: Response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final candidates = data['candidates'] as List?;

          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'] as Map<String, dynamic>?;
            final parts = content?['parts'] as List?;

            if (parts != null && parts.isNotEmpty) {
              final text = parts[0]['text'] as String?;
              print('AI Service: Extracted response: $text');
              return text?.trim() ?? _getLocalReply(userText);
            }
          }
          throw AiBackendException(
            'No text found in response: ${response.body}',
          );
        }

        errorMessage = 'Status ${response.statusCode}: ${response.body}';
        // Continue to next model if this one failed
      } catch (e) {
        if (e is! AiBackendException) {
          errorMessage = e.toString();
        }
        // Continue to next model variant
        print('AI Service: Model $model failed: $e');
      }
    }

    // All models failed
    throw AiBackendException(
      'All Gemini models failed. Last error: $errorMessage',
    );
  }

  Future<String> _callGeminiApiV1(String userText) async {
    // Use v1beta instead of v1 - it has better model support
    const baseUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent';
    final url = '$baseUrl?key=$geminiApiKey';

    print('AI Service: Trying fallback endpoint: $baseUrl');

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'contents': [
          {
            'parts': [
              {'text': userText},
            ],
          },
        ],
        'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 150},
      }),
    );

    print('AI Service: V1 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List?;

      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List?;

        if (parts != null && parts.isNotEmpty) {
          final text = parts[0]['text'] as String?;
          return text?.trim() ?? _getLocalReply(userText);
        }
      }
    }

    throw AiBackendException(
      'Gemini API fallback request failed: ${response.statusCode} - ${response.body}',
    );
  }

  String _getLocalReply(String userText) {
    final replies = [
      "That's interesting! Tell me more about that. What made you think of it?",
      "Great! I can hear you're working hard on your English. How long have you been practicing?",
      "Nice pronunciation! Let's continue - what would you like to talk about next?",
      "Wonderful! Your English is improving. Can you tell me about your hobbies?",
      "Perfect! I love hearing your thoughts. What's your favorite thing to do in your free time?",
      "Excellent! You're doing well with conversation. What brings you joy in life?",
      "Great job! Keep practicing like this. What's something new you learned recently?",
      "Amazing! Your confidence is growing. What would you like to improve about your English?",
    ];

    return replies[DateTime.now().microsecond % replies.length];
  }
}

class AiResponse {
  final String transcript;
  final String reply;
  const AiResponse({required this.transcript, required this.reply});
}

class AiBackendException implements Exception {
  final String message;
  AiBackendException(this.message);
  @override
  String toString() => 'AiBackendException: $message';
}
