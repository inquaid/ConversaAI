import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'platform_audio_service.dart';

class AudioService implements AudioServiceInterface {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  String? _currentRecordingPath;
  bool _isRecording = false;
  bool _isPlaying = false;

  // Stream controllers for real-time feedback
  final StreamController<double> _volumeController =
      StreamController<double>.broadcast();
  final StreamController<bool> _recordingController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _playingController =
      StreamController<bool>.broadcast();

  // Getters
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  Stream<double> get volumeStream => _volumeController.stream;
  Stream<bool> get recordingStream => _recordingController.stream;
  Stream<bool> get playingStream => _playingController.stream;

  Future<bool> requestPermissions() async {
    final microphonePermission = await Permission.microphone.request();
    return microphonePermission == PermissionStatus.granted;
  }

  Future<String> _getRecordingPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${directory.path}/recording_$timestamp.wav';
  }

  Future<bool> startRecording() async {
    try {
      // Request permissions
      if (!await requestPermissions()) {
        print('Microphone permission denied');
        return false;
      }

      // Check if recorder is available
      if (!await _recorder.hasPermission()) {
        print('Recording permission not available');
        return false;
      }

      // Get recording path
      _currentRecordingPath = await _getRecordingPath();

      // Configure recording settings for optimal quality and performance
      const config = RecordConfig(
        encoder: AudioEncoder.wav, // WAV format for Whisper compatibility
        bitRate: 128000, // Good quality, reasonable file size
        sampleRate: 16000, // 16kHz required by Whisper
        numChannels: 1, // Mono for voice
      );

      // Start recording
      await _recorder.start(config, path: _currentRecordingPath!);

      _isRecording = true;
      _recordingController.add(true);

      // Start volume monitoring for visual feedback
      _startVolumeMonitoring();

      print('Recording started: $_currentRecordingPath');
      return true;
    } catch (e) {
      print('Error starting recording: $e');
      _isRecording = false;
      _recordingController.add(false);
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) return null;

      // Stop recording
      final path = await _recorder.stop();

      _isRecording = false;
      _recordingController.add(false);

      // Stop volume monitoring
      _stopVolumeMonitoring();

      print('Recording stopped: $path');
      return path ?? _currentRecordingPath;
    } catch (e) {
      print('Error stopping recording: $e');
      _isRecording = false;
      _recordingController.add(false);
      return null;
    }
  }

  Future<bool> playRecording([String? path]) async {
    try {
      final playPath = path ?? _currentRecordingPath;
      if (playPath == null) {
        print('No recording path available');
        return false;
      }

      // Check if file exists
      if (!File(playPath).existsSync()) {
        print('Recording file does not exist: $playPath');
        return false;
      }

      // Play the recording
      _isPlaying = true;
      _playingController.add(true);

      await _player.play(DeviceFileSource(playPath));

      // Listen for completion
      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
        _playingController.add(false);
      });

      print('Playing recording: $playPath');
      return true;
    } catch (e) {
      print('Error playing recording: $e');
      _isPlaying = false;
      _playingController.add(false);
      return false;
    }
  }

  Future<void> stopPlayback() async {
    try {
      await _player.stop();
      _isPlaying = false;
      _playingController.add(false);
    } catch (e) {
      print('Error stopping playback: $e');
    }
  }

  Timer? _volumeTimer;

  void _startVolumeMonitoring() {
    _volumeTimer?.cancel();
    _volumeTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) async {
      if (_isRecording) {
        try {
          // Get amplitude for volume visualization
          final amplitude = await _recorder.getAmplitude();
          final normalizedVolume =
              (amplitude.current + 50) / 50; // Normalize to 0-1
          final clampedVolume = normalizedVolume.clamp(0.0, 1.0);
          _volumeController.add(clampedVolume);
        } catch (e) {
          // Silently handle amplitude errors
          _volumeController.add(0.0);
        }
      }
    });
  }

  void _stopVolumeMonitoring() {
    _volumeTimer?.cancel();
    _volumeTimer = null;
    _volumeController.add(0.0);
  }

  void dispose() {
    _volumeTimer?.cancel();
    _recorder.dispose();
    _player.dispose();
    _volumeController.close();
    _recordingController.close();
    _playingController.close();
  }
}
