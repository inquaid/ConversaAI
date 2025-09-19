import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class WebAudioService {
  static final WebAudioService _instance = WebAudioService._internal();
  factory WebAudioService() => _instance;
  WebAudioService._internal();

  html.MediaRecorder? _mediaRecorder;
  html.MediaStream? _mediaStream;
  List<html.Blob> _recordedChunks = [];
  bool _isRecording = false;
  String? _currentRecordingUrl;

  // Stream controllers for real-time feedback
  final StreamController<double> _volumeController =
      StreamController<double>.broadcast();
  final StreamController<bool> _recordingController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _playingController =
      StreamController<bool>.broadcast();

  // Getters
  bool get isRecording => _isRecording;
  bool get isPlaying => false; // Simplified for web
  Stream<double> get volumeStream => _volumeController.stream;
  Stream<bool> get recordingStream => _recordingController.stream;
  Stream<bool> get playingStream => _playingController.stream;

  Future<bool> requestPermissions() async {
    try {
      _mediaStream = await html.window.navigator.mediaDevices?.getUserMedia({
        'audio': {
          'sampleRate': 16000,
          'channelCount': 1,
          'echoCancellation': true,
          'noiseSuppression': true,
        },
      });
      return _mediaStream != null;
    } catch (e) {
      print('Permission denied or error: $e');
      return false;
    }
  }

  Future<bool> startRecording() async {
    try {
      if (_mediaStream == null) {
        final hasPermission = await requestPermissions();
        if (!hasPermission) return false;
      }

      _recordedChunks.clear();

      // Create MediaRecorder with web-compatible settings
      _mediaRecorder = html.MediaRecorder(_mediaStream!, {
        'mimeType': 'audio/webm;codecs=opus',
      });

      _mediaRecorder!.onDataAvailable.listen((html.BlobEvent event) {
        if (event.data != null && event.data!.size > 0) {
          _recordedChunks.add(event.data!);
        }
      });

      _mediaRecorder!.onStop.listen((_) {
        _createRecordingBlob();
      });

      _mediaRecorder!.start();
      _isRecording = true;
      _recordingController.add(true);

      // Start volume monitoring simulation
      _startVolumeMonitoring();

      print('Web recording started');
      return true;
    } catch (e) {
      print('Error starting web recording: $e');
      _isRecording = false;
      _recordingController.add(false);
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (!_isRecording || _mediaRecorder == null) return null;

      _mediaRecorder!.stop();
      _isRecording = false;
      _recordingController.add(false);
      _stopVolumeMonitoring();

      // Wait for the blob to be created
      await Future.delayed(const Duration(milliseconds: 100));

      print('Web recording stopped');
      return _currentRecordingUrl;
    } catch (e) {
      print('Error stopping web recording: $e');
      _isRecording = false;
      _recordingController.add(false);
      return null;
    }
  }

  void _createRecordingBlob() {
    if (_recordedChunks.isNotEmpty) {
      final blob = html.Blob(_recordedChunks, 'audio/webm');
      _currentRecordingUrl = html.Url.createObjectUrl(blob);
    }
  }

  Future<Uint8List?> getRecordingBytes() async {
    if (_currentRecordingUrl == null) return null;

    try {
      final response = await html.HttpRequest.request(
        _currentRecordingUrl!,
        responseType: 'arraybuffer',
      );

      if (response.response != null) {
        return Uint8List.view(response.response as ByteBuffer);
      }
    } catch (e) {
      print('Error getting recording bytes: $e');
    }
    return null;
  }

  Future<bool> playRecording([String? path]) async {
    if (_currentRecordingUrl == null) return false;

    try {
      final audio = html.AudioElement()
        ..src = _currentRecordingUrl!
        ..autoplay = true;

      return true;
    } catch (e) {
      print('Error playing web recording: $e');
      return false;
    }
  }

  Timer? _volumeTimer;

  void _startVolumeMonitoring() {
    _volumeTimer?.cancel();
    _volumeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isRecording) {
        // Simulate volume levels for web
        final volume = (DateTime.now().millisecondsSinceEpoch % 1000) / 1000.0;
        _volumeController.add(volume * 0.5 + 0.1); // Keep it reasonable
      }
    });
  }

  void _stopVolumeMonitoring() {
    _volumeTimer?.cancel();
    _volumeTimer = null;
    _volumeController.add(0.0);
  }

  Future<void> stopPlayback() async {
    // Web audio stops automatically
  }

  void dispose() {
    _volumeTimer?.cancel();
    _mediaStream?.getTracks().forEach((track) => track.stop());
    _volumeController.close();
    _recordingController.close();
    _playingController.close();

    if (_currentRecordingUrl != null) {
      html.Url.revokeObjectUrl(_currentRecordingUrl!);
    }
  }
}
