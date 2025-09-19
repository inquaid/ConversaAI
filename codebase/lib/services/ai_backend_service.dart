import 'dart:convert';
import 'dart:io';

/// Simple bridge to the Python voice backend. It expects a Python environment
/// with required dependencies installed. Given a WAV file path (16kHz mono),
/// it calls the single-turn engine and returns transcript + reply.
class AiBackendService {
  final String pythonExecutable;
  final String engineScriptPath;

  const AiBackendService({
    this.pythonExecutable = 'python3',
    this.engineScriptPath = 'lib/backend/voice_backend/engine_invoke.py',
  });

  Future<AiResponse> processUtterance(String wavPath) async {
    final proc = await Process.start(pythonExecutable, [
      engineScriptPath,
      wavPath,
    ], runInShell: false);
    final stdoutFuture = proc.stdout.transform(utf8.decoder).join();
    final stderrFuture = proc.stderr.transform(utf8.decoder).join();
    final exitCode = await proc.exitCode;
    final out = await stdoutFuture;
    final err = await stderrFuture;
    if (exitCode != 0) {
      throw AiBackendException('Engine failed (code $exitCode): $err');
    }
    try {
      final decoded = json.decode(out) as Map<String, dynamic>;
      return AiResponse(
        transcript: (decoded['transcript'] ?? '').toString(),
        reply: (decoded['reply'] ?? '').toString(),
      );
    } catch (e) {
      throw AiBackendException('Invalid JSON from engine: $e');
    }
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
