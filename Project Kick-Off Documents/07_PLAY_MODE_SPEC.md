# SaxStart — Play Mode & Audio Scoring Spec

## Overview

Play Mode listens to the user playing saxophone through the device microphone, analyzes the audio, and returns a structured score. MVP supports single-note analysis only.

---

## Drill Types

### 1. Tune the Note
- Target: one specific note (B, A, or G)
- Duration: 3 seconds
- Scores: Pitch accuracy + Stability + Sustain + Attack
- Good for: beginners learning their first notes

### 2. Hold It Steady
- Target: one note, held as steadily as possible
- Duration: 4 seconds
- Scores: Stability (weighted 50%) + Sustain + Pitch
- Good for: long tone practice

### 3. Follow the Pattern
- Target: B → A → G in sequence
- Duration: ~6 seconds
- Scores: each note separately, then averages
- Unlocked: after Module 2 completion

---

## Scoring Model

### Score Weights by Drill Type

| Score Component | Tune the Note | Hold It Steady | Follow the Pattern |
|----------------|:-------------:|:--------------:|:-----------------:|
| Pitch          | 40%           | 30%            | 35%               |
| Stability      | 30%           | 50%            | 30%               |
| Sustain        | 20%           | 15%            | 25%               |
| Attack         | 10%           | 5%             | 10%               |

### Pitch Score Calculation

```
Target Hz for each note:
  B4 = 493.88 Hz
  A4 = 440.00 Hz
  G4 = 392.00 Hz

Cents deviation = 1200 × log₂(detected / target)

Score:
  0–5 cents off   → 100
  5–50 cents off  → linear scale 100→0
  50+ cents off   → 0
```

### Stability Score Calculation

```
Collect Hz readings every 100ms during sustain phase.
Convert each to cents deviation.
Calculate variance of cents readings.

Score:
  variance ≤ 2    → 100
  variance ≥ 30   → 0
  2–30            → linear scale 100→0
```

### Sustain Score Calculation

```
Target duration = drill type duration
Actual = seconds note was detected above threshold

Score = min(100, actual / target × 100)
```

### Attack Score Calculation

```
Seconds from "Start Listening" tap to first clean pitch detection.

Score:
  ≤ 0.2s → 100
  ≥ 1.5s → 0
  0.2–1.5s → linear scale 100→0
```

---

## Feedback Messages

### Pitch Feedback
```dart
String pitchFeedback(int score) {
  if (score >= 90) return 'Excellent pitch! Right on target.';
  if (score >= 75) return 'Good pitch. Just slightly off center.';
  if (score >= 55) return 'Slightly flat. Try relaxing your jaw slightly.';
  if (score >= 40) return 'Noticeably sharp. Try releasing jaw pressure.';
  return 'Pitch needs work. Check your embouchure and air speed.';
}
```

### Stability Feedback
```dart
String stabilityFeedback(int score) {
  if (score >= 90) return 'Rock steady! Great air control.';
  if (score >= 70) return 'Good stability. A little wobble at the end.';
  if (score >= 50) return 'Note drifted. Try keeping belly support throughout.';
  return 'Lot of wobble. Focus on slow, even air pressure.';
}
```

### Sustain Feedback
```dart
String sustainFeedback(int score) {
  if (score >= 90) return 'Great sustain! You held the full note.';
  if (score >= 70) return 'Good. Try to push through to the end.';
  return 'Cut off too early. Keep air moving until time is up.';
}
```

---

## Flutter Implementation Plan

### Required Packages
```yaml
pitch_detector_dart: ^0.0.4   # Core pitch detection
permission_handler: ^11.1.0   # Mic permission
```

### Permission Flow

```dart
// lib/core/services/audio_permission_service.dart

Future<bool> requestMicPermission() async {
  final status = await Permission.microphone.request();
  return status == PermissionStatus.granted;
}
```

### Drill Session Flow

```dart
// lib/features/play/providers/drill_provider.dart

enum DrillPhase { ready, listening, scored }

class DrillSession {
  final String drillType;
  final String targetNote;
  List<double> hzReadings = [];
  List<double> centsReadings = [];
  DateTime? listenStartTime;
  DateTime? firstDetectionTime;
  
  void addReading(double hz) {
    hzReadings.add(hz);
    final targetHz = noteFrequencies[targetNote] ?? 440;
    final cents = 1200 * log(hz / targetHz) / log(2);
    centsReadings.add(cents);
  }
  
  DrillResultModel computeResult() {
    final pitch = ScoreCalculator.pitchScore(
      _averageHz(), targetNote
    );
    final stability = ScoreCalculator.stabilityScore(centsReadings);
    final sustain = ScoreCalculator.sustainScore(
      _detectedDurationSeconds(), 3.0
    );
    final attack = ScoreCalculator.attackScore(
      firstDetectionTime?.difference(listenStartTime!).inMilliseconds ?? 1500 / 1000.0
    );
    
    return DrillResultModel(
      drillType: drillType,
      targetNote: targetNote,
      pitchScore: pitch,
      stabilityScore: stability,
      sustainScore: sustain,
      attackScore: attack,
      overallScore: ScoreCalculator.overallScore(
        pitch: pitch, stability: stability,
        sustain: sustain, attack: attack,
      ),
      feedback: _selectFeedback(pitch, stability, sustain),
      attemptedAt: DateTime.now(),
    );
  }
}
```

### Pitch Detector Integration

```dart
// lib/features/tools/tuner/tuner_provider.dart

import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:audioplayers/audioplayers.dart';

class TunerNotifier extends StateNotifier<TunerState> {
  final PitchDetector _detector = PitchDetector(
    audioSampleRate: 44100,
    bufferSize: 2048,
  );
  
  StreamSubscription? _subscription;
  
  Future<void> startListening() async {
    final hasPermission = await requestMicPermission();
    if (!hasPermission) {
      state = state.copyWith(error: 'Microphone permission required');
      return;
    }
    
    state = state.copyWith(isListening: true);
    
    _subscription = _detector.pitchStream.listen((pitchResult) {
      if (pitchResult.pitched) {
        final hz = pitchResult.pitch;
        final noteName = hzToNoteName(hz);
        final cents = hzToCentsDeviation(hz, noteName);
        state = state.copyWith(
          detectedNote: noteName,
          detectedHz: hz,
          centsDeviation: cents,
          status: _statusFromCents(cents),
        );
      }
    });
    
    await _detector.start();
  }
  
  void stopListening() {
    _detector.stop();
    _subscription?.cancel();
    state = state.copyWith(isListening: false);
  }
}
```

### Hz to Note Name Conversion

```dart
String hzToNoteName(double hz) {
  const noteNames = ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B'];
  final midi = 12 * log(hz / 440) / log(2) + 69;
  final rounded = midi.round();
  return noteNames[rounded % 12];
}

double hzToCentsDeviation(double hz, String closestNote) {
  final targetHz = noteFrequencies[closestNote + '4'] ?? hz;
  return 1200 * log(hz / targetHz) / log(2);
}
```

---

## Metronome Implementation

```dart
// lib/features/tools/metronome/metronome_provider.dart

class MetronomeNotifier extends StateNotifier<MetronomeState> {
  final AudioPlayer _player = AudioPlayer();
  Timer? _timer;
  
  MetronomeNotifier() : super(MetronomeState(bpm: 80, isPlaying: false)) {
    _player.setSource(AssetSource('audio/metro_tick.wav'));
  }
  
  void start() {
    final intervalMs = (60000 / state.bpm).round();
    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      _player.resume(); // plays from start each time
      state = state.copyWith(beatFlash: true);
      Future.delayed(const Duration(milliseconds: 100), () {
        state = state.copyWith(beatFlash: false);
      });
    });
    state = state.copyWith(isPlaying: true);
  }
  
  void stop() {
    _timer?.cancel();
    state = state.copyWith(isPlaying: false, beatFlash: false);
  }
  
  void setBpm(int bpm) {
    state = state.copyWith(bpm: bpm);
    if (state.isPlaying) { stop(); start(); }
  }
}
```

---

## Note Audio Playback

```dart
// lib/features/tools/fingering/fingering_chart_widget.dart

class NotePlayer {
  final AudioPlayer _player = AudioPlayer();
  
  Future<void> playNote(String noteName) async {
    final asset = 'audio/notes/note_${noteName.toLowerCase()}4.mp3';
    await _player.stop();
    await _player.play(AssetSource(asset));
  }
}
```

---

## Free Note Audio Resources

For `.mp3` note samples (free use):
- **Freesound.org** — search "alto saxophone B note" etc.
- **Philharmonia Orchestra samples** — philharmonia.co.uk/audio
- Record your own with a real sax (best for authenticity)

Files needed for MVP:
- `note_b4.mp3`
- `note_a4.mp3`
- `note_g4.mp3`
- `note_c4.mp3`
- `note_d4.mp3`
- `metro_tick.wav` (any clean click sound)
