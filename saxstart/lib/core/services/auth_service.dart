import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Auth state representation (works without Firebase for now)
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? displayName;
  final bool isGuest;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.userId,
    this.email,
    this.displayName,
    this.isGuest = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? displayName,
    bool? isGuest,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(status: AuthStatus.unauthenticated));

  /// Sign in with email/password
  /// TODO: Replace with Firebase Auth
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.unknown);
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      state = AuthState(
        status: AuthStatus.authenticated,
        userId: 'local_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@').first,
      );
      return true;
    } catch (e) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return false;
    }
  }

  /// Sign up with email/password
  Future<bool> signUpWithEmail(String email, String password) async {
    return signInWithEmail(email, password);
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    // TODO: Implement Google Sign-In
    state = AuthState(
      status: AuthStatus.authenticated,
      userId: 'google_${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'Google User',
    );
    return true;
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    // TODO: Implement Apple Sign-In
    state = AuthState(
      status: AuthStatus.authenticated,
      userId: 'apple_${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'Apple User',
    );
    return true;
  }

  /// Continue as guest
  void continueAsGuest() {
    state = AuthState(
      status: AuthStatus.authenticated,
      userId: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'Saxophonist',
      isGuest: true,
    );
  }

  /// Sign out
  void signOut() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
