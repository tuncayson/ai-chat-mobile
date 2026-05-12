import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'package_info_provider.g.dart';

/// Lazily loads [PackageInfo] from the platform. Read with
/// `ref.watch(packageInfoProvider)` and handle the `AsyncValue` —
/// the value is cached for the app's lifetime once resolved.
@Riverpod(keepAlive: true)
Future<PackageInfo> packageInfo(Ref ref) {
  return PackageInfo.fromPlatform();
}
