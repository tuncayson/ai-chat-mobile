import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

/// Holds the app-wide [SharedPreferences] handle. Must be overridden in
/// `main()` with `sharedPreferencesProvider.overrideWithValue(prefs)` so
/// providers that depend on it (e.g. theme persistence) can read prefs
/// synchronously — no first-frame flash from late async loads.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider was not overridden — '
    'did main() forget to await SharedPreferences.getInstance()?',
  );
}
