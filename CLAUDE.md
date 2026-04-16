# SaxStart - CLAUDE.md

## Project Overview
SaxStart is a beginner saxophone learning app built with Flutter (Dart). It targets absolute beginners on alto saxophone, providing structured lessons, real-time pitch feedback, practice tools, and progress tracking.

**Platform:** iOS + Android (Flutter)
**Version:** MVP 1.0
**Language:** English only

## Tech Stack
- **Framework:** Flutter (Dart)
- **State Management:** Riverpod (flutter_riverpod + riverpod_annotation)
- **Navigation:** go_router
- **Backend:** Firebase (Auth, Firestore, Analytics, Cloud Messaging)
- **Local Storage:** Hive (offline cache, lesson content)
- **Audio - Tuner:** pitch_detector_dart (microphone pitch detection)
- **Audio - Playback:** audioplayers (metronome tick, note samples)
- **Purchases:** RevenueCat (purchases_flutter)
- **UI:** flutter_svg, lottie, cached_network_image

## Design System
- **Theme:** Dark-only, luxury music aesthetic
- **Background:** #0F0F0F (near black)
- **Primary accent:** Gold #C9963A
- **Light gold:** #E8B84B
- **Cream (headings):** #F5EDD6
- **Body font:** DM Sans (400/500/600)
- **Display font:** Playfair Display (700)
- **Card bg:** #1A1A1A with gold 15% opacity border
- **Spacing:** 4/8/12/16/20/24/32px system
- **Corner radius:** 16px cards, 14px buttons

## Architecture
```
lib/
  main.dart
  app/          - MaterialApp, router, theme
  core/         - Constants, utils (score_calculator), services (auth, firestore, notifications)
  features/     - Feature modules (onboarding, home, learn, play, tools, progress)
    each has: screens/, widgets/, providers/
  data/         - Models, repositories, local_content
  shared/       - Reusable widgets (GoldButton, AppCard, BadgeChip, ProgressBar), extensions
```

## Key Routes
- /welcome, /onboarding/level, /onboarding/goal, /auth
- /home, /learn, /learn/:moduleId/:lessonId
- /play, /play/drill
- /tools, /progress, /settings

## Navigation
Bottom nav with 5 tabs: Home, Learn, Play, Tools, Progress

## Curriculum
4 modules, 17 lessons total:
- Module 1: Foundations (4 lessons) - setup, posture, embouchure, breathing
- Module 2: First Notes (5 lessons) - B, A, G, switching
- Module 3: Tone Building (4 lessons) - long tones, air, tonguing, stability
- Module 4: First Music (4 lessons) - rhythm, patterns, melody, scale

## Play Mode (Audio Scoring)
3 drill types:
- Tune the Note: 3s, pitch-weighted scoring
- Hold It Steady: 4s, stability-weighted scoring
- Follow the Pattern: ~6s, B->A->G sequence

Score components: Pitch (Hz->cents deviation), Stability (variance), Sustain (duration), Attack (time to lock)

## Monetization
- Free: Module 1, basic tuner/metronome, B/A/G fingering, Tune the Note drill
- Premium: All 4 modules, all drills, full fingering chart, daily routines, score history

## Data Storage
- Firestore: users/{uid}, users/{uid}/progress/summary, users/{uid}/sessions/{id}, users/{uid}/drill_scores/{id}
- Hive: local cache for offline, lesson content
- Assets: bundled audio (.mp3 notes, .wav metronome tick), SVG images, Lottie animations

## Build Commands
```bash
flutter create saxstart --org com.yourname
flutter pub get
flutter run --debug           # debug on device
flutter build ios             # iOS release
flutter build appbundle       # Android release
dart run build_runner build   # generate Riverpod/Hive code
```

## Build Order (Phases)
1. Project setup + theme + shared widgets + navigation
2. Onboarding screens + auth + home screen
3. Learn screen + lesson detail screen
4. Tools screen (tuner + metronome + fingering)
5. Play screen + drill screen + scoring logic
6. Progress screen + streak logic + push notifications
7. IAP + paywall + premium gating
8. Polish + animations + App Store prep

## Important Notes
- All lesson content is bundled locally as Dart constants (no network needed)
- Test audio features on real devices (simulators have limited mic support)
- Firebase setup requires google-services.json (Android) and GoogleService-Info.plist (iOS)
- Two Firebase environments: saxstart-dev and saxstart-prod
- Offline-first: write to Hive cache, sync to Firestore when connected
