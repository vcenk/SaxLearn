import 'dart:async';
import 'dart:typed_data';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:record/record.dart';

/// Real-time pitch detection from the device microphone.
///
/// Usage:
/// ```dart
/// final svc = PitchDetectionService();
/// await svc.start();
/// svc.pitchStream.listen((result) {
///   print('${result.pitch} Hz, pitched=${result.isPitched}');
/// });
/// await svc.stop();
/// ```
///
/// The service captures 16-bit PCM audio at 44.1 kHz in chunks, feeds
/// them through the YIN algorithm (via `pitch_detector_dart`), and
/// emits results roughly every 50-100 ms.
class PitchDetectionService {
  static const int sampleRate = 44100;
  static const int bufferSize = 2048;

  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _audioSub;
  final StreamController<PitchResult> _pitchController =
      StreamController<PitchResult>.broadcast();

  late final PitchDetector _detector;
  final List<double> _sampleBuffer = [];
  bool _isRunning = false;

  PitchDetectionService() {
    _detector = PitchDetector(
      audioSampleRate: sampleRate.toDouble(),
      bufferSize: bufferSize,
    );
  }

  Stream<PitchResult> get pitchStream => _pitchController.stream;
  bool get isRunning => _isRunning;

  Future<bool> start() async {
    if (_isRunning) return true;

    // Check/request mic permission
    if (!await _recorder.hasPermission()) {
      return false;
    }

    const config = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: sampleRate,
      numChannels: 1,
      bitRate: sampleRate * 16,
    );

    try {
      final stream = await _recorder.startStream(config);
      _audioSub = stream.listen(_handleAudioChunk);
      _isRunning = true;
      return true;
    } catch (e) {
      _isRunning = false;
      return false;
    }
  }

  Future<void> stop() async {
    _isRunning = false;
    await _audioSub?.cancel();
    _audioSub = null;
    await _recorder.stop();
    _sampleBuffer.clear();
  }

  Future<void> dispose() async {
    await stop();
    await _pitchController.close();
    await _recorder.dispose();
  }

  void _handleAudioChunk(Uint8List data) {
    // Convert 16-bit PCM bytes to normalized doubles in [-1.0, 1.0]
    for (int i = 0; i + 1 < data.length; i += 2) {
      final sample = (data[i] | (data[i + 1] << 8));
      final signed = sample > 0x7FFF ? sample - 0x10000 : sample;
      _sampleBuffer.add(signed / 32768.0);
    }

    // Process full buffers asynchronously
    while (_sampleBuffer.length >= bufferSize) {
      final chunk = _sampleBuffer.sublist(0, bufferSize);
      _sampleBuffer.removeRange(0, bufferSize);
      _processChunk(chunk);
    }
  }

  Future<void> _processChunk(List<double> chunk) async {
    try {
      final result = await _detector.getPitchFromFloatBuffer(chunk);
      if (_pitchController.isClosed) return;
      _pitchController.add(PitchResult(
        pitch: result.pitch,
        isPitched: result.pitched,
        probability: result.probability,
      ));
    } catch (_) {
      // Skip malformed chunks
    }
  }
}

class PitchResult {
  final double pitch;
  final bool isPitched;
  final double probability;

  const PitchResult({
    required this.pitch,
    required this.isPitched,
    required this.probability,
  });
}
