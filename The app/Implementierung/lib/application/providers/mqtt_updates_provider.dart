/// MQTT client implementation for managing connections,
/// subscribing to topics, publishing messages, and monitoring the connection state.
///
/// It includes error handling, auto-reconnection, and the ability to handle updates
/// and publish messages asynchronously.
///
/// Authors:
///   * Heye Hamadmad
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:typed_data/typed_data.dart';

import '../../models/ternary_status.dart';
// Enable MQTT support for all platforms (including web)
// https://github.com/shamblett/mqtt_client/blob/master/example/mqtt_client_universal.dart
import '../mqtt_client_server.dart'
    if (dart.library.js_interop) '../mqtt_client_browser.dart' as mqttsetup;
import 'settings_provider.dart';

part 'mqtt_updates_provider.g.dart';

MqttClient? _client;

/// Counts the rebuilds of the mqttUpdatesProvider to escape an infinite loop later on
int _clientBuildNumber = 0;

@Riverpod(keepAlive: true)
class MqttUpdates extends _$MqttUpdates {
  @override
  Stream<MqttPublishMessage> build() async* {
    final log = Logger('MqttUpdates');

    ref.onDispose(() {
      // When the provider is rebuilt (for example when settings were changed)
      // the client needs to orderly disconnect and be reset first.
      if (_client != null) {
        _client?.disconnect();
        _client = null;
      }
    });

    // Increment and save own build number
    _clientBuildNumber++;
    int currentClientBuildNumber = _clientBuildNumber;

    // Configuration settings for MQTT connection (Rebuild on changes)
    final String mqttWsUri =
        (await ref.watch(settingsProvider("mqtt_ws_uri").future))?.dynamicValue
            as String;
    final String mqttClientId =
        (await ref.watch(settingsProvider("mqtt_client_id").future))
            ?.dynamicValue as String;
    final String mqttUser =
        (await ref.watch(settingsProvider("mqtt_user").future))?.dynamicValue
            as String;
    final String mqttPass =
        (await ref.watch(settingsProvider("mqtt_pass").future))?.dynamicValue
            as String;

    // The URI from the settings may contain a port number and login
    // information. The former needs to be its own variable due to mqtt_client
    // quirkyness, the latter needs to be disregarded because it will be set
    // separately.
    final originalUri = Uri.parse(mqttWsUri);
    var newUri = Uri(
        scheme: (originalUri.hasScheme ? originalUri.scheme : "ws"),
        host: originalUri.host,
        path: originalUri.path);

    _client = mqttsetup.setup(newUri.toString(), mqttClientId,
        originalUri.hasPort ? originalUri.port : 9001);
    _client!.keepAlivePeriod = 30;
    _client!.autoReconnect = true;
    _client!.websocketProtocols = ['mqtt'];
    _client!.logging(on: kDebugMode);
    // The following callbacks are needed for setting the connection state
    _client!.onConnected = _invalidateStateProvider;
    _client!.onDisconnected = _invalidateStateProvider;
    _client!.onAutoReconnect = _invalidateStateProvider;
    _client!.onAutoReconnected = _invalidateStateProvider;

    // Try loggin in in an infinite loop
    while (true) {
      if (_clientBuildNumber != currentClientBuildNumber) {
        // A new client has been started, the loop must be escaped.
        return;
      }
      await _client!.connect(mqttUser, mqttPass).onError((error, stackTrace) {
        log.severe("Connection attempt failed: $error");
        // Further error handling is not necessary as the connection attempt
        // will just be logged and repeated
        return null;
      });

      /// Check connection status
      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        break;
      }

      _client!.disconnect(); // Clean up failed connection attempt
      log.info("Connection attempt failed, retrying...");
      await Future.delayed(const Duration(seconds: 10));
    }

    // Connection succeeded, set connection
    _client!.subscribe("#", MqttQos.atLeastOnce);
    // It would be ideal to not subscribe to all topics, but it's fine to do so
    // for now, as was confirmed by our tutor.

    // In an infinite loop, listen for updates
    while (true) {
      if (_clientBuildNumber != currentClientBuildNumber) {
        // A new client has been started, the loop must be escaped.
        return;
      }
      await for (List<MqttReceivedMessage<MqttMessage?>>? c
          in _client!.updates ?? const Stream.empty()) {
        for (final recMess in c!) {
          yield recMess.payload as MqttPublishMessage;
        }
      }
      log.info("No messages in stream, reopening stream");
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  void _invalidateStateProvider() {
    ref.invalidate(mqttStateProvider);
  }
}

/// Provides the connection state, gets updated by mqttUpdatesProvider
@riverpod
class MqttState extends _$MqttState {
  @override
  TernaryStatus build() {
    return switch (_client?.connectionStatus?.state) {
      MqttConnectionState.connected => TernaryStatus.ok,
      MqttConnectionState.faulted => TernaryStatus.critical,
      _ => TernaryStatus.abnormal,
    };
  }
}

/// Allows publishing of new messages
///
/// Could technicall be a part of MqttUpdates, but separating it out allows for
/// more obvious semantics
@riverpod
class MqttPublisher extends _$MqttPublisher {
  @override
  void build() {}
  Future<void> publish(
      String topic, MqttQos qualityOfService, Uint8Buffer data) async {
    int? messageIdentifier;

    // Need to return an Future from a non-async function
    final Completer completer = Completer();

    if (_client == null) {
      completer.completeError("Client not yet set up");
      return completer.future;
    }

    if (_client!.published == null) {
      completer.completeError("Client not connected");
      return completer.future;
    }

    // The subscription gets saved for cancelling later. From now on, no return
    // is allowed without cancelling the subscription.
    var subscription = _client!.published!.listen(
      (MqttPublishMessage message) {
        if (messageIdentifier != null) {
          if (messageIdentifier == message.variableHeader?.messageIdentifier) {
            // Ensure that the message was sent by listening for the published
            // messages and comparing them with the sent one.
            // It might be useful to add a timeout somewhere.
            completer.complete();
          }
        }
      },
      onError: (err, st) {
        completer.completeError(err, st);
      },
      onDone: () {
        completer.completeError(
            "Client published stream completed but never encountered sent message");
      },
    );

    //Randomly sleep in debug mode for testing asynchronity
    if (kDebugMode) {
      if (Random().nextBool()) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    try {
      messageIdentifier =
          _client!.publishMessage(topic, qualityOfService, data);
    } catch (err, st) {
      completer.completeError(err, st);
    }

    try {
      await completer.future;
    } catch (err) {
      rethrow;
    } finally {
      await subscription.cancel();
    }
  }
}
