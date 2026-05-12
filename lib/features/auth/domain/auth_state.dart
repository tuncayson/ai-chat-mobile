import 'package:ai_chat_mobile/features/auth/data/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthState, Supabase, User;

part 'auth_state.g.dart';

/// Singleton wrapper around Supabase's auth client.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(Supabase.instance.client.auth);
}

/// Stream of Supabase auth state changes (sign-in, sign-out, token refresh).
@Riverpod(keepAlive: true)
Stream<AuthState> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

/// The currently authenticated user, or null if signed out. Derived from
/// [authStateProvider] and falls back to the persisted session so it has a
/// value on cold start before the stream has emitted.
@riverpod
User? currentUser(Ref ref) {
  final asyncAuth = ref.watch(authStateProvider);
  final fromStream = switch (asyncAuth) {
    AsyncData(:final value) => value.session?.user,
    _ => null,
  };
  if (fromStream != null) {
    return fromStream;
  }
  return ref.watch(authRepositoryProvider).currentSession?.user;
}
