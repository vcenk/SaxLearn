# SaxStart — Screen Build Checklist

Track your build progress screen by screen.

---

## Phase 1 — Project Setup

- [ ] Create Flutter project: `flutter create saxstart --org com.yourname`
- [ ] Add all packages to `pubspec.yaml` (see 02_TECH_STACK.md)
- [ ] Run `flutter pub get`
- [ ] Set up Firebase project (dev + prod)
- [ ] Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- [ ] Configure `firebase_options.dart` via FlutterFire CLI
- [ ] Set up Hive for local storage
- [ ] Create folder structure (see 02_TECH_STACK.md)
- [ ] Create `app_colors.dart` with full dark theme palette
- [ ] Create `app_theme.dart` with MaterialApp dark theme
- [ ] Create `app_typography.dart` with DM Sans + Playfair Display
- [ ] Set up `go_router` with all route paths defined
- [ ] Create shared widgets: `GoldButton`, `OutlineButton`, `AppCard`, `BadgeChip`, `ProgressBar`
- [ ] Add local lesson content as Dart constants
- [ ] Add fingering chart data
- [ ] Add note sample `.mp3` files to `assets/audio/notes/`
- [ ] Add metronome tick `.wav` to `assets/audio/`

---

## Phase 2 — Onboarding Screens

### Welcome Screen (`/welcome`)
- [ ] Splash logo centered on dark background
- [ ] Tagline: "Learn saxophone step by step"
- [ ] 3-slide onboarding carousel (auto or swipe)
  - Slide 1: "Learn without feeling overwhelmed"
  - Slide 2: "Practice with beginner tools"
  - Slide 3: "Track your progress every day"
- [ ] Dot indicator for slides
- [ ] "Get Started" → Level Select
- [ ] "Sign In" → Firebase Auth screen

### Level Select Screen (`/onboarding/level`)
- [ ] Title: "Where are you starting?"
- [ ] 3 option cards:
  - Absolute Beginner
  - Returning Player
  - School Band Starter
- [ ] Selection highlights card in gold
- [ ] "Continue" button → Goal Select
- [ ] Save selection to local state

### Goal Select Screen (`/onboarding/goal`)
- [ ] Title: "What's your main goal?"
- [ ] 3 option cards:
  - Learn my first notes
  - Improve my tone
  - Build a daily practice habit
- [ ] "Let's Go" button → Home
- [ ] Save goal to Firestore user document on completion

### Auth Screen (`/auth`)
- [ ] Email + password sign up
- [ ] Google Sign-In button
- [ ] Apple Sign-In button (iOS required)
- [ ] "Skip for now" → continue as guest
- [ ] Guest mode saves progress to Hive only

---

## Phase 3 — Main Screens

### Home Screen (`/home`)
- [ ] Header: greeting ("Good evening") + streak badge + profile icon
- [ ] Continue Lesson card:
  - Current lesson title + module
  - Progress bar (% complete in module)
  - "Resume" button → Lesson Detail
- [ ] Daily Practice card:
  - Today's 3–4 tasks
  - Checkmarks for completed items
  - "Start Drill Mode" → Play Screen
- [ ] Quick Tools row (4 icon cards):
  - Tuner, Metronome, Fingering, Play Mode
- [ ] Progress snapshot row: lessons done / practice time / streak
- [ ] Scroll behavior: single scrollable column

### Learn Screen (`/learn`)
- [ ] Title: "Lessons"
- [ ] Module cards list (accordion or flat list):
  - Module title
  - X of Y complete
  - Badge: Done / In Progress / Locked
  - Lock icon if prerequisites not met
- [ ] Expanded module shows lesson rows:
  - Lesson title + duration + difficulty
  - Checkmark if complete
  - Lock icon if locked
  - Tap → Lesson Detail Screen
- [ ] Free vs Premium gate: blur/lock Module 2+ for free users

### Lesson Detail Screen (`/learn/:moduleId/:lessonId`)
- [ ] Back button + module breadcrumb + duration badge
- [ ] Lesson title (large, display font)
- [ ] Short intro paragraph
- [ ] Objective card
- [ ] Fingering visual (if noteReference set):
  - Note name large
  - Key diagram with pressed keys highlighted in gold
  - "Play sample" button
- [ ] Practice Steps list (numbered, with completion checkmarks)
- [ ] Tip card (gold accent)
- [ ] "Practice in Play Mode" button → Play Screen with note pre-selected
- [ ] "Mark Complete" button → updates progress, unlocks next lesson, returns to Learn

### Play Screen (`/play`)
- [ ] Title: "Play Mode"
- [ ] 3 drill mode cards:
  - Tune the Note (beginner)
  - Hold It Steady (beginner)
  - Follow the Pattern (intermediate)
  - Each card: title, description, badge, tap → Drill Screen
- [ ] Best Scores section below drill cards

### Drill Screen (`/play/drill`)
- [ ] Phase 1 — Ready:
  - Drill type label
  - "Play this note" label
  - Large target note (display font)
  - Instruction text
  - "Start Listening" button → start microphone + timer
- [ ] Phase 2 — Listening:
  - Hide start button
  - Show animated listening ring (pulsing circle)
  - "Listening..." instruction text
  - Auto-advance to Phase 3 after 3–4 seconds
- [ ] Phase 3 — Score:
  - Overall score (large number)
  - Score breakdown bars (Pitch, Stability, Sustain, Attack)
  - Feedback tip card
  - "Try Again" button → back to Phase 1
  - "Done" button → back to Play Screen
- [ ] Save result to Firestore session

### Tools Screen (`/tools`)
- [ ] Tuner section:
  - Large detected note name
  - Tuning meter (flat / in tune / sharp zones)
  - Needle indicator position
  - Start/Stop listening button
  - Status text: "Slightly flat" / "In tune ✓" / "Slightly sharp"
- [ ] Metronome section:
  - Large BPM number
  - Preset buttons: 60, 80, 100, 120
  - Slider: 40–200 BPM
  - Circle that flashes gold on beat
  - Start/Stop button
- [ ] Fingering Chart section:
  - Note selector row (B, A, G, C, D, E, F free; rest premium)
  - Fingering diagram with pressed keys highlighted
  - Note name + tip text
  - "Play note" audio button

### Progress Screen (`/progress`)
- [ ] Header: "Progress"
- [ ] Top stat row (3 cards): Total Practice / Lessons Done / Streak
- [ ] "This Week" section:
  - 7-day dot row (M T W T F S S)
  - Done = gold fill, today = bright gold, future = empty
- [ ] Module Progress section:
  - Progress bar per module with % label
- [ ] Achievements grid (2 columns):
  - First Lesson Complete
  - 3-Day Streak
  - 30 Min Club
  - First A Note
  - First G Note
  - 7-Day Streak
  - Module 2 Complete
- [ ] Locked achievements shown at reduced opacity

### Profile / Settings Screen (`/settings`)
- [ ] Name (editable)
- [ ] Level display
- [ ] Daily reminder toggle + time picker
- [ ] Dark mode toggle (always dark for v1, just show it)
- [ ] Subscription status + "Upgrade to Pro" if free
- [ ] Sign out button
- [ ] Restore purchases button

---

## Phase 4 — Functional Features

### Microphone + Pitch Detection
- [ ] Request microphone permission on first tuner/drill use
- [ ] Handle permission denied state gracefully
- [ ] `pitch_detector_dart` integration
- [ ] Real-time Hz → note name conversion
- [ ] Cents deviation calculation
- [ ] Stability tracking over time (list of readings)
- [ ] Session recording + scoring (3–4 seconds)

### Metronome
- [ ] `audioplayers` + local tick.wav
- [ ] Timer-based at `60000 / bpm` ms interval
- [ ] Visual flash synced to audio tick
- [ ] No drift over 4+ minutes (use AudioPlayer loop or precise scheduling)

### Note Sample Playback
- [ ] `audioplayers` plays local `.mp3` on tap
- [ ] One sound file per note: note_b4.mp3, note_a4.mp3, etc.
- [ ] Quick tap response (preload on screen init)

### Streak Logic
- [ ] Check streak on app open
- [ ] Update streak when session saved
- [ ] Handle timezone edge cases (use local date, not UTC)
- [ ] Show "streak at risk" warning if no practice today by 8 PM

### Push Notifications
- [ ] Request permission on first open (after onboarding)
- [ ] Schedule daily reminder at user's chosen time
- [ ] Notification: "Time to practice! Your streak is at X days 🎷"
- [ ] On tap: open app to Home screen

### In-App Purchases (RevenueCat)
- [ ] Configure RevenueCat project
- [ ] Add iOS + Android products
- [ ] Premium gate on locked content
- [ ] Paywall screen with monthly / annual options
- [ ] Restore purchases flow

---

## Phase 5 — Polish

- [ ] App icon (dark background, gold sax)
- [ ] Splash screen
- [ ] Loading states on all async operations
- [ ] Empty states (no sessions yet, no streak)
- [ ] Error states (no internet, microphone failed)
- [ ] Haptic feedback on drill score reveal
- [ ] Smooth page transitions
- [ ] Score bar animation (grow on reveal)
- [ ] Listening ring pulse animation
- [ ] Achievement unlock animation (lottie)
- [ ] App Store screenshots (6 screens)
- [ ] Privacy policy page (required for microphone + IAP)
- [ ] Terms of service page

---

## Phase 6 — Launch

- [ ] TestFlight build (iOS)
- [ ] Google Play Internal Testing build (Android)
- [ ] Crashlytics enabled
- [ ] Firebase Analytics events mapped
- [ ] App Store Connect listing
- [ ] Google Play Console listing
- [ ] Submit for review

---

## Key Build Order Recommendation

```
Week 1:  Project setup + theme + shared widgets + navigation
Week 2:  Onboarding screens + auth + home screen
Week 3:  Learn screen + lesson detail screen
Week 4:  Tools screen (tuner + metronome + fingering)
Week 5:  Play screen + drill screen + scoring logic
Week 6:  Progress screen + streak logic + push notifications
Week 7:  IAP + paywall + premium gating
Week 8:  Polish + animations + App Store prep + submit
```
