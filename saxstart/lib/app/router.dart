import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/onboarding/screens/welcome_screen.dart';
import '../features/onboarding/screens/level_select_screen.dart';
import '../features/onboarding/screens/goal_select_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/learn/screens/learn_screen.dart';
import '../features/learn/screens/lesson_detail_screen.dart';
import '../features/play/screens/play_screen.dart';
import '../features/play/screens/drill_screen.dart';
import '../features/tools/screens/tools_screen.dart';
import '../features/progress/screens/progress_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/auth/screens/auth_screen.dart';
import '../shared/widgets/main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/welcome',
  routes: [
    // Onboarding routes (no bottom nav)
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/onboarding/level',
      builder: (context, state) => const LevelSelectScreen(),
    ),
    GoRoute(
      path: '/onboarding/goal',
      builder: (context, state) => const GoalSelectScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),

    // Main app shell with bottom navigation
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/learn',
          builder: (context, state) => const LearnScreen(),
          routes: [
            GoRoute(
              path: ':moduleId/:lessonId',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => LessonDetailScreen(
                moduleId: state.pathParameters['moduleId']!,
                lessonId: state.pathParameters['lessonId']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/play',
          builder: (context, state) => const PlayScreen(),
          routes: [
            GoRoute(
              path: 'drill',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) {
                final extra = state.extra as Map<String, String>?;
                return DrillScreen(
                  drillType: extra?['drillType'] ?? 'tune',
                  targetNote: extra?['targetNote'] ?? 'B4',
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/tools',
          builder: (context, state) => const ToolsScreen(),
        ),
        GoRoute(
          path: '/progress',
          builder: (context, state) => const ProgressScreen(),
        ),
      ],
    ),
  ],
);
