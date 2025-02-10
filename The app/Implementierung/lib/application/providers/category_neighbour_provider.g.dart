// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_neighbour_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hwCategoriesHash() => r'010d9f39e6393783e8e9011172c9bc423599337e';

/// Provides a list of [HwCategory] elements, depending on available
/// [SensorTimeSeries].
///
/// Copied from [HwCategories].
@ProviderFor(HwCategories)
final hwCategoriesProvider =
    AutoDisposeNotifierProvider<HwCategories, List<HwCategory>>.internal(
  HwCategories.new,
  name: r'hwCategoriesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$hwCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HwCategories = AutoDisposeNotifier<List<HwCategory>>;
String _$hwCategoryInstancesHash() =>
    r'55afdcfa49e31a957511155503ca654605459dd6';

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

abstract class _$HwCategoryInstances
    extends BuildlessAutoDisposeNotifier<List<int>> {
  late final HwCategory? hwCategory;

  List<int> build({
    HwCategory? hwCategory,
  });
}

/// Takes a selected [HwCategory] and returns available instances of said Category.
///
/// Copied from [HwCategoryInstances].
@ProviderFor(HwCategoryInstances)
const hwCategoryInstancesProvider = HwCategoryInstancesFamily();

/// Takes a selected [HwCategory] and returns available instances of said Category.
///
/// Copied from [HwCategoryInstances].
class HwCategoryInstancesFamily extends Family<List<int>> {
  /// Takes a selected [HwCategory] and returns available instances of said Category.
  ///
  /// Copied from [HwCategoryInstances].
  const HwCategoryInstancesFamily();

  /// Takes a selected [HwCategory] and returns available instances of said Category.
  ///
  /// Copied from [HwCategoryInstances].
  HwCategoryInstancesProvider call({
    HwCategory? hwCategory,
  }) {
    return HwCategoryInstancesProvider(
      hwCategory: hwCategory,
    );
  }

  @override
  HwCategoryInstancesProvider getProviderOverride(
    covariant HwCategoryInstancesProvider provider,
  ) {
    return call(
      hwCategory: provider.hwCategory,
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
  String? get name => r'hwCategoryInstancesProvider';
}

/// Takes a selected [HwCategory] and returns available instances of said Category.
///
/// Copied from [HwCategoryInstances].
class HwCategoryInstancesProvider
    extends AutoDisposeNotifierProviderImpl<HwCategoryInstances, List<int>> {
  /// Takes a selected [HwCategory] and returns available instances of said Category.
  ///
  /// Copied from [HwCategoryInstances].
  HwCategoryInstancesProvider({
    HwCategory? hwCategory,
  }) : this._internal(
          () => HwCategoryInstances()..hwCategory = hwCategory,
          from: hwCategoryInstancesProvider,
          name: r'hwCategoryInstancesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$hwCategoryInstancesHash,
          dependencies: HwCategoryInstancesFamily._dependencies,
          allTransitiveDependencies:
              HwCategoryInstancesFamily._allTransitiveDependencies,
          hwCategory: hwCategory,
        );

  HwCategoryInstancesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.hwCategory,
  }) : super.internal();

  final HwCategory? hwCategory;

  @override
  List<int> runNotifierBuild(
    covariant HwCategoryInstances notifier,
  ) {
    return notifier.build(
      hwCategory: hwCategory,
    );
  }

  @override
  Override overrideWith(HwCategoryInstances Function() create) {
    return ProviderOverride(
      origin: this,
      override: HwCategoryInstancesProvider._internal(
        () => create()..hwCategory = hwCategory,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        hwCategory: hwCategory,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<HwCategoryInstances, List<int>>
      createElement() {
    return _HwCategoryInstancesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HwCategoryInstancesProvider &&
        other.hwCategory == hwCategory;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, hwCategory.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HwCategoryInstancesRef on AutoDisposeNotifierProviderRef<List<int>> {
  /// The parameter `hwCategory` of this provider.
  HwCategory? get hwCategory;
}

class _HwCategoryInstancesProviderElement
    extends AutoDisposeNotifierProviderElement<HwCategoryInstances, List<int>>
    with HwCategoryInstancesRef {
  _HwCategoryInstancesProviderElement(super.provider);

  @override
  HwCategory? get hwCategory =>
      (origin as HwCategoryInstancesProvider).hwCategory;
}

String _$displayGroupsHash() => r'adc46d4a46501ad909f971dcd368d17dfe39beea';

abstract class _$DisplayGroups
    extends BuildlessAutoDisposeNotifier<List<DisplayGroup>> {
  late final HwCategory? hwCategory;
  late final int? hwCategoryInstance;

  List<DisplayGroup> build({
    HwCategory? hwCategory,
    int? hwCategoryInstance,
  });
}

/// Takes a selected [HwCategory] and a selected Instance and returns a list of
/// [DisplayGroup] for all available topics.
///
/// Copied from [DisplayGroups].
@ProviderFor(DisplayGroups)
const displayGroupsProvider = DisplayGroupsFamily();

/// Takes a selected [HwCategory] and a selected Instance and returns a list of
/// [DisplayGroup] for all available topics.
///
/// Copied from [DisplayGroups].
class DisplayGroupsFamily extends Family<List<DisplayGroup>> {
  /// Takes a selected [HwCategory] and a selected Instance and returns a list of
  /// [DisplayGroup] for all available topics.
  ///
  /// Copied from [DisplayGroups].
  const DisplayGroupsFamily();

  /// Takes a selected [HwCategory] and a selected Instance and returns a list of
  /// [DisplayGroup] for all available topics.
  ///
  /// Copied from [DisplayGroups].
  DisplayGroupsProvider call({
    HwCategory? hwCategory,
    int? hwCategoryInstance,
  }) {
    return DisplayGroupsProvider(
      hwCategory: hwCategory,
      hwCategoryInstance: hwCategoryInstance,
    );
  }

  @override
  DisplayGroupsProvider getProviderOverride(
    covariant DisplayGroupsProvider provider,
  ) {
    return call(
      hwCategory: provider.hwCategory,
      hwCategoryInstance: provider.hwCategoryInstance,
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
  String? get name => r'displayGroupsProvider';
}

/// Takes a selected [HwCategory] and a selected Instance and returns a list of
/// [DisplayGroup] for all available topics.
///
/// Copied from [DisplayGroups].
class DisplayGroupsProvider
    extends AutoDisposeNotifierProviderImpl<DisplayGroups, List<DisplayGroup>> {
  /// Takes a selected [HwCategory] and a selected Instance and returns a list of
  /// [DisplayGroup] for all available topics.
  ///
  /// Copied from [DisplayGroups].
  DisplayGroupsProvider({
    HwCategory? hwCategory,
    int? hwCategoryInstance,
  }) : this._internal(
          () => DisplayGroups()
            ..hwCategory = hwCategory
            ..hwCategoryInstance = hwCategoryInstance,
          from: displayGroupsProvider,
          name: r'displayGroupsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$displayGroupsHash,
          dependencies: DisplayGroupsFamily._dependencies,
          allTransitiveDependencies:
              DisplayGroupsFamily._allTransitiveDependencies,
          hwCategory: hwCategory,
          hwCategoryInstance: hwCategoryInstance,
        );

  DisplayGroupsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.hwCategory,
    required this.hwCategoryInstance,
  }) : super.internal();

  final HwCategory? hwCategory;
  final int? hwCategoryInstance;

  @override
  List<DisplayGroup> runNotifierBuild(
    covariant DisplayGroups notifier,
  ) {
    return notifier.build(
      hwCategory: hwCategory,
      hwCategoryInstance: hwCategoryInstance,
    );
  }

  @override
  Override overrideWith(DisplayGroups Function() create) {
    return ProviderOverride(
      origin: this,
      override: DisplayGroupsProvider._internal(
        () => create()
          ..hwCategory = hwCategory
          ..hwCategoryInstance = hwCategoryInstance,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        hwCategory: hwCategory,
        hwCategoryInstance: hwCategoryInstance,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<DisplayGroups, List<DisplayGroup>>
      createElement() {
    return _DisplayGroupsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DisplayGroupsProvider &&
        other.hwCategory == hwCategory &&
        other.hwCategoryInstance == hwCategoryInstance;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, hwCategory.hashCode);
    hash = _SystemHash.combine(hash, hwCategoryInstance.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DisplayGroupsRef on AutoDisposeNotifierProviderRef<List<DisplayGroup>> {
  /// The parameter `hwCategory` of this provider.
  HwCategory? get hwCategory;

  /// The parameter `hwCategoryInstance` of this provider.
  int? get hwCategoryInstance;
}

class _DisplayGroupsProviderElement extends AutoDisposeNotifierProviderElement<
    DisplayGroups, List<DisplayGroup>> with DisplayGroupsRef {
  _DisplayGroupsProviderElement(super.provider);

  @override
  HwCategory? get hwCategory => (origin as DisplayGroupsProvider).hwCategory;
  @override
  int? get hwCategoryInstance =>
      (origin as DisplayGroupsProvider).hwCategoryInstance;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
