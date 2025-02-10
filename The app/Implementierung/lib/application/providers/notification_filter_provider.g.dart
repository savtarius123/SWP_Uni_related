// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationFilterHash() =>
    r'0a881a0ee7c9acb93927ae615f3a504004c3b365';

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

abstract class _$NotificationFilter
    extends BuildlessAutoDisposeNotifier<TernaryStatus> {
  late final RegExp topicMatcher;

  TernaryStatus build(
    RegExp topicMatcher,
  );
}

/// See also [NotificationFilter].
@ProviderFor(NotificationFilter)
const notificationFilterProvider = NotificationFilterFamily();

/// See also [NotificationFilter].
class NotificationFilterFamily extends Family<TernaryStatus> {
  /// See also [NotificationFilter].
  const NotificationFilterFamily();

  /// See also [NotificationFilter].
  NotificationFilterProvider call(
    RegExp topicMatcher,
  ) {
    return NotificationFilterProvider(
      topicMatcher,
    );
  }

  @override
  NotificationFilterProvider getProviderOverride(
    covariant NotificationFilterProvider provider,
  ) {
    return call(
      provider.topicMatcher,
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
  String? get name => r'notificationFilterProvider';
}

/// See also [NotificationFilter].
class NotificationFilterProvider
    extends AutoDisposeNotifierProviderImpl<NotificationFilter, TernaryStatus> {
  /// See also [NotificationFilter].
  NotificationFilterProvider(
    RegExp topicMatcher,
  ) : this._internal(
          () => NotificationFilter()..topicMatcher = topicMatcher,
          from: notificationFilterProvider,
          name: r'notificationFilterProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$notificationFilterHash,
          dependencies: NotificationFilterFamily._dependencies,
          allTransitiveDependencies:
              NotificationFilterFamily._allTransitiveDependencies,
          topicMatcher: topicMatcher,
        );

  NotificationFilterProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.topicMatcher,
  }) : super.internal();

  final RegExp topicMatcher;

  @override
  TernaryStatus runNotifierBuild(
    covariant NotificationFilter notifier,
  ) {
    return notifier.build(
      topicMatcher,
    );
  }

  @override
  Override overrideWith(NotificationFilter Function() create) {
    return ProviderOverride(
      origin: this,
      override: NotificationFilterProvider._internal(
        () => create()..topicMatcher = topicMatcher,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        topicMatcher: topicMatcher,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<NotificationFilter, TernaryStatus>
      createElement() {
    return _NotificationFilterProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationFilterProvider &&
        other.topicMatcher == topicMatcher;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, topicMatcher.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NotificationFilterRef on AutoDisposeNotifierProviderRef<TernaryStatus> {
  /// The parameter `topicMatcher` of this provider.
  RegExp get topicMatcher;
}

class _NotificationFilterProviderElement
    extends AutoDisposeNotifierProviderElement<NotificationFilter,
        TernaryStatus> with NotificationFilterRef {
  _NotificationFilterProviderElement(super.provider);

  @override
  RegExp get topicMatcher =>
      (origin as NotificationFilterProvider).topicMatcher;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
