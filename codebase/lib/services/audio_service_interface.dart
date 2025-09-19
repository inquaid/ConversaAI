import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

// Abstract interface for audio services
abstract class AudioServiceInterface {
  bool get isRecording;
  bool get isPlaying;
  Stream<double> get volumeStream;
  Stream<bool> get recordingStream;
  Stream<bool> get playingStream;

  Future<bool> requestPermissions();
  Future<bool> startRecording();
  Future<String?> stopRecording();
  Future<bool> playRecording([String? path]);
  Future<void> stopPlayback();
  void dispose();
}

// Factory to create the appropriate audio service
class AudioServiceFactory {
  static AudioServiceInterface create() {
    if (kIsWeb) {
      return WebAudioService();
    } else {
      return NativeAudioService();
    }
  }
}

// Web implementation
class WebAudioService implements AudioServiceInterface {
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _simulatedRecordingPath;

  final StreamController<double> _volumeController =
      StreamController<double>.broadcast();
  final StreamController<bool> _recordingController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _playingController =
      StreamController<bool>.broadcast();

  @override
  bool get isRecording => _isRecording;

  @override
  bool get isPlaying => _isPlaying;

  @override
  Stream<double> get volumeStream => _volumeController.stream;

  @override
  Stream<bool> get recordingStream => _recordingController.stream;

  @override
  Stream<bool> get playingStream => _playingController.stream;

  @override
  Future<bool> requestPermissions() async {
    // For web, we'll simulate permissions for now
    return true;
  }

  @override
  Future<bool> startRecording() async {
    try {
      _isRecording = true;
      _recordingController.add(true);
      _startVolumeMonitoring();
      print('Web recording started (simulated)');
      return true;
    } catch (e) {
      print('Error starting web recording: $e');
      _isRecording = false;
      _recordingController.add(false);
      return false;
    }
  }

  @override
  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) return null;

      _isRecording = false;
      _recordingController.add(false);
      _stopVolumeMonitoring();

      // Simulate a recording file path
      _simulatedRecordingPath =
          'web_recording_${DateTime.now().millisecondsSinceEpoch}.wav';

      print('Web recording stopped (simulated)');
      return _simulatedRecordingPath;
    } catch (e) {
      print('Error stopping web recording: $e');
      _isRecording = false;
      _recordingController.add(false);
      return null;
    }
  }

  @override
  Future<bool> playRecording([String? path]) async {
    try {
      _isPlaying = true;
      _playingController.add(true);

      // Simulate playback duration
      Future.delayed(const Duration(seconds: 2), () {
        _isPlaying = false;
        _playingController.add(false);
      });

      return true;
    } catch (e) {
      print('Error playing web recording: $e');
      _isPlaying = false;
      _playingController.add(false);
      return false;
    }
  }

  @override
  Future<void> stopPlayback() async {
    _isPlaying = false;
    _playingController.add(false);
  }

  Timer? _volumeTimer;

  void _startVolumeMonitoring() {
    _volumeTimer?.cancel();
    _volumeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isRecording) {
        final volume = (DateTime.now().millisecondsSinceEpoch % 1000) / 1000.0;
        _volumeController.add(volume * 0.7 + 0.1);
      }
    });
  }

  void _stopVolumeMonitoring() {
    _volumeTimer?.cancel();
    _volumeTimer = null;
    _volumeController.add(0.0);
  }

  @override
  void dispose() {
    _volumeTimer?.cancel();
    _volumeController.close();
    _recordingController.close();
    _playingController.close();
  }
}

// Native implementation (imports moved to avoid web compilation issues)
class NativeAudioService implements AudioServiceInterface {
  late dynamic _audioService;

  NativeAudioService() {
    // Import only on native platforms
    if (!kIsWeb) {
      // This will be imported conditionally in the factory
      throw UnsupportedError(
        'Native audio service not implemented in this file',
      );
    }
  }

  @override
  bool get isRecording => false;

  @override
  bool get isPlaying => false;

  @override
  Stream<double> get volumeStream => const Stream.empty();

  @override
  Stream<bool> get recordingStream => const Stream.empty();

  @override
  Stream<bool> get playingStream => const Stream.empty();

  @override
  Future<bool> requestPermissions() async => false;

  @override
  Future<bool> startRecording() async => false;

  @override
  Future<String?> stopRecording() async => null;

  @override
  Future<bool> playRecording([String? path]) async => false;

  @override
  Future<void> stopPlayback() async {}

  @override
  void dispose() {}
}
