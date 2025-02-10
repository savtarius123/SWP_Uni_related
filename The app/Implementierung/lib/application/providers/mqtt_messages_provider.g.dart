// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mqtt_messages_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mqttMessagesHash() => r'6877da49349debc19b7fcf83e65a78aa18954510';

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

abstract class _$MqttMessages
    extends BuildlessAutoDisposeAsyncNotifier<MqttPublishMessage> {
  late final RegExp matcher;

  FutureOr<MqttPublishMessage> build(
    RegExp matcher,
  );
}

/// See also [MqttMessages].
@ProviderFor(MqttMessages)
const mqttMessagesProvider = MqttMessagesFamily();

/// See also [MqttMessages].
class MqttMessagesFamily extends Family<AsyncValue<MqttPublishMessage>> {
  /// See also [MqttMessages].
  const MqttMessagesFamily();

  /// See also [MqttMessages].
  MqttMessagesProvider call(
    RegExp matcher,
  ) {
    return MqttMessagesProvider(
      matcher,
    );
  }

  @override
  MqttMessagesProvider getProviderOverride(
    covariant MqttMessagesProvider provider,
  ) {
    return call(
      provider.matcher,
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
  String? get name => r'mqttMessagesProvider';
}

/// See also [MqttMessages].
class MqttMessagesProvider extends AutoDisposeAsyncNotifierProviderImpl<
    MqttMessages, MqttPublishMessage> {
  /// See also [MqttMessages].
  MqttMessagesProvider(
    RegExp matcher,
  ) : this._internal(
          () => MqttMessages()..matcher = matcher,
          from: mqttMessagesProvider,
          name: r'mqttMessagesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mqttMessagesHash,
          dependencies: MqttMessagesFamily._dependencies,
          allTransitiveDependencies:
              MqttMessagesFamily._allTransitiveDependencies,
          matcher: matcher,
        );

  MqttMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.matcher,
  }) : super.internal();

  final RegExp matcher;

  @override
  FutureOr<MqttPublishMessage> runNotifierBuild(
    covariant MqttMessages notifier,
  ) {
    return notifier.build(
      matcher,
    );
  }

  @override
  Override overrideWith(MqttMessages Function() create) {
    return ProviderOverride(
      origin: this,
      override: MqttMessagesProvider._internal(
        () => create()..matcher = matcher,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        matcher: matcher,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<MqttMessages, MqttPublishMessage>
      createElement() {
    return _MqttMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MqttMessagesProvider && other.matcher == matcher;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, matcher.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MqttMessagesRef
    on AutoDisposeAsyncNotifierProviderRef<MqttPublishMessage> {
  /// The parameter `matcher` of this provider.
  RegExp get matcher;
}

class _MqttMessagesProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MqttMessages,
        MqttPublishMessage> with MqttMessagesRef {
  _MqttMessagesProviderElement(super.provider);

  @override
  RegExp get matcher => (origin as MqttMessagesProvider).matcher;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
