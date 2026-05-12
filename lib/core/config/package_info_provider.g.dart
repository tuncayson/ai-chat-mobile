// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Lazily loads [PackageInfo] from the platform. Read with
/// `ref.watch(packageInfoProvider)` and handle the `AsyncValue` —
/// the value is cached for the app's lifetime once resolved.

@ProviderFor(packageInfo)
final packageInfoProvider = PackageInfoProvider._();

/// Lazily loads [PackageInfo] from the platform. Read with
/// `ref.watch(packageInfoProvider)` and handle the `AsyncValue` —
/// the value is cached for the app's lifetime once resolved.

final class PackageInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<PackageInfo>,
          PackageInfo,
          FutureOr<PackageInfo>
        >
    with $FutureModifier<PackageInfo>, $FutureProvider<PackageInfo> {
  /// Lazily loads [PackageInfo] from the platform. Read with
  /// `ref.watch(packageInfoProvider)` and handle the `AsyncValue` —
  /// the value is cached for the app's lifetime once resolved.
  PackageInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'packageInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$packageInfoHash();

  @$internal
  @override
  $FutureProviderElement<PackageInfo> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PackageInfo> create(Ref ref) {
    return packageInfo(ref);
  }
}

String _$packageInfoHash() => r'cc57db7b4684ab0d5df0f050b8ea045a3658e89a';
