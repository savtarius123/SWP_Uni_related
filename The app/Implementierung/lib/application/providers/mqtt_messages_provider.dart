/// Listens to messages from the MQTT client and filters them based on a RegExp.
///
/// Authors:
///   * Heye Hamadmad
library;

import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'mqtt_updates_provider.dart';

part 'mqtt_messages_provider.g.dart';

@riverpod
class MqttMessages extends _$MqttMessages {
  // This class is not just a bloaty indirection because it ensures that other
  // providers that just need to listen to a subset of all topics won't be
  // needlessly rebuilt, which might be expensive.
  @override
  Future<MqttPublishMessage> build(RegExp matcher) {
    final currentMessage = ref.watch(mqttUpdatesProvider);

    final c = Completer<MqttPublishMessage>();
    switch (currentMessage) {
      case AsyncData(:final value):
        if (value.variableHeader?.topicName != null &&
            matcher.hasMatch(value.variableHeader!.topicName)) {
          c.complete(value);
        }
      case AsyncError(:final error, :final stackTrace):
        c.completeError(error, stackTrace);
      case _:
    }

    return c.future;
  }
}
