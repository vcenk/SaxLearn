import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/score_calculator.dart';

enum TunerStatus { idle, listening, permissionDenied }

class TunerState {
  final TunerStatus status;
  final String detectedNote;
  final double detectedHz;
  final double centsDeviation;
  final String statusText;

  const TunerState({
    this.status = TunerStatus.idle,
    this.detectedNote = '--',
    this.detectedHz = 0,
    this.centsDeviation = 0,
    this.statusText = 'Tap to start',
  });

  TunerState copyWith({
    TunerStatus? status,
    String? detectedNote,
    double? detectedHz,
    double? centsDeviation,
    String? statusText,
  }) {
    return TunerState(
      status: status ?? this.status,
      detectedNote: detectedNote ?? this.detectedNote,
      detectedHz: detectedHz ?? this.detectedHz,
      centsDeviation: centsDeviation ?? this.centsDeviation,
      statusText: statusText ?? this.statusText,
    );
  }
}

class TunerNotifier extends StateNotifier<TunerState> {
  TunerNotifier() : super(const TunerState());

  bool get isListening => state.status == TunerStatus.listening;

  Future<void> startListening() async {
    final permission = await Permission.microphone.request();
    if (!permission.isGranted) {
      state = state.copyWith(
        status: TunerStatus.permissionDenied,
        statusText: 'Microphone permission required',
      );
      return;
    }

    state = state.copyWith(
      status: TunerStatus.listening,
      statusText: 'Listening...',
    );

    // TODO: Integrate pitch_detector_dart for real pitch detection
    // For now, the tuner UI is ready and permission flow works.
    // On real device, replace this with:
    //   _detector = PitchDetector(audioSampleRate: 44100, bufferSize: 2048);
    //   _subscription = _detector.pitchStream.listen((result) { ... });
    //   await _detector.start();
  }

  void stopListening() {
    // TODO: Stop pitch detector stream
    state = const TunerState();
  }

  void toggle() {
    if (isListening) {
      stopListening();
    } else {
      startListening();
    }
  }

  /// Process a detected Hz value into note name and cents deviation
  void processHz(double hz) {
    if (hz <= 0) return;

    final noteName = hzToNoteName(hz);
    final noteKey = '$noteName${_octaveFromHz(hz)}';
    final targetHz = ScoreCalculator.noteFrequencies[noteKey] ?? _closestFreq(hz);
    final cents = 1200 * log(hz / targetHz) / log(2);

    String statusText;
    if (cents.abs() <= 5) {
      statusText = 'In tune';
    } else if (cents < -5) {
      statusText = 'Slightly flat';
    } else {
      statusText = 'Slightly sharp';
    }

    state = state.copyWith(
      detectedNote: noteName,
      detectedHz: hz,
      centsDeviation: cents,
      statusText: statusText,
    );
  }

  static String hzToNoteName(double hz) {
    const noteNames = [
      'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
    ];
    final midi = 12 * log(hz / 440) / log(2) + 69;
    final rounded = midi.round();
    return noteNames[rounded % 12];
  }

  static int _octaveFromHz(double hz) {
    final midi = (12 * log(hz / 440) / log(2) + 69).round();
    return (midi ~/ 12) - 1;
  }

  static double _closestFreq(double hz) {
    final midi = (12 * log(hz / 440) / log(2) + 69).round();
    return 440 * pow(2, (midi - 69) / 12).toDouble();
  }
}

final tunerProvider = StateNotifierProvider<TunerNotifier, TunerState>(
  (ref) => TunerNotifier(),
);
