// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeseries_averages_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timeSeriesAverageCurrentHash() =>
    r'34fff57cdea190c140ee279d8e08ba3eef7afb4a';

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

/// Provides the latest averaged values of the time series for all topics matching the RegExp
///
/// Copied from [timeSeriesAverageCurrent].
@ProviderFor(timeSeriesAverageCurrent)
const timeSeriesAverageCurrentProvider = TimeSeriesAverageCurrentFamily();

/// Provides the latest averaged values of the time series for all topics matching the RegExp
///
/// Copied from [timeSeriesAverageCurrent].
class TimeSeriesAverageCurrentFamily extends Family<Measurement?> {
  /// Provides the latest averaged values of the time series for all topics matching the RegExp
  ///
  /// Copied from [timeSeriesAverageCurrent].
  const TimeSeriesAverageCurrentFamily();

  /// Provides the latest averaged values of the time series for all topics matching the RegExp
  ///
  /// Copied from [timeSeriesAverageCurrent].
  TimeSeriesAverageCurrentProvider call(
    RegExp topics,
  ) {
    return TimeSeriesAverageCurrentProvider(
      topics,
    );
  }

  @override
  TimeSeriesAverageCurrentProvider getProviderOverride(
    covariant TimeSeriesAverageCurrentProvider provider,
  ) {
    return call(
      provider.topics,
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
  String? get name => r'timeSeriesAverageCurrentProvider';
}

/// Provides the latest averaged values of the time series for all topics matching the RegExp
///
/// Copied from [timeSeriesAverageCurrent].
class TimeSeriesAverageCurrentProvider extends Provider<Measurement?> {
  /// Provides the latest averaged values of the time series for all topics matching the RegExp
  ///
  /// Copied from [timeSeriesAverageCurrent].
  TimeSeriesAverageCurrentProvider(
    RegExp topics,
  ) : this._internal(
          (ref) => timeSeriesAverageCurrent(
            ref as TimeSeriesAverageCurrentRef,
            topics,
          ),
          from: timeSeriesAverageCurrentProvider,
          name: r'timeSeriesAverageCurrentProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$timeSeriesAverageCurrentHash,
          dependencies: TimeSeriesAverageCurrentFamily._dependencies,
          allTransitiveDependencies:
              TimeSeriesAverageCurrentFamily._allTransitiveDependencies,
          topics: topics,
        );

  TimeSeriesAverageCurrentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.topics,
  }) : super.internal();

  final RegExp topics;

  @override
  Override overrideWith(
    Measurement? Function(TimeSeriesAverageCurrentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TimeSeriesAverageCurrentProvider._internal(
        (ref) => create(ref as TimeSeriesAverageCurrentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        topics: topics,
      ),
    );
  }

  @override
  ProviderElement<Measurement?> createElement() {
    return _TimeSeriesAverageCurrentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TimeSeriesAverageCurrentProvider && other.topics == topics;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, topics.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TimeSeriesAverageCurrentRef on ProviderRef<Measurement?> {
  /// The parameter `topics` of this provider.
  RegExp get topics;
}

class _TimeSeriesAverageCurrentProviderElement
    extends ProviderElement<Measurement?> with TimeSeriesAverageCurrentRef {
  _TimeSeriesAverageCurrentProviderElement(super.provider);

  @override
  RegExp get topics => (origin as TimeSeriesAverageCurrentProvider).topics;
}

String _$timeSeriesAveragesHash() =>
    r'dc538ed036526047e7e4a9954aa70bf2237b7d4a';

abstract class _$TimeSeriesAverages extends BuildlessNotifier<TimeSeries?> {
  late final RegExp topics;
  late final bool onlyNotifyOnChangedHistory;

  TimeSeries? build(
    RegExp topics, {
    bool onlyNotifyOnChangedHistory = false,
  });
}

/// Provides historical averaged data as a [TimeSeries].
/// The boolean variable [onlyNotifyOnChangedHistory] effectively separates two
/// completely different providers. One (with the variable set to true) only
/// notifies its listeners when for some reason (for example an InfluxDB import)
/// the historical time series data changes. It then recalculates the averages
/// over all matching topics/time series and notifies its listeners. Other than
/// the convenience function with [onlyNotifyOnChangedHistory] set to false
/// (which listens to the former and also timeSeriesAverageCurrentProvider),
/// this will only be used by other providers that need historical averaged
/// values.
/// The keepAlive is necessary here because the recalculation of the AQI is
/// rather expensive and should be cached whenever possible.
///
/// Copied from [TimeSeriesAverages].
@ProviderFor(TimeSeriesAverages)
const timeSeriesAveragesProvider = TimeSeriesAveragesFamily();

/// Provides historical averaged data as a [TimeSeries].
/// The boolean variable [onlyNotifyOnChangedHistory] effectively separates two
/// completely different providers. One (with the variable set to true) only
/// notifies its listeners when for some reason (for example an InfluxDB import)
/// the historical time series data changes. It then recalculates the averages
/// over all matching topics/time series and notifies its listeners. Other than
/// the convenience function with [onlyNotifyOnChangedHistory] set to false
/// (which listens to the former and also timeSeriesAverageCurrentProvider),
/// this will only be used by other providers that need historical averaged
/// values.
/// The keepAlive is necessary here because the recalculation of the AQI is
/// rather expensive and should be cached whenever possible.
///
/// Copied from [TimeSeriesAverages].
class TimeSeriesAveragesFamily extends Family<TimeSeries?> {
  /// Provides historical averaged data as a [TimeSeries].
  /// The boolean variable [onlyNotifyOnChangedHistory] effectively separates two
  /// completely different providers. One (with the variable set to true) only
  /// notifies its listeners when for some reason (for example an InfluxDB import)
  /// the historical time series data changes. It then recalculates the averages
  /// over all matching topics/time series and notifies its listeners. Other than
  /// the convenience function with [onlyNotifyOnChangedHistory] set to false
  /// (which listens to the former and also timeSeriesAverageCurrentProvider),
  /// this will only be used by other providers that need historical averaged
  /// values.
  /// The keepAlive is necessary here because the recalculation of the AQI is
  /// rather expensive and should be cached whenever possible.
  ///
  /// Copied from [TimeSeriesAverages].
  const TimeSeriesAveragesFamily();

  /// Provides historical averaged data as a [TimeSeries].
  /// The boolean variable [onlyNotifyOnChangedHistory] effectively separates two
  /// completely different providers. One (with the variable set to true) only
  /// notifies its listeners when for some reason (for example an InfluxDB import)
  /// the historical time series data changes. It then recalculates the averages
  /// over all matching topics/time series and notifies its listeners. Other than
  /// the convenience function with [onlyNotifyOnChangedHistory] set to false
  /// (which listens to the former and also timeSeriesAverageCurrentProvider),
  /// this will only be used by other providers that need historical averaged
  /// values.
  /// The keepAlive is necessary here because the recalculation of the AQI is
  /// rather expensive and should be cached whenever possible.
  ///
  /// Copied from [TimeSeriesAverages].
  TimeSeriesAveragesProvider call(
    RegExp topics, {
    bool onlyNotifyOnChangedHistory = false,
  }) {
    return TimeSeriesAveragesProvider(
      topics,
      onlyNotifyOnChangedHistory: onlyNotifyOnChangedHistory,
    );
  }

  @override
  TimeSeriesAveragesProvider getProviderOverride(
    covariant TimeSeriesAveragesProvider provider,
  ) {
    return call(
      provider.topics,
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
  String? get name => r'timeSeriesAveragesProvider';
}

/// Provides historical averaged data as a [TimeSeries].
/// The boolean variable [onlyNotifyOnChangedHistory] effectively separates two
/// completely different providers. One (with the variable set to true) only
/// notifies its listeners when for some reason (for example an InfluxDB import)
/// the historical time series data changes. It then recalculates the averages
/// over all matching topics/time series and notifies its listeners. Other than
/// the convenience function with [onlyNotifyOnChangedHistory] set to false
/// (which listens to the former and also timeSeriesAverageCurrentProvider),
/// this will only be used by other providers that need historical averaged
/// values.
/// The keepAlive is necessary here because the recalculation of the AQI is
/// rather expensive and should be cached whenever possible.
///
/// Copied from [TimeSeriesAverages].
class TimeSeriesAveragesProvider
    extends NotifierProviderImpl<TimeSeriesAverages, TimeSeries?> {
  /// Provides historical averaged data as a [TimeSeries].
  /// The boolean variable [onlyNotifyOnChangedHistory] effectively separates two
  /// completely different providers. One (with the variable set to true) only
  /// notifies its listeners when for some reason (for example an InfluxDB import)
  /// the historical time series data changes. It then recalculates the averages
  /// over all matching topics/time series and notifies its listeners. Other than
  /// the convenience function with [onlyNotifyOnChangedHistory] set to false
  /// (which listens to the former and also timeSeriesAverageCurrentProvider),
  /// this will only be used by other providers that need historical averaged
  /// values.
  /// The keepAlive is necessary here because the recalculation of the AQI is
  /// rather expensive and should be cached whenever possible.
  ///
  /// Copied from [TimeSeriesAverages].
  TimeSeriesAveragesProvider(
    RegExp topics, {
    bool onlyNotifyOnChangedHistory = false,
  }) : this._internal(
          () => TimeSeriesAverages()
            ..topics = topics
            ..onlyNotifyOnChangedHistory = onlyNotifyOnChangedHistory,
          from: timeSeriesAveragesProvider,
          name: r'timeSeriesAveragesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$timeSeriesAveragesHash,
          dependencies: TimeSeriesAveragesFamily._dependencies,
          allTransitiveDependencies:
              TimeSeriesAveragesFamily._allTransitiveDependencies,
          topics: topics,
          onlyNotifyOnChangedHistory: onlyNotifyOnChangedHistory,
        );

  TimeSeriesAveragesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.topics,
    required this.onlyNotifyOnChangedHistory,
  }) : super.internal();

  final RegExp topics;
  final bool onlyNotifyOnChangedHistory;

  @override
  TimeSeries? runNotifierBuild(
    covariant TimeSeriesAverages notifier,
  ) {
    return notifier.build(
      topics,
      onlyNotifyOnChangedHistory: onlyNotifyOnChangedHistory,
    );
  }

  @override
  Override overrideWith(TimeSeriesAverages Function() create) {
    return ProviderOverride(
      origin: this,
      override: TimeSeriesAveragesProvider._internal(
        () => create()
          ..topics = topics
          ..onlyNotifyOnChangedHistory = onlyNotifyOnChangedHistory,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        topics: topics,
        onlyNotifyOnChangedHistory: onlyNotifyOnChangedHistory,
      ),
    );
  }

  @override
  NotifierProviderElement<TimeSeriesAverages, TimeSeries?> createElement() {
    return _TimeSeriesAveragesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TimeSeriesAveragesProvider &&
        other.topics == topics &&
        other.onlyNotifyOnChangedHistory == onlyNotifyOnChangedHistory;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, topics.hashCode);
    hash = _SystemHash.combine(hash, onlyNotifyOnChangedHistory.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TimeSeriesAveragesRef on NotifierProviderRef<TimeSeries?> {
  /// The parameter `topics` of this provider.
  RegExp get topics;

  /// The parameter `onlyNotifyOnChangedHistory` of this provider.
  bool get onlyNotifyOnChangedHistory;
}

class _TimeSeriesAveragesProviderElement
    extends NotifierProviderElement<TimeSeriesAverages, TimeSeries?>
    with TimeSeriesAveragesRef {
  _TimeSeriesAveragesProviderElement(super.provider);

  @override
  RegExp get topics => (origin as TimeSeriesAveragesProvider).topics;
  @override
  bool get onlyNotifyOnChangedHistory =>
      (origin as TimeSeriesAveragesProvider).onlyNotifyOnChangedHistory;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
