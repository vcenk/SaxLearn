# SaxStart — Claude Code Prompts

Use these prompts with Claude Code CLI to build each part of the app.  
Run Claude Code from inside the `saxstart/` Flutter project directory.

---

## Prompt 1 — Project Setup & Theme

```
I am building a Flutter app called SaxStart — a beginner saxophone learning app.

Set up the following:
1. Create the full folder structure as defined in 02_TECH_STACK.md
2. Create app_colors.dart with the dark theme palette (dark charcoal background, gold accent #C9963A, cream text #F5EDD6)
3. Create app_typography.dart using DM Sans (body) and Playfair Display (display/headings)
4. Create app_theme.dart with a full dark ThemeData
5. Create the shared widgets: GoldButton, OutlineButton, AppCard, BadgeChip, AppProgressBar
6. Set up go_router with these routes: /welcome, /onboarding/level, /onboarding/goal, /home, /learn, /learn/:lessonId, /play, /play/drill, /tools, /progress, /settings
7. Set up Riverpod with ProviderScope in main.dart

Use the design system specs from 06_DESIGN_SYSTEM.md.
All widgets should be dark-theme only for MVP.
```

---

## Prompt 2 — Onboarding Screens

```
Build the onboarding flow for SaxStart (Flutter app):

1. WelcomeScreen — 3-slide carousel with dot indicators
   - Slide 1: saxophone SVG icon, "Learn without feeling overwhelmed"
   - Slide 2: tool icons, "Practice with beginner-friendly tools"
   - Slide 3: progress graphic, "Track your progress every single day"
   - "Get Started" button → /onboarding/level
   - "Sign In" text button → Firebase Auth

2. LevelSelectScreen — choose your starting point
   - Title: "Where are you starting?"
   - 3 selectable cards: Absolute Beginner / Returning Player / School Band Starter
   - Selected card gets gold border
   - "Continue" button → /onboarding/goal

3. GoalSelectScreen — personalize experience
   - Title: "What's your main goal?"
   - 3 selectable cards: Learn first notes / Improve my tone / Daily practice habit
   - "Let's Go" button → saves to Riverpod state → navigates to /home

All screens use the dark theme. Background #0F0F0F. Gold button style.
Use Riverpod for state (OnboardingNotifier).
```

---

## Prompt 3 — Home Screen

```
Build the HomeScreen for SaxStart (Flutter app).

The screen is a scrollable column with these sections:

1. Header row
   - Left: greeting text ("Good evening") + user name below in Playfair Display
   - Right: 🔥 5 day streak badge chip

2. Continue Lesson card (AppCard with gold highlight)
   - Label: "CONTINUE LEARNING" (small uppercase)
   - Lesson title (bold)
   - Module info (muted, small)
   - Progress bar (35% filled)
   - GoldButton: "Resume Lesson →"

3. Daily Practice card
   - Title: "Today's Practice" + time badge ("10 min")
   - 3 task rows with status icons:
     - green checkmark = done
     - gold circle play = current
     - grey circle = upcoming
   - OutlineButton: "Start Drill Mode"

4. Quick Tools grid (2×2)
   - Tuner / Metronome / Fingering / Play Mode
   - Each is a dark card with emoji icon, name, short description
   - Tap navigates to the relevant screen

5. Stats row (3 stat boxes)
   - Lessons Done / Practice Time / Day Streak

Pull progress data from ProgressNotifier (Riverpod).
Pull current lesson from LessonNotifier.
```

---

## Prompt 4 — Learn Screen + Lesson Detail

```
Build the Learn screen and Lesson Detail screen for SaxStart.

LearnScreen:
- Title "Lessons" (Playfair Display)
- List of module cards. Each module shows:
  - Module number + title
  - X of Y complete
  - Status badge: Done (green) / In Progress (gold) / Locked (grey)
  - When tapped: expands to show lesson rows
- Lesson rows inside expanded module:
  - Lesson title + duration + difficulty
  - Green checkmark if complete
  - Gold arrow if current
  - Lock icon if locked
  - Tap unlocked lesson → LessonDetailScreen

LessonDetailScreen (receives lessonId):
- Back button + breadcrumb + duration badge
- Lesson title (large, Playfair Display)
- Short objective paragraph
- If noteReference is set: show fingering visual
  - Note name large, key diagram with pressed keys in gold
  - "Play sample" audio button
- Practice Steps list (numbered, with step status)
- Tip box (gold-tinted background)
- "Practice in Play Mode" button
- "Mark Complete" button → updates progress provider → pops back

Use LessonNotifier + ProgressNotifier from Riverpod.
Load lesson data from local content constants (no network needed).
```

---

## Prompt 5 — Tools Screen (Tuner + Metronome + Fingering)

```
Build the Tools screen for SaxStart. It's a single scrollable screen with 3 sections.

TUNER SECTION:
- Large detected note name (Playfair Display, gold)
- Status text: "Slightly flat" / "In tune ✓" / "Slightly sharp"
- Horizontal meter bar:
  - Red zone on left (flat)
  - Green zone in center (in tune)
  - Red zone on right (sharp)
  - Gold needle that moves based on centsDeviation
- "Start Listening" / "Stop Listening" GoldButton
- Integrate pitch_detector_dart
- Request microphone permission on first tap
- TunerNotifier (Riverpod) manages state

METRONOME SECTION:
- Large BPM number (Playfair Display)
- Circle that flashes gold on each beat
- 4 preset buttons: 60, 80, 100, 120 (selected = gold border)
- Horizontal BPM slider: 40–200
- Start/Stop GoldButton
- MetronomeNotifier (Riverpod) using Timer + audioplayers

FINGERING CHART SECTION:
- Note selector: horizontal scrollable row of note buttons (B A G C D E F ...)
  - B, A, G free | rest locked with lock icon for premium
- Fingering diagram: custom widget showing 7 key holes
  - Pressed keys filled gold, unpressed empty with grey border
- Note name large (Playfair Display)
- Tip text (muted)
- Play note button (plays local .mp3)

Use FingeringChartNotifier for selected note state.
```

---

## Prompt 6 — Play Mode + Drill Screen + Scoring

```
Build the Play Mode screens for SaxStart.

PlayScreen:
- Title "Play Mode"
- 3 drill mode cards:
  - "Tune the Note" — beginner — play a note and score pitch accuracy
  - "Hold It Steady" — beginner — sustain a note and score stability
  - "Follow the Pattern" — intermediate — play B→A→G sequence
- Best Scores section: show personal best for each drill type from Riverpod
- Tapping a drill → DrillScreen with drillType parameter

DrillScreen (3 phases):

Phase 1 — Ready:
- Drill type label (small uppercase)
- "Play this note" instruction
- Large target note name (Playfair Display, gold, 96px)
- Instruction text
- GoldButton "Start Listening" → Phase 2

Phase 2 — Listening:
- Pulsing circle animation (gold ring expanding outward, looping)
- "Listening... play your note now!" text
- Timer counts down (3 seconds for Tune, 4 for Hold)
- After timer: run scoring → Phase 3

Phase 3 — Score:
- Overall score large number (Playfair Display)
- 4 animated score bars: Pitch, Stability, Sustain, Attack
  - Bars animate from 0 to score on reveal
- Feedback tip card (gold-tinted background, one sentence)
- "Try Again" button → back to Phase 1
- "Done" button → back to PlayScreen
- Save result to DrillNotifier + Firestore session

Use DrillNotifier (Riverpod) to manage phase state and scoring.
Use ScoreCalculator from core/utils/score_calculator.dart.
Generate demo scores for now (real mic analysis in next iteration).
```

---

## Prompt 7 — Progress Screen

```
Build the Progress screen for SaxStart.

Sections:

1. Header: "Progress" title

2. Top stats row (3 boxes, no border, background-secondary):
   - Total Practice Time (in minutes)
   - Lessons Completed
   - Current Streak (with fire emoji)

3. "This Week" section:
   - 7 circles labeled M T W T F S S
   - Done days: gold fill
   - Today: bright gold
   - Future: empty dark
   - Pull streak dates from ProgressNotifier

4. "Module Progress" section:
   - One row per module
   - Module name + percentage label
   - AppProgressBar widget
   - Green bar for completed modules, gold for in-progress

5. "Achievements" section:
   - 2-column grid
   - Achievement cards with emoji icon, name, status
   - Earned: full opacity, green "Earned!" label
   - Not earned: 40% opacity, locked

Achievements list:
- 🎷 First Lesson (complete any lesson)
- 🔥 3-Day Streak
- ⏱ 30 Min Club (30+ total minutes)
- ⭐ First A Note (complete lesson 2.3)
- 🌟 First G Note (complete lesson 2.4)
- 🏆 7-Day Streak
- ✅ Module 2 Complete

Pull all data from ProgressNotifier (Riverpod).
```

---

## Prompt 8 — Firebase + Firestore Integration

```
Set up Firebase integration for SaxStart (Flutter).

1. AuthService:
   - Email/password sign up + sign in
   - Google Sign-In
   - Apple Sign-In (iOS)
   - Anonymous / guest sign in
   - Sign out
   - Auth state stream exposed via Riverpod

2. FirestoreService:
   - createUser(UserModel) — write to users/{uid}
   - getUser(uid) → UserModel
   - updateProgress(uid, ProgressModel)
   - getProgress(uid) → ProgressModel
   - saveSession(uid, PracticeSessionModel)
   - saveDrillResult(uid, DrillResultModel)

3. UserRepository:
   - Wraps FirestoreService
   - Handles null/not-found cases
   - Syncs with Hive local cache

4. ProgressRepository:
   - loadProgress(uid) — tries Firestore, falls back to Hive
   - saveProgress(uid, progress) — writes to both Firestore and Hive
   - incrementStreak() — calculates and updates streak
   - completeLesson(lessonId) — adds to completedLessonIds

5. Riverpod providers:
   - authStateProvider (StreamProvider)
   - currentUserProvider (FutureProvider)
   - progressProvider (StateNotifierProvider)

Use the schema from 04_DATABASE_SCHEMA.md.
All Firestore writes should be wrapped in try/catch with error state.
```

---

## Notes for Using These Prompts

- Run prompts one at a time in order
- After each prompt, test the screen before moving to the next
- Paste relevant sections of the .md files if Claude Code needs more context
- For audio features (tuner, metronome), test on a real device — simulators have limited mic support
- Use `flutter run --debug` on a physical iPhone or Android device for audio testing
