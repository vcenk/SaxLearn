import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingState {
  final String? level;
  final String? goal;
  final bool isComplete;

  const OnboardingState({
    this.level,
    this.goal,
    this.isComplete = false,
  });

  OnboardingState copyWith({
    String? level,
    String? goal,
    bool? isComplete,
  }) {
    return OnboardingState(
      level: level ?? this.level,
      goal: goal ?? this.goal,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void setLevel(String level) {
    state = state.copyWith(level: level);
  }

  void setGoal(String goal) {
    state = state.copyWith(goal: goal);
  }

  void completeOnboarding() {
    state = state.copyWith(isComplete: true);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);
