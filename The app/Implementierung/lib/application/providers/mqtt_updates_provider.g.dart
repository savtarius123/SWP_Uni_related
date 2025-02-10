// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mqtt_updates_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mqttUpdatesHash() => r'df2260de98fe37b48eca619b6c8a9477ec3bf91d';

/// See also [MqttUpdates].
@ProviderFor(MqttUpdates)
final mqttUpdatesProvider =
    StreamNotifierProvider<MqttUpdates, MqttPublishMessage>.internal(
  MqttUpdates.new,
  name: r'mqttUpdatesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$mqttUpdatesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MqttUpdates = StreamNotifier<MqttPublishMessage>;
String _$mqttStateHash() => r'c698d0dcc7be3566269bbd700c2655e752f7176b';

/// Provides the connection state, gets updated by mqttUpdatesProvider
///
/// Copied from [MqttState].
@ProviderFor(MqttState)
final mqttStateProvider =
    AutoDisposeNotifierProvider<MqttState, TernaryStatus>.internal(
  MqttState.new,
  name: r'mqttStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$mqttStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MqttState = AutoDisposeNotifier<TernaryStatus>;
String _$mqttPublisherHash() => r'e57602c0f8a7ecb09682ab31a181a4156df811fd';

/// Allows publishing of new messages
///
/// Could technicall be a part of MqttUpdates, but separating it out allows for
/// more obvious semantics
///
/// Copied from [MqttPublisher].
@ProviderFor(MqttPublisher)
final mqttPublisherProvider =
    AutoDisposeNotifierProvider<MqttPublisher, void>.internal(
  MqttPublisher.new,
  name: r'mqttPublisherProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mqttPublisherHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MqttPublisher = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
