import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? displayName;
  final bool isGuest;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.userId,
    this.email,
    this.displayName,
    this.isGuest = false,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? displayName,
    bool? isGuest,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isGuest: isGuest ?? this.isGuest,
      errorMessage: errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;

  factory AuthState.fromFirebaseUser(User? user) {
    if (user == null) {
      return const AuthState(status: AuthStatus.unauthenticated);
    }
    return AuthState(
      status: AuthStatus.authenticated,
      userId: user.uid,
      email: user.email,
      displayName: user.displayName ?? user.email?.split('@').first ?? 'Saxophonist',
      isGuest: user.isAnonymous,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth;

  AuthNotifier({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance,
        super(const AuthState(status: AuthStatus.unknown)) {
    // Listen to Firebase auth state changes
    _auth.authStateChanges().listen((user) {
      state = AuthState.fromFirebaseUser(user);
    });
  }

  /// Sign in with email/password
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.unknown, errorMessage: null);
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: _friendlyError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Sign in failed. Please try again.',
      );
      return false;
    }
  }

  /// Sign up with email/password
  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.unknown, errorMessage: null);
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: _friendlyError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Sign up failed. Please try again.',
      );
      return false;
    }
  }

  /// Sign in with Google (requires google_sign_in package)
  /// TODO: Add google_sign_in integration
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(
      errorMessage: 'Google Sign-In coming soon. Use email/password for now.',
    );
    return false;
  }

  /// Sign in with Apple (iOS only, requires sign_in_with_apple)
  /// TODO: Add sign_in_with_apple integration
  Future<bool> signInWithApple() async {
    state = state.copyWith(
      errorMessage: 'Apple Sign-In coming soon. Use email/password for now.',
    );
    return false;
  }

  /// Continue as guest (anonymous auth)
  Future<bool> continueAsGuest() async {
    try {
      state = state.copyWith(status: AuthStatus.unknown, errorMessage: null);
      await _auth.signInAnonymously();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Could not start guest session.',
      );
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Check your network.';
      case 'too-many-requests':
        return 'Too many attempts. Try again in a minute.';
      default:
        return e.message ?? 'Authentication error.';
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

/// Stream of the raw Firebase user, for reactive UI
final firebaseUserStreamProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);
