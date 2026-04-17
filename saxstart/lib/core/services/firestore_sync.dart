import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/drill_result_model.dart';
import '../../data/models/progress_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../../features/play/providers/drill_provider.dart';
import '../../features/progress/providers/progress_provider.dart';
import 'auth_service.dart';

/// Encapsulates all Firestore sync logic:
/// - On sign-in: loads progress + drill history from Firestore and
///   hydrates in-memory providers.
/// - On progress changes: debounced save back to Firestore.
/// - On new drill result: immediate save to drill_scores subcollection.
class FirestoreSync {
  final Ref ref;

  Timer? _progressDebounce;
  String? _currentUid;
  bool _hydrated = false;
  DrillResultModel? _lastSavedDrill;

  FirestoreSync(this.ref) {
    // React to auth changes
    ref.listen<AuthState>(authProvider, (prev, next) {
      _onAuthChanged(prev, next);
    }, fireImmediately: true);

    // React to progress changes (debounced write)
    ref.listen<ProgressModel>(progressProvider, (prev, next) {
      if (_hydrated && _currentUid != null && prev != next) {
        _scheduleProgressSave(next);
      }
    });

    // React to new drill results
    ref.listen<DrillState>(drillProvider, (prev, next) {
      if (_hydrated &&
          _currentUid != null &&
          next.recentResults.isNotEmpty &&
          next.recentResults.first != _lastSavedDrill &&
          next.recentResults.first != (prev?.recentResults.firstOrNull)) {
        _saveNewDrill(next.recentResults.first);
      }
    });
  }

  Future<void> _onAuthChanged(AuthState? prev, AuthState next) async {
    if (next.isAuthenticated && next.userId != null) {
      if (_currentUid == next.userId) return; // already hydrated
      _currentUid = next.userId;
      await _hydrateFromFirestore(next.userId!);
    } else {
      // Signed out — reset local state
      _currentUid = null;
      _hydrated = false;
      _progressDebounce?.cancel();
      ref.read(progressProvider.notifier).reset();
      ref.read(drillProvider.notifier).reset();
    }
  }

  Future<void> _hydrateFromFirestore(String uid) async {
    try {
      // Load progress
      final progress =
          await ref.read(progressRepositoryProvider).loadProgress(uid);
      ref.read(progressProvider.notifier).hydrate(progress);

      // Load recent drill scores
      final scores =
          await ref.read(sessionRepositoryProvider).getDrillScores(uid);
      ref.read(drillProvider.notifier).hydrate(scores);

      _hydrated = true;
    } catch (e) {
      // Network offline or rules deny — keep defaults, allow future writes
      _hydrated = true;
    }
  }

  void _scheduleProgressSave(ProgressModel progress) {
    _progressDebounce?.cancel();
    _progressDebounce = Timer(const Duration(milliseconds: 800), () async {
      final uid = _currentUid;
      if (uid == null) return;
      try {
        await ref.read(progressRepositoryProvider).saveProgress(uid, progress);
      } catch (_) {
        // Silent fail — next change will retry
      }
    });
  }

  Future<void> _saveNewDrill(DrillResultModel result) async {
    final uid = _currentUid;
    if (uid == null) return;
    _lastSavedDrill = result;
    try {
      await ref.read(sessionRepositoryProvider).saveDrillResult(uid, result);
    } catch (_) {
      // Silent fail
    }
  }

}

/// Call at the end of onboarding or auth to upsert the user document.
/// Works with either `Ref` (provider) or `WidgetRef` (widget) via the
/// shared `Refena`-compatible readers.
Future<void> createUserOnOnboardingComplete({
  required AuthState auth,
  required OnboardingState onboarding,
  required UserRepository userRepo,
  required ProgressRepository progressRepo,
}) async {
  if (!auth.isAuthenticated || auth.userId == null) return;

  final user = UserModel(
    id: auth.userId!,
    name: auth.displayName ?? 'Saxophonist',
    email: auth.email ?? '',
    level: onboarding.level ?? 'beginner',
    goal: onboarding.goal ?? 'first_notes',
    createdAt: DateTime.now(),
    lastActiveAt: DateTime.now(),
  );

  try {
    await userRepo.createUser(user);
    // Also seed an empty progress document
    await progressRepo.saveProgress(auth.userId!, const ProgressModel());
  } catch (_) {
    // Silent fail — next login will retry creation via getOrCreateUser
  }
}

/// Provider that constructs the sync controller once and keeps it alive
/// for the lifetime of the app.
final firestoreSyncProvider = Provider<FirestoreSync>((ref) {
  return FirestoreSync(ref);
});
