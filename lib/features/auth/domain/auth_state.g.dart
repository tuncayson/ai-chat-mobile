// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Singleton wrapper around Supabase's auth client.

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// Singleton wrapper around Supabase's auth client.

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Singleton wrapper around Supabase's auth client.
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'9d10f0fc5d503a8c7172b25af76887f1679b9bee';

/// Stream of Supabase auth state changes (sign-in, sign-out, token refresh).

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// Stream of Supabase auth state changes (sign-in, sign-out, token refresh).

final class AuthStateProvider
    extends
        $FunctionalProvider<AsyncValue<AuthState>, AuthState, Stream<AuthState>>
    with $FutureModifier<AuthState>, $StreamProvider<AuthState> {
  /// Stream of Supabase auth state changes (sign-in, sign-out, token refresh).
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<AuthState> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AuthState> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'ebf8e79f36ad3e615d407720e5fa9e232784ef8a';

/// The currently authenticated user, or null if signed out. Derived from
/// [authStateProvider] and falls back to the persisted session so it has a
/// value on cold start before the stream has emitted.

@ProviderFor(currentUser)
final currentUserProvider = CurrentUserProvider._();

/// The currently authenticated user, or null if signed out. Derived from
/// [authStateProvider] and falls back to the persisted session so it has a
/// value on cold start before the stream has emitted.

final class CurrentUserProvider extends $FunctionalProvider<User?, User?, User?>
    with $Provider<User?> {
  /// The currently authenticated user, or null if signed out. Derived from
  /// [authStateProvider] and falls back to the persisted session so it has a
  /// value on cold start before the stream has emitted.
  CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  $ProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  User? create(Ref ref) {
    return currentUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(User? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<User?>(value),
    );
  }
}

String _$currentUserHash() => r'952337ac325b1f69a332d9539ec5b2303a69a606';
