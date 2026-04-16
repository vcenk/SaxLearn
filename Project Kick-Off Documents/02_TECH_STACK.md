# SaxStart — Tech Stack & Architecture

## Stack Overview

| Layer | Technology | Reason |
|-------|-----------|--------|
| Frontend | Flutter (Dart) | Cross-platform iOS + Android, best audio support |
| State Management | Riverpod | Clean, scalable, testable |
| Backend | Firebase | Fast MVP setup, real-time sync, free tier |
| Auth | Firebase Auth | Email + Apple + Google sign-in |
| Database | Cloud Firestore | User profiles, progress, sessions |
| Local Storage | Hive | Lesson content, offline access, fast reads |
| Audio - Tuner | pitch_detector_dart | Microphone pitch detection |
| Audio - Metro | flutter_sound or audioplayers | Metronome tick playback |
| Audio - Samples | audioplayers | Note sample playback (local .mp3 files) |
| Purchases | revenue_cat | iOS + Android subscription management |
| Analytics | Firebase Analytics | Session tracking, funnel analysis |
| Push | Firebase Cloud Messaging | Daily practice reminders |
| Navigation | go_router | Declarative routing |

---

## Flutter Packages (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # Navigation
  go_router: ^13.0.0

  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_analytics: ^10.7.0
  firebase_messaging: ^14.7.0

  # Local storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Audio
  audioplayers: ^5.2.1
  pitch_detector_dart: ^0.0.4
  permission_handler: ^11.1.0

  # Purchases
  purchases_flutter: ^6.5.0

  # UI Utilities
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  lottie: ^2.7.0
  shared_preferences: ^2.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.7
  riverpod_generator: ^2.3.3
  hive_generator: ^2.0.1
  flutter_lints: ^3.0.0
```

---

## Firebase Setup

### Required Firebase Services
- Authentication (Email, Apple, Google)
- Cloud Firestore
- Analytics
- Cloud Messaging (push)
- Crashlytics (optional but recommended)

### Environment
Create two Firebase projects:
- `saxstart-dev` — for development
- `saxstart-prod` — for production

Use `flutter_flavorizr` or manual flavors to switch environments.

---

## Folder Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # MaterialApp + router
│   └── theme/
│       ├── app_theme.dart          # Dark theme, gold accent
│       ├── app_colors.dart         # Color constants
│       └── app_typography.dart     # Text styles
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── lesson_content.dart     # Static lesson data
│   ├── utils/
│   │   ├── audio_utils.dart
│   │   └── score_calculator.dart
│   └── services/
│       ├── auth_service.dart
│       ├── firestore_service.dart
│       └── notification_service.dart
│
├── features/
│   ├── onboarding/
│   │   ├── screens/
│   │   │   ├── welcome_screen.dart
│   │   │   ├── level_select_screen.dart
│   │   │   └── goal_select_screen.dart
│   │   └── providers/
│   │       └── onboarding_provider.dart
│   │
│   ├── home/
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   └── widgets/
│   │       ├── continue_lesson_card.dart
│   │       ├── daily_practice_card.dart
│   │       ├── quick_tools_row.dart
│   │       └── progress_snapshot.dart
│   │
│   ├── learn/
│   │   ├── screens/
│   │   │   ├── learn_screen.dart
│   │   │   └── lesson_detail_screen.dart
│   │   ├── widgets/
│   │   │   ├── module_card.dart
│   │   │   └── lesson_row.dart
│   │   └── providers/
│   │       └── lesson_provider.dart
│   │
│   ├── play/
│   │   ├── screens/
│   │   │   ├── play_screen.dart
│   │   │   └── drill_screen.dart
│   │   ├── widgets/
│   │   │   ├── drill_mode_card.dart
│   │   │   ├── listening_animation.dart
│   │   │   └── score_breakdown.dart
│   │   └── providers/
│   │       └── drill_provider.dart
│   │
│   ├── tools/
│   │   ├── screens/
│   │   │   └── tools_screen.dart
│   │   ├── tuner/
│   │   │   ├── tuner_widget.dart
│   │   │   └── tuner_provider.dart
│   │   ├── metronome/
│   │   │   ├── metronome_widget.dart
│   │   │   └── metronome_provider.dart
│   │   └── fingering/
│   │       ├── fingering_chart_widget.dart
│   │       └── fingering_data.dart
│   │
│   └── progress/
│       ├── screens/
│       │   └── progress_screen.dart
│       ├── widgets/
│       │   ├── streak_row.dart
│       │   ├── module_progress_bars.dart
│       │   └── achievement_grid.dart
│       └── providers/
│           └── progress_provider.dart
│
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── lesson_model.dart
│   │   ├── practice_session_model.dart
│   │   └── drill_result_model.dart
│   ├── repositories/
│   │   ├── user_repository.dart
│   │   ├── lesson_repository.dart
│   │   └── session_repository.dart
│   └── local_content/
│       ├── modules.dart
│       └── fingering_chart_data.dart
│
└── shared/
    ├── widgets/
    │   ├── gold_button.dart
    │   ├── outline_button.dart
    │   ├── progress_bar.dart
    │   ├── badge_chip.dart
    │   └── app_card.dart
    └── extensions/
        └── context_extensions.dart
```

---

## Audio Architecture

### Tuner
- Uses device microphone via `permission_handler`
- `pitch_detector_dart` returns Hz value
- Convert Hz to note name using equal temperament formula
- Calculate cents deviation from target: `cents = 1200 * log2(detected / target)`
- Score: 0 cents = 100%, ±50 cents = 0%

### Metronome
- Uses `audioplayers` to play a local `.wav` tick file
- Timer-based scheduling at `60000 / bpm` milliseconds
- Visual flash synced to audio

### Note Samples
- Local `.mp3` files bundled in `assets/audio/notes/`
- Named: `note_b4.mp3`, `note_a4.mp3`, `note_g4.mp3`, etc.
- Played via `audioplayers` on tap

---

## State Management Pattern (Riverpod)

```dart
// Example: Lesson provider
@riverpod
class LessonNotifier extends _$LessonNotifier {
  @override
  AsyncValue<List<Module>> build() => const AsyncLoading();

  Future<void> loadModules() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(lessonRepositoryProvider).getModules(),
    );
  }

  Future<void> completeLesson(String lessonId) async {
    await ref.read(lessonRepositoryProvider).markComplete(lessonId);
    ref.read(progressNotifierProvider.notifier).refresh();
  }
}
```

---

## Offline Strategy

All lesson content is bundled locally as Dart constants (no network required to learn). Firestore syncs:
- User progress
- Streak data
- Drill scores

If offline, write to local Hive cache → sync when reconnected.
