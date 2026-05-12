import 'package:flutter/foundation.dart';

/// Build-time configuration. Values are injected via `--dart-define`:
///
/// ```sh
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xyz.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=eyJ...
/// ```
@immutable
abstract final class Env {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// Asserts that every required env var has been provided. Assertions only
  /// run in debug mode, so this surfaces misconfiguration early during
  /// development without affecting release builds.
  static void assertConfigured() {
    assert(
      supabaseUrl.isNotEmpty,
      'SUPABASE_URL is empty. Pass it via '
      '--dart-define=SUPABASE_URL=https://<project>.supabase.co',
    );
    assert(
      supabaseAnonKey.isNotEmpty,
      'SUPABASE_ANON_KEY is empty. Pass it via '
      '--dart-define=SUPABASE_ANON_KEY=<key>',
    );
  }
}
