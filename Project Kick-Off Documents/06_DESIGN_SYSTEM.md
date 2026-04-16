# SaxStart — UI Design System

## Design Direction

**Aesthetic:** Luxury dark — premium music tool, not a kids app  
**Feel:** Like a high-end instrument in app form  
**Mood:** Focused, calm, musical, slightly luxurious

---

## Color Palette

```dart
// lib/app/theme/app_colors.dart

class AppColors {
  // Backgrounds
  static const Color background       = Color(0xFF0F0F0F); // near black
  static const Color surface          = Color(0xFF1A1A1A); // card bg
  static const Color surfaceElevated  = Color(0xFF222222); // raised card
  static const Color surface2         = Color(0xFF252525); // inner card

  // Brand
  static const Color gold             = Color(0xFFC9963A); // primary accent
  static const Color goldLight        = Color(0xFFE8B84B); // bright gold
  static const Color cream            = Color(0xFFF5EDD6); // headings

  // Semantic
  static const Color success          = Color(0xFF4CAF7D); // green
  static const Color error            = Color(0xFFE05C5C); // red/warning
  static const Color warning          = Color(0xFFE8A84B); // amber

  // Text
  static const Color textPrimary      = Color(0xFFF0EAD6); // main text
  static const Color textSecondary    = Color(0xFF888888); // muted text
  static const Color textDisabled     = Color(0xFF555555); // locked

  // Borders
  static const Color borderGold       = Color(0x26C9963A); // gold 15% opacity
  static const Color borderSubtle     = Color(0x0AFFFFFF); // white 4% opacity
}
```

---

## Typography

```dart
// lib/app/theme/app_typography.dart

// Fonts used:
// - DM Sans (body, UI) — clean, modern, readable
// - Playfair Display (display, headings) — musical, elegant

class AppTypography {
  // Display — used for note names, scores, module titles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 64,
    fontWeight: FontWeight.w700,
    color: AppColors.goldLight,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.cream,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.cream,
  );

  // Body — used for everything else
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}
```

---

## Theme Setup

```dart
// lib/app/theme/app_theme.dart

ThemeData get darkTheme => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.gold,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.gold,
    secondary: AppColors.goldLight,
    surface: AppColors.surface,
    background: AppColors.background,
    error: AppColors.error,
  ),
  fontFamily: 'DMSans',
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.cream,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.gold,
    unselectedItemColor: AppColors.textSecondary,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
  cardTheme: CardTheme(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.borderGold, width: 1),
    ),
  ),
);
```

---

## Shared Components

### GoldButton

```dart
// lib/shared/widgets/gold_button.dart

class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const GoldButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: const Color(0xFF1A0F00),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A0F00)),
              )
            : Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
```

### AppCard

```dart
// lib/shared/widgets/app_card.dart

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool highlighted; // gold border accent

  const AppCard({
    required this.child,
    this.padding,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted
            ? const Color(0xFF1E1700)   // warm dark for highlighted cards
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted
              ? AppColors.gold.withOpacity(0.4)
              : AppColors.borderGold,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
```

### BadgeChip

```dart
// lib/shared/widgets/badge_chip.dart

enum BadgeType { gold, green, muted }

class BadgeChip extends StatelessWidget {
  final String label;
  final BadgeType type;

  const BadgeChip({required this.label, this.type = BadgeType.gold});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color text;

    switch (type) {
      case BadgeType.gold:
        bg = AppColors.gold.withOpacity(0.15);
        text = AppColors.goldLight;
      case BadgeType.green:
        bg = AppColors.success.withOpacity(0.15);
        text = AppColors.success;
      case BadgeType.muted:
        bg = Colors.white.withOpacity(0.06);
        text = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: text)),
    );
  }
}
```

### ProgressBar

```dart
// lib/shared/widgets/progress_bar.dart

class AppProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color? color;
  final double height;

  const AppProgressBar({
    required this.value,
    this.color,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color ?? AppColors.gold, color ?? AppColors.goldLight],
            ),
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}
```

---

## Section Label Style

Use this pattern consistently throughout the app:

```dart
// Section labels (uppercase, spaced)
Text(
  'QUICK TOOLS',
  style: AppTypography.label, // 11px, uppercase, letter-spacing 1.5
)
```

---

## Spacing System

```
4px  — micro gap (icon to text)
8px  — small gap (related items)
12px — default item gap
16px — card internal padding
20px — screen horizontal padding
24px — section gap
32px — large section gap
```

---

## Assets Folder Structure

```
assets/
├── audio/
│   ├── metro_tick.wav
│   └── notes/
│       ├── note_b4.mp3
│       ├── note_a4.mp3
│       ├── note_g4.mp3
│       ├── note_c4.mp3
│       └── note_d4.mp3
├── images/
│   ├── logo.svg
│   ├── sax_icon.svg
│   └── onboarding/
│       ├── slide_1.png
│       ├── slide_2.png
│       └── slide_3.png
└── animations/
    └── achievement_unlock.json  (Lottie)
```

---

## pubspec.yaml Assets Declaration

```yaml
flutter:
  fonts:
    - family: DMSans
      fonts:
        - asset: assets/fonts/DMSans-Regular.ttf
          weight: 400
        - asset: assets/fonts/DMSans-Medium.ttf
          weight: 500
        - asset: assets/fonts/DMSans-SemiBold.ttf
          weight: 600
    - family: PlayfairDisplay
      fonts:
        - asset: assets/fonts/PlayfairDisplay-Bold.ttf
          weight: 700

  assets:
    - assets/audio/
    - assets/audio/notes/
    - assets/images/
    - assets/images/onboarding/
    - assets/animations/
```
