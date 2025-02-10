// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeseries_notifier_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timeSeriesLatestMeasurementHash() =>
    r'b6ae260d6f631aa4b8fe2f3eadbb7e0403772182';

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

/// When an append-only update comes in (the usual case) only this provider will be updated.
///
/// Copied from [timeSeriesLatestMeasurement].
@ProviderFor(timeSeriesLatestMeasurement)
const timeSeriesLatestMeasurementProvider = TimeSeriesLatestMeasurementFamily();

/// When an append-only update comes in (the usual case) only this provider will be updated.
///
/// Copied from [timeSeriesLatestMeasurement].
class TimeSeriesLatestMeasurementFamily extends Family<Measurement?> {
  /// When an append-only update comes in (the usual case) only this provider will be updated.
  ///
  /// Copied from [timeSeriesLatestMeasurement].
  const TimeSeriesLatestMeasurementFamily();

  /// When an append-only update comes in (the usual case) only this provider will be updated.
  ///
  /// Copied from [timeSeriesLatestMeasurement].
  TimeSeriesLatestMeasurementProvider call(
    String topic,
  ) {
    return TimeSeriesLatestMeasurementProvider(
      topic,
    );
  }

  @override
  TimeSeriesLatestMeasurementProvider getProviderOverride(
    covariant TimeSeriesLatestMeasurementProvider provider,
  ) {
    return call(
      provider.topic,
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
  String? get name => r'timeSeriesLatestMeasurementProvider';
}

/// When an append-only update comes in (the usual case) only this provider will be updated.
///
/// Copied from [timeSeriesLatestMeasurement].
class TimeSeriesLatestMeasurementProvider
    extends AutoDisposeProvider<Measurement?> {
  /// When an append-only update comes in (the usual case) only this provider will be updated.
  ///
  /// Copied from [timeSeriesLatestMeasurement].
  TimeSeriesLatestMeasurementProvider(
    String topic,
  ) : this._internal(
          (ref) => timeSeriesLatestMeasurement(
            ref as TimeSeriesLatestMeasurementRef,
            topic,
          ),
          from: timeSeriesLatestMeasurementProvider,
          name: r'timeSeriesLatestMeasurementProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$timeSeriesLatestMeasurementHash,
          dependencies: TimeSeriesLatestMeasurementFamily._dependencies,
          allTransitiveDependencies:
              TimeSeriesLatestMeasurementFamily._allTransitiveDependencies,
          topic: topic,
        );

  TimeSeriesLatestMeasurementProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.topic,
  }) : super.internal();

  final String topic;

  @override
  Override overrideWith(
    Measurement? Function(TimeSeriesLatestMeasurementRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TimeSeriesLatestMeasurementProvider._internal(
        (ref) => create(ref as TimeSeriesLatestMeasurementRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        topic: topic,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Measurement?> createElement() {
    return _TimeSeriesLatestMeasurementProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TimeSeriesLatestMeasurementProvider && other.topic == topic;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, topic.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TimeSeriesLatestMeasurementRef on AutoDisposeProviderRef<Measurement?> {
  /// The parameter `topic` of this provider.
  String get topic;
}

class _TimeSeriesLatestMeasurementProviderElement
    extends AutoDisposeProviderElement<Measurement?>
    with TimeSeriesLatestMeasurementRef {
  _TimeSeriesLatestMeasurementProviderElement(super.provider);

  @override
  String get topic => (origin as TimeSeriesLatestMeasurementProvider).topic;
}

String _$timeSeriesTopicsHash() => r'a15e4f064426b8c7d9f7143022161a792a4bba04';

/// Provides a list of available topics / TimeSeries
///
/// Copied from [timeSeriesTopics].
@ProviderFor(timeSeriesTopics)
final timeSeriesTopicsProvider = AutoDisposeProvider<Iterable<String>>.internal(
  timeSeriesTopics,
  name: r'timeSeriesTopicsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timeSeriesTopicsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TimeSeriesTopicsRef = AutoDisposeProviderRef<Iterable<String>>;
String _$latestUpdateHash() => r'b0899bd3a1360addab95fcab83c0604428ae1b0a';

/// Provides the timestamp of the newest known measurement
///
/// Copied from [latestUpdate].
@ProviderFor(latestUpdate)
final latestUpdateProvider = AutoDisposeProvider<MartianTimeStamp?>.internal(
  latestUpdate,
  name: r'latestUpdateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$latestUpdateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LatestUpdateRef = AutoDisposeProviderRef<MartianTimeStamp?>;
String _$timeSeriesNotifierHash() =>
    r'4d7034fedecd6b34939f81c792fdf011a33544b9';

abstract class _$TimeSeriesNotifier
    extends BuildlessAutoDisposeNotifier<TimeSeries?> {
  late final String topic;
  late final bool onlyNotifyOnChangedHistory;

  TimeSeries? build(
    String topic, {
    bool onlyNotifyOnChangedHistory = false,
  });
}

/// Providers current and historical data on time series. Enables Updating.
/// For an explanation of "onlyNotifyOnChangedHistory" see [TimeSeriesAverages].
///
/// Copied from [TimeSeriesNotifier].
@ProviderFor(TimeSeriesNotifier)
const timeSeriesNotifierProvider = TimeSeriesNotifierFamily();

/// Providers current and historical data on time series. Enables Updating.
/// For an explanation of "onlyNotifyOnChangedHistory" see [TimeSeriesAverages].
///
/// Copied from [TimeSeriesNotifier].
class TimeSeriesNotifierFamily extends Family<TimeSeries?> {
  /// Providers current and historical data on time series. Enables Updating.
  /// For an explanation of "onlyNotifyOnChangedHistory" see [TimeSeriesAverages].
  ///
  /// Copied from [TimeSeriesNotifier].
  const TimeSeriesNotifierFamily();

  /// Providers current and historical data on time series. Enables Updating.
  /// For an explanation of "onlyNotifyOnChangedHistory" see [TimeSeriesAverages].
  ///
  /// Copied from [TimeSeriesNotifier].
  TimeSeriesNotifierProvider call(
    String topic, {
    bool onlyNotifyOnChangedHistory = false,
  }) {
    return TimeSeriesNotifierProvider(
      topic,
      onlyNotifyOnChangedHistory: onlyNotifyOnChangedHistory,
    );
  }

  @override
  TimeSeriesNotifierProvider getProviderOverride(
    covariant TimeSeriesNotifierProvider provider,
  ) {
    return call(
      provider.topic,
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
  String? get name => r'timeSeriesNotifierProvider';
}

/// Providers current and historical data on time series. Enables Updating.
/// For an explanation of "onlyNotifyOnChangedHistory" see [TimeSeriesAverages].
///
/// Copied from [TimeSeriesNotifier].
class TimeSeriesNotifierProvider
    extends AutoDisposeNotifierProviderImpl<TimeSeriesNotifier, TimeSeries?> {
  /// Providers current and historical data on time series. Enables Updating.
  /// For an explanation of "onlyNotifyOnChangedHistory" see [TimeSeriesAverages].
  ///
  /// Copied from [TimeSeriesNotifier].
  TimeSeriesNotifierProvider(
    String topic, {
    bool onlyNotifyOnChangedHistory = false,
  }) : this._internal(
          () => TimeSeriesNotifier()
            ..topic = topic
            ..onlyNotifyOnChangedHistory = onlyNotifyOnChangedHistory,
          from: timeSeriesNotifierProvider,
          name: r'timeSeriesNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$timeSeriesNotifierHash,
          dependencies: TimeSeriesNotifierFamily._dependencies,
          allTransitiveDependencies:
              TimeSeriesNotifierFamily._allTransitiveDependencies,
          topic: topic,
          onlyNotifyOnChangedHistory: onlyNotifyOnChangedHistory,
        );

  TimeSeriesNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.topic,
    required this.onlyNotifyOnChangedHistory,
  }) : super.internal();

  final String topic;
  final bool onlyNotifyOnChangedHistory;

  @override
  TimeSeries? runNotifierBuild(
    covariant TimeSeriesNotifier notifier,
  ) {
    return notifier.build(
      topic,
      onlyNotifyOnChangedHistory: onlyNotifyOnChangedHistory,
    );
  }

  @override
  Override overrideWith(TimeSeriesNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TimeSeriesNotifierProvider._internal(
        () => create()
          ..topic = topic
          ..onlyNotifyOnChangedHistory = onlyNotifyOnChangedHistory,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        topic: topic,
        onlyNotifyOnChangedHistory: onlyNotifyOnChangedHistory,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<TimeSeriesNotifier, TimeSeries?>
      createElement() {
    return _TimeSeriesNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TimeSeriesNotifierProvider &&
        other.topic == topic &&
        other.onlyNotifyOnChangedHistory == onlyNotifyOnChangedHistory;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, topic.hashCode);
    hash = _SystemHash.combine(hash, onlyNotifyOnChangedHistory.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TimeSeriesNotifierRef on AutoDisposeNotifierProviderRef<TimeSeries?> {
  /// The parameter `topic` of this provider.
  String get topic;

  /// The parameter `onlyNotifyOnChangedHistory` of this provider.
  bool get onlyNotifyOnChangedHistory;
}

class _TimeSeriesNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<TimeSeriesNotifier, TimeSeries?>
    with TimeSeriesNotifierRef {
  _TimeSeriesNotifierProviderElement(super.provider);

  @override
  String get topic => (origin as TimeSeriesNotifierProvider).topic;
  @override
  bool get onlyNotifyOnChangedHistory =>
      (origin as TimeSeriesNotifierProvider).onlyNotifyOnChangedHistory;
}

String _$allTimeSeriesHash() => r'237722bb98823b5668cc54c099d8ffb1e1788342';

abstract class _$AllTimeSeries
    extends BuildlessAutoDisposeNotifier<Map<String, TimeSeries>> {
  late final RegExp? filter;
  late final bool onlyNotifyOnChangedHistory;

  Map<String, TimeSeries> build({
    RegExp? filter,
    bool onlyNotifyOnChangedHistory = false,
  });
}

/// Provides all time series (or alternatively only those matching a RegExp) as a map for better performance.
///
/// Copied from [AllTimeSeries].
@ProviderFor(AllTimeSeries)
const allTimeSeriesProvider = AllTimeSeriesFamily();

/// Provides all time series (or alternatively only those matching a RegExp) as a map for better performance.
///
/// Copied from [AllTimeSeries].
class AllTimeSeriesFamily extends Family<Map<String, TimeSeries>> {
  /// Provides all time series (or alternatively only those matching a RegExp) as a map for better performance.
  ///
  /// Copied from [AllTimeSeries].
  const AllTimeSeriesFamily();

  /// Provides all time series (or alternatively only those matching a RegExp) as a map for better performance.
  ///
  /// Copied from [AllTimeSeries].
  AllTimeSeriesProvider call({
    RegExp? filter,
    bool onlyNotifyOnChangedHistory = false,
  }) {
    return AllTimeSeriesProvider(
      filter: filter,
      onlyNotifyOnChangedHistory: onlyNotifyOnChangedHistory,
    );
  }

  @override
  AllTimeSeriesProvider getProviderOverride(
    covariant AllTimeSeriesProvider provider,
  ) {
    return call(
      filter: provider.filter,
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
  String? get name => r'allTimeSeriesProvider';
}

/// Provides all time series (or alternatively only those matching a RegExp) as a map for better performance.
///
/// Copied from [AllTimeSeries].
class AllTimeSeriesProvider extends AutoDisposeNotifierProviderImpl<
    AllTimeSeries, Map<String, TimeSeries>> {
  /// Provides all time series (or alternatively only those matching a RegExp) as a map for better performance.
  ///
  /// Copied from [AllTimeSeries].
  AllTimeSeriesProvider({
    RegExp? filter,
    bool onlyNotifyOnChangedHistory = false,
  }) : this._internal(
          () => AllTimeSeries()
            ..filter = filter
            ..onlyNotifyOnChangedHistory = onlyNotifyOnChangedHistory,
          from: allTimeSeriesProvider,
          name: r'allTimeSeriesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$allTimeSeriesHash,
          dependencies: AllTimeSeriesFamily._dependencies,
          allTransitiveDependencies:
              AllTimeSeriesFamily._allTransitiveDependencies,
          filter: filter,
          onlyNotifyOnChangedHistory: onlyNotifyOnChangedHistory,
        );

  AllTimeSeriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
    required this.onlyNotifyOnChangedHistory,
  }) : super.internal();

  final RegExp? filter;
  final bool onlyNotifyOnChangedHistory;

  @override
  Map<String, TimeSeries> runNotifierBuild(
    covariant AllTimeSeries notifier,
  ) {
    return notifier.build(
      filter: filter,
      onlyNotifyOnChangedHistory: onlyNotifyOnChangedHistory,
    );
  }

  @override
  Override overrideWith(AllTimeSeries Function() create) {
    return ProviderOverride(
      origin: this,
      override: AllTimeSeriesProvider._internal(
        () => create()
          ..filter = filter
          ..onlyNotifyOnChangedHistory = onlyNotifyOnChangedHistory,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filter: filter,
        onlyNotifyOnChangedHistory: onlyNotifyOnChangedHistory,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<AllTimeSeries, Map<String, TimeSeries>>
      createElement() {
    return _AllTimeSeriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllTimeSeriesProvider &&
        other.filter == filter &&
        other.onlyNotifyOnChangedHistory == onlyNotifyOnChangedHistory;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);
    hash = _SystemHash.combine(hash, onlyNotifyOnChangedHistory.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AllTimeSeriesRef
    on AutoDisposeNotifierProviderRef<Map<String, TimeSeries>> {
  /// The parameter `filter` of this provider.
  RegExp? get filter;

  /// The parameter `onlyNotifyOnChangedHistory` of this provider.
  bool get onlyNotifyOnChangedHistory;
}

class _AllTimeSeriesProviderElement extends AutoDisposeNotifierProviderElement<
    AllTimeSeries, Map<String, TimeSeries>> with AllTimeSeriesRef {
  _AllTimeSeriesProviderElement(super.provider);

  @override
  RegExp? get filter => (origin as AllTimeSeriesProvider).filter;
  @override
  bool get onlyNotifyOnChangedHistory =>
      (origin as AllTimeSeriesProvider).onlyNotifyOnChangedHistory;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
