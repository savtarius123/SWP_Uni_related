// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingIdsHash() => r'6126100354188a11c157a3a8c9cca21bac4bbd04';

/// See also [settingIds].
@ProviderFor(settingIds)
final settingIdsProvider = AutoDisposeProvider<Iterable<String>>.internal(
  settingIds,
  name: r'settingIdsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$settingIdsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingIdsRef = AutoDisposeProviderRef<Iterable<String>>;
String _$settingsHash() => r'9892d9082301a6e115d9f911e188dd6e69aa3338';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$Settings extends BuildlessAutoDisposeAsyncNotifier<Setting?> {
  late final String settingId;

  FutureOr<Setting?> build(
    String settingId,
  );
}

/// See also [Settings].
@ProviderFor(Settings)
const settingsProvider = SettingsFamily();

/// See also [Settings].
class SettingsFamily extends Family<AsyncValue<Setting?>> {
  /// See also [Settings].
  const SettingsFamily();

  /// See also [Settings].
  SettingsProvider call(
    String settingId,
  ) {
    return SettingsProvider(
      settingId,
    );
  }

  @override
  SettingsProvider getProviderOverride(
    covariant SettingsProvider provider,
  ) {
    return call(
      provider.settingId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'settingsProvider';
}

/// See also [Settings].
class SettingsProvider
    extends AutoDisposeAsyncNotifierProviderImpl<Settings, Setting?> {
  /// See also [Settings].
  SettingsProvider(
    String settingId,
  ) : this._internal(
          () => Settings()..settingId = settingId,
          from: settingsProvider,
          name: r'settingsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$settingsHash,
          dependencies: SettingsFamily._dependencies,
          allTransitiveDependencies: SettingsFamily._allTransitiveDependencies,
          settingId: settingId,
        );

  SettingsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.settingId,
  }) : super.internal();

  final String settingId;

  @override
  FutureOr<Setting?> runNotifierBuild(
    covariant Settings notifier,
  ) {
    return notifier.build(
      settingId,
    );
  }

  @override
  Override overrideWith(Settings Function() create) {
    return ProviderOverride(
      origin: this,
      override: SettingsProvider._internal(
        () => create()..settingId = settingId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        settingId: settingId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<Settings, Setting?> createElement() {
    return _SettingsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SettingsProvider && other.settingId == settingId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, settingId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SettingsRef on AutoDisposeAsyncNotifierProviderRef<Setting?> {
  /// The parameter `settingId` of this provider.
  String get settingId;
}

class _SettingsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<Settings, Setting?>
    with SettingsRef {
  _SettingsProviderElement(super.provider);

  @override
  String get settingId => (origin as SettingsProvider).settingId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
