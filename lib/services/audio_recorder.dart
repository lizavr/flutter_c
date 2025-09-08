import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorderService {
  AudioRecorderService({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  StreamSubscription<Amplitude>? _ampSub;
  Timer? _silenceTimer;
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  Future<bool> _ensurePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> start() async {
    if (_isRecording) return false;
    final ok = await _ensurePermission();
    if (!ok) return false;

    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
      sampleRate: 44100,
    );
    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(config, path: filePath);
    _isRecording = true;

    _ampSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 250))
        .listen(_onAmplitude);
    return true;
  }

  void _onAmplitude(Amplitude amp) {
    // Threshold based on normalized level. Tune as needed.
    final double level = amp.current.abs();
    const double silenceThreshold = 0.03; // ~-30 dBFS equivalent

    if (level < silenceThreshold) {
      _silenceTimer?.cancel();
      _silenceTimer = Timer(const Duration(seconds: 2), () async {
        if (_isRecording) {
          await stop();
        }
      });
    } else {
      _silenceTimer?.cancel();
    }
  }

  Future<Uint8List?> stop() async {
    if (!_isRecording) return null;
    _silenceTimer?.cancel();
    await _ampSub?.cancel();
    _ampSub = null;
    _isRecording = false;

    final path = await _recorder.stop();
    if (path == null) return null;
    try {
      final bytes = await File(path).readAsBytes();
      return bytes;
    } catch (e) {
      debugPrint('Failed reading recorded bytes: $e');
      return null;
    }
  }

  Future<void> dispose() async {
    _silenceTimer?.cancel();
    await _ampSub?.cancel();
    if (_isRecording) {
      await _recorder.stop();
    }
  }
}
