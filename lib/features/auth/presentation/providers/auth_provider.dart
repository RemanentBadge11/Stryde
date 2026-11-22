import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:stryde/core/supabase/supabase_client.dart';

/// The Supabase client used across the app.
final supabaseProvider = Provider<SupabaseClient?>((_) => supabaseClientOrNull);

/// Emits the current session every time the auth state changes.
final sessionProvider = StreamProvider<Session?>((ref) async* {
  final auth = ref.read(supabaseProvider)?.auth;
  if (auth == null) {
    yield null;
    return;
  }
  yield auth.currentSession;
  yield* auth.onAuthStateChange.map((event) => event.session);
});

/// The currently signed-in user, or `null` when there is no active session.
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(sessionProvider).value?.user ??
      ref.read(supabaseProvider)?.auth.currentUser;
});

/// Holds an authentication error message surfaced in the UI.
class AuthNotifierState {
  const AuthNotifierState({this.errorMessage});

  final String? errorMessage;

  AuthNotifierState copyWith({String? errorMessage}) {
    return AuthNotifierState(errorMessage: errorMessage ?? this.errorMessage);
  }
}

/// Coordinates signing in, signing up and signing out.
///
/// Errors from Supabase are caught and stored in [AuthNotifierState.errorMessage]
/// so the UI can show red error text under the fields instead of crashing.
class AuthNotifier extends Notifier<AuthNotifierState> {
  @override
  AuthNotifierState build() => const AuthNotifierState();

  SupabaseClient? get _client => ref.read(supabaseProvider);

  /// Sign in with email and password.
  Future<bool> signIn({required String email, required String password}) async {
    state = const AuthNotifierState();
    final client = _client;
    if (client == null) {
      state = state.copyWith(errorMessage: 'Authentication is unavailable.');
      return false;
    }
    try {
      await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return true;
    } on AuthException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Unable to log in right now. Please try again.',
      );
      return false;
    }
  }

  /// Sign up with email, password and a username stored in user metadata.
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    state = const AuthNotifierState();
    final client = _client;
    if (client == null) {
      state = state.copyWith(errorMessage: 'Authentication is unavailable.');
      return false;
    }
    try {
      await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: <String, dynamic>{'username': username.trim()},
      );
      return true;
    } on AuthException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Unable to create your account. Please try again.',
      );
      return false;
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = const AuthNotifierState();
    }
  }

  /// Sign out and clear local error state.
  Future<bool> signOut() async {
    state = const AuthNotifierState();
    final client = _client;
    if (client == null) {
      state = state.copyWith(errorMessage: 'Authentication is unavailable.');
      return false;
    }

    try {
      await client.auth.signOut();
      return true;
    } on AuthException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Unable to log out right now. Please try again.',
      );
      return false;
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthNotifierState>(
  AuthNotifier.new,
);
