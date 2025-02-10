/// Necessary to allow use of mqtt_client on all platforms.
///
/// Source: https://github.com/shamblett/mqtt_client/blob/master/example/mqtt_client_universal.dart
library;

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttClient setup(String serverAddress, String uniqueID, int port) {
  final client = MqttServerClient.withPort(serverAddress, uniqueID, port);
  client.useWebSocket = true;
  return client;
}
