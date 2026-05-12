// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the app-wide [SharedPreferences] handle. Must be overridden in
/// `main()` with `sharedPreferencesProvider.overrideWithValue(prefs)` so
/// providers that depend on it (e.g. theme persistence) can read prefs
/// synchronously — no first-frame flash from late async loads.

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Holds the app-wide [SharedPreferences] handle. Must be overridden in
/// `main()` with `sharedPreferencesProvider.overrideWithValue(prefs)` so
/// providers that depend on it (e.g. theme persistence) can read prefs
/// synchronously — no first-frame flash from late async loads.

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
  /// Holds the app-wide [SharedPreferences] handle. Must be overridden in
  /// `main()` with `sharedPreferencesProvider.overrideWithValue(prefs)` so
  /// providers that depend on it (e.g. theme persistence) can read prefs
  /// synchronously — no first-frame flash from late async loads.
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'53060c5d972c84e42341644d3e2ebfd536bbe0a4';
