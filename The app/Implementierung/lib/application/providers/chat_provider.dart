/// Handles sending and receiving messages using MQTT.
///
/// Key functionality:
/// - Stores incoming and outgoing messages with timestamps.
/// - Includes error handling for failed message transmissions.
///
/// Authors:
///   * Heye Hamadmad
///   * Arin Tanriverdi
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:circular_buffer/circular_buffer.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/chat_message.dart';
import '../../models/chat_message_content.dart';
import '../util/current_time.dart';
import 'mqtt_messages_provider.dart';
import 'mqtt_updates_provider.dart';

part 'chat_provider.g.dart';

// For now, a circular buffer of 1000 Messages should suffice.
// May be increased if necessary or made configurable
CircularBuffer<ChatMessage> _chatMessages = CircularBuffer(1000);

// If the provider gets rebuilt, the latest available message didn't change.
// This caches it to avoid duplicating messages.
MqttPublishMessage? _latestReceivedMessage;

/// Listens to incoming MQTT messages on the topic `chatbot/mission_control`
/// and adds them to the chat buffer if they are new.
@Riverpod(keepAlive: true)
class Chat extends _$Chat {
  @override
  List<ChatMessage> build() {
    final messageStream =
        ref.watch(mqttMessagesProvider(RegExp("^chatbot/mission_control\$")));
    switch (messageStream) {
      case AsyncData(:final value):
        if (value != _latestReceivedMessage) {
          _latestReceivedMessage = value;
          _chatMessages.add(ReceivedChatMessage(
              binaryContent: Uint8List.fromList(value.payload.message),
              timestamp: currentTime()));
        }
      case AsyncError(:final error):
        throw error;
      case _:
    }

    return _chatMessages
        .toList(); // Might be cached, but performance seems fine
  }

  /// Sends a chat message to the MQTT topic `chatbot/user` and adds it to the buffer on success.
  Future<void> sendMessage(ChatMessageContent content) async {
    final publisher = ref.read(mqttPublisherProvider.notifier);

    try {
      await publisher.publish(
          "chatbot/user", MqttQos.atLeastOnce, content.toUint8Buffer());
    } catch (e, st) {
      return Future.error(e, st);
    }

    _chatMessages
        .add(SentChatMessage(content: content, timestamp: currentTime()));
    ref.invalidateSelf();
  }
}
