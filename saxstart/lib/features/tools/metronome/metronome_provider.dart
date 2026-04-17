import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MetronomeState {
  final int bpm;
  final bool isPlaying;
  final bool beatFlash;

  const MetronomeState({
    this.bpm = 80,
    this.isPlaying = false,
    this.beatFlash = false,
  });

  MetronomeState copyWith({int? bpm, bool? isPlaying, bool? beatFlash}) {
    return MetronomeState(
      bpm: bpm ?? this.bpm,
      isPlaying: isPlaying ?? this.isPlaying,
      beatFlash: beatFlash ?? this.beatFlash,
    );
  }
}

class MetronomeNotifier extends StateNotifier<MetronomeState> {
  final AudioPlayer _player = AudioPlayer();
  Timer? _timer;

  MetronomeNotifier() : super(const MetronomeState()) {
    _player.setSource(AssetSource('audio/metro_tick.wav'));
  }

  void start() {
    if (state.isPlaying) return;

    state = state.copyWith(isPlaying: true);
    _tick(); // Play immediately
    final intervalMs = (60000 / state.bpm).round();
    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      _tick();
    });
  }

  void _tick() {
    _player.stop();
    _player.resume();
    state = state.copyWith(beatFlash: true);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        state = state.copyWith(beatFlash: false);
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isPlaying: false, beatFlash: false);
  }

  void toggle() {
    if (state.isPlaying) {
      stop();
    } else {
      start();
    }
  }

  void setBpm(int bpm) {
    final wasPlaying = state.isPlaying;
    if (wasPlaying) stop();
    state = state.copyWith(bpm: bpm.clamp(40, 200));
    if (wasPlaying) start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }
}

final metronomeProvider =
    StateNotifierProvider<MetronomeNotifier, MetronomeState>(
  (ref) => MetronomeNotifier(),
);
