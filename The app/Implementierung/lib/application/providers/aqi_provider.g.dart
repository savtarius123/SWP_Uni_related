// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aqi_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aqiHash() => r'c219dcb6dddf2ee0f800a75011f917120fa37d6c';

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

/// Provides historical Air Quality Data as a [TimeSeries].
/// For the interplay of [onlyNotifyOnChangedHistory] and [aqiCurrent] refer
/// to the documentation for [TimeSeriesAverages].
/// The keepAlive is necessary here because the recalculation of the AQI is
/// rather expensive and should be cached whenever possible.
///
/// Copied from [aqi].
@ProviderFor(aqi)
const aqiProvider = AqiFamily();

/// Provides historical Air Quality Data as a [TimeSeries].
/// For the interplay of [onlyNotifyOnChangedHistory] and [aqiCurrent] refer
/// to the documentation for [TimeSeriesAverages].
/// The keepAlive is necessary here because the recalculation of the AQI is
/// rather expensive and should be cached whenever possible.
///
/// Copied from [aqi].
class AqiFamily extends Family<TimeSeries?> {
  /// Provides historical Air Quality Data as a [TimeSeries].
  /// For the interplay of [onlyNotifyOnChangedHistory] and [aqiCurrent] refer
  /// to the documentation for [TimeSeriesAverages].
  /// The keepAlive is necessary here because the recalculation of the AQI is
  /// rather expensive and should be cached whenever possible.
  ///
  /// Copied from [aqi].
  const AqiFamily();

  /// Provides historical Air Quality Data as a [TimeSeries].
  /// For the interplay of [onlyNotifyOnChangedHistory] and [aqiCurrent] refer
  /// to the documentation for [TimeSeriesAverages].
  /// The keepAlive is necessary here because the recalculation of the AQI is
  /// rather expensive and should be cached whenever possible.
  ///
  /// Copied from [aqi].
  AqiProvider call({
    bool onlyNotifyOnChangedHistory = false,
  }) {
    return AqiProvider(
      onlyNotifyOnChangedHistory: onlyNotifyOnChangedHistory,
    );
  }

  @override
  AqiProvider getProviderOverride(
    covariant AqiProvider provider,
  ) {
    return call(
      onlyNotifyOnChangedHistory: provider.onlyNotifyOnChangedHistory,
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
  String? get name => r'aqiProvider';
}

/// Provides historical Air Quality Data as a [TimeSeries].
/// For the interplay of [onlyNotifyOnChangedHistory] and [aqiCurrent] refer
/// to the documentation for [TimeSeriesAverages].
/// The keepAlive is necessary here because the recalculation of the AQI is
/// rather expensive and should be cached whenever possible.
///
/// Copied from [aqi].
class AqiProvider extends Provider<TimeSeries?> {
  /// Provides historical Air Quality Data as a [TimeSeries].
  /// For the interplay of [onlyNotifyOnChangedHistory] and [aqiCurrent] refer
  /// to the documentation for [TimeSeriesAverages].
  /// The keepAlive is necessary here because the recalculation of the AQI is
  /// rather expensive and should be cached whenever possible.
  ///
  /// Copied from [aqi].
  AqiProvider({
    bool onlyNotifyOnChangedHistory = false,
  }) : this._internal(
          (ref) => aqi(
            ref as AqiRef,
            onlyNotifyOnChangedHistory: onlyNotifyOnChangedHistory,
          ),
          from: aqiProvider,
          name: r'aqiProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product') ? null : _$aqiHash,
          dependencies: AqiFamily._dependencies,
          allTransitiveDependencies: AqiFamily._allTransitiveDependencies,
          onlyNotifyOnChangedHistory: onlyNotifyOnChangedHistory,
        );

  AqiProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.onlyNotifyOnChangedHistory,
  }) : super.internal();

  final bool onlyNotifyOnChangedHistory;

  @override
  Override overrideWith(
    TimeSeries? Function(AqiRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AqiProvider._internal(
        (ref) => create(ref as AqiRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        onlyNotifyOnChangedHistory: onlyNotifyOnChangedHistory,
      ),
    );
  }

  @override
  ProviderElement<TimeSeries?> createElement() {
    return _AqiProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AqiProvider &&
        other.onlyNotifyOnChangedHistory == onlyNotifyOnChangedHistory;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, onlyNotifyOnChangedHistory.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AqiRef on ProviderRef<TimeSeries?> {
  /// The parameter `onlyNotifyOnChangedHistory` of this provider.
  bool get onlyNotifyOnChangedHistory;
}

class _AqiProviderElement extends ProviderElement<TimeSeries?> with AqiRef {
  _AqiProviderElement(super.provider);

  @override
  bool get onlyNotifyOnChangedHistory =>
      (origin as AqiProvider).onlyNotifyOnChangedHistory;
}

String _$aqiCurrentHash() => r'ec193f4c2936cdc55dc81b869ce3f64f408021aa';

/// The same as [aqi] but only for the latest measurements
///
/// Copied from [aqiCurrent].
@ProviderFor(aqiCurrent)
final aqiCurrentProvider = Provider<Measurement?>.internal(
  aqiCurrent,
  name: r'aqiCurrentProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$aqiCurrentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AqiCurrentRef = ProviderRef<Measurement?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
