// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App-wide [GoRouter]. The router instance is built once and shared via
/// Riverpod; auth-driven redirects are triggered by a [Listenable] that
/// fires whenever [currentUserProvider] changes — the router itself is
/// never recreated, so navigation history is preserved across sign-ins
/// and sign-outs.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// App-wide [GoRouter]. The router instance is built once and shared via
/// Riverpod; auth-driven redirects are triggered by a [Listenable] that
/// fires whenever [currentUserProvider] changes — the router itself is
/// never recreated, so navigation history is preserved across sign-ins
/// and sign-outs.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// App-wide [GoRouter]. The router instance is built once and shared via
  /// Riverpod; auth-driven redirects are triggered by a [Listenable] that
  /// fires whenever [currentUserProvider] changes — the router itself is
  /// never recreated, so navigation history is preserved across sign-ins
  /// and sign-outs.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'd6a78276313da75811bd071bca28fdb9df2fa5bb';
