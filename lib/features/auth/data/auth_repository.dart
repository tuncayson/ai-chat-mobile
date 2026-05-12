import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Friendly typed exception thrown by [AuthRepository]. Wraps any error
/// coming back from Supabase's auth client and exposes a UI-ready message.
@immutable
class AuthException implements Exception {
  const AuthException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AuthException(${code ?? '-'}): $message';
}

/// Thin wrapper around Supabase's [supabase.GoTrueClient]. Centralises error
/// translation so the rest of the app only ever sees [AuthException].
class AuthRepository {
  AuthRepository(this._client);

  final supabase.GoTrueClient _client;

  supabase.Session? get currentSession => _client.currentSession;

  Stream<supabase.AuthState> get authStateChanges =>
      _client.onAuthStateChange;

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await _run(
      () => _client.signUp(email: email, password: password),
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _run(
      () =>
          _client.signInWithPassword(email: email, password: password),
    );
  }

  Future<void> signOut() => _run(_client.signOut);

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on supabase.AuthException catch (err) {
      throw AuthException(_messageFor(err), code: err.code);
    } on SocketException {
      throw const AuthException(
        'Network error. Please check your connection and try again.',
      );
    } on TimeoutException {
      throw const AuthException(
        'Request timed out. Please try again.',
      );
    } on Object catch (err) {
      throw AuthException('Something went wrong. Please try again. ($err)');
    }
  }

  String _messageFor(supabase.AuthException err) {
    switch (err.code) {
      case 'invalid_credentials':
      case 'invalid_grant':
        return 'Invalid email or password.';
      case 'user_already_exists':
      case 'email_exists':
      case 'email_address_taken':
        return 'An account already exists for that email.';
      case 'weak_password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email_not_confirmed':
        return 'Please confirm your email before signing in.';
      case 'over_email_send_rate_limit':
      case 'over_request_rate_limit':
        return 'Too many attempts. Please wait a minute and try again.';
      case 'signups_disabled':
        return 'Sign-ups are currently disabled.';
      case 'email_address_invalid':
        return 'Please enter a valid email address.';
    }

    // Fall back to message heuristics for older clients without codes.
    final lower = err.message.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'Invalid email or password.';
    }
    if (lower.contains('already registered') ||
        lower.contains('already exists')) {
      return 'An account already exists for that email.';
    }
    return err.message;
  }
}
