// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$topicNotificationsHash() =>
    r'35846de2fc379051c6bb81486eed67ac5140eded';

/// Notifies listeners if a new notification is generated or an existing one is
/// dismissed
///
/// Copied from [TopicNotifications].
@ProviderFor(TopicNotifications)
final topicNotificationsProvider = AutoDisposeNotifierProvider<
    TopicNotifications, List<TopicNotification>>.internal(
  TopicNotifications.new,
  name: r'topicNotificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$topicNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TopicNotifications = AutoDisposeNotifier<List<TopicNotification>>;
String _$topicNotificationStatusHash() =>
    r'7214eb11b3569ec63d6da769adfcbba6e750c330';

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

abstract class _$TopicNotificationStatus
    extends BuildlessAutoDisposeNotifier<TernaryStatus?> {
  late final TopicNotification topicNotification;

  TernaryStatus? build(
    TopicNotification topicNotification,
  );
}

/// Allows watching changes of any singular notification
///
/// Copied from [TopicNotificationStatus].
@ProviderFor(TopicNotificationStatus)
const topicNotificationStatusProvider = TopicNotificationStatusFamily();

/// Allows watching changes of any singular notification
///
/// Copied from [TopicNotificationStatus].
class TopicNotificationStatusFamily extends Family<TernaryStatus?> {
  /// Allows watching changes of any singular notification
  ///
  /// Copied from [TopicNotificationStatus].
  const TopicNotificationStatusFamily();

  /// Allows watching changes of any singular notification
  ///
  /// Copied from [TopicNotificationStatus].
  TopicNotificationStatusProvider call(
    TopicNotification topicNotification,
  ) {
    return TopicNotificationStatusProvider(
      topicNotification,
    );
  }

  @override
  TopicNotificationStatusProvider getProviderOverride(
    covariant TopicNotificationStatusProvider provider,
  ) {
    return call(
      provider.topicNotification,
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
  String? get name => r'topicNotificationStatusProvider';
}

/// Allows watching changes of any singular notification
///
/// Copied from [TopicNotificationStatus].
class TopicNotificationStatusProvider extends AutoDisposeNotifierProviderImpl<
    TopicNotificationStatus, TernaryStatus?> {
  /// Allows watching changes of any singular notification
  ///
  /// Copied from [TopicNotificationStatus].
  TopicNotificationStatusProvider(
    TopicNotification topicNotification,
  ) : this._internal(
          () =>
              TopicNotificationStatus()..topicNotification = topicNotification,
          from: topicNotificationStatusProvider,
          name: r'topicNotificationStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$topicNotificationStatusHash,
          dependencies: TopicNotificationStatusFamily._dependencies,
          allTransitiveDependencies:
              TopicNotificationStatusFamily._allTransitiveDependencies,
          topicNotification: topicNotification,
        );

  TopicNotificationStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.topicNotification,
  }) : super.internal();

  final TopicNotification topicNotification;

  @override
  TernaryStatus? runNotifierBuild(
    covariant TopicNotificationStatus notifier,
  ) {
    return notifier.build(
      topicNotification,
    );
  }

  @override
  Override overrideWith(TopicNotificationStatus Function() create) {
    return ProviderOverride(
      origin: this,
      override: TopicNotificationStatusProvider._internal(
        () => create()..topicNotification = topicNotification,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        topicNotification: topicNotification,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<TopicNotificationStatus, TernaryStatus?>
      createElement() {
    return _TopicNotificationStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TopicNotificationStatusProvider &&
        other.topicNotification == topicNotification;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, topicNotification.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TopicNotificationStatusRef
    on AutoDisposeNotifierProviderRef<TernaryStatus?> {
  /// The parameter `topicNotification` of this provider.
  TopicNotification get topicNotification;
}

class _TopicNotificationStatusProviderElement
    extends AutoDisposeNotifierProviderElement<TopicNotificationStatus,
        TernaryStatus?> with TopicNotificationStatusRef {
  _TopicNotificationStatusProviderElement(super.provider);

  @override
  TopicNotification get topicNotification =>
      (origin as TopicNotificationStatusProvider).topicNotification;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
