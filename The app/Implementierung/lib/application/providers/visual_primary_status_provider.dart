/// Generates a list of `VisualStatus` objects to provide a visual representation of the primary statuses of the system.
///
/// Authors:
///   * Heye Hamadmad
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/visual_status.dart';
import 'mqtt_updates_provider.dart';
import 'notification_filter_provider.dart';

part 'visual_primary_status_provider.g.dart';

@riverpod
class VisualPrimaryStatus extends _$VisualPrimaryStatus {
  @override
  List<VisualStatus> build() {
    return [
      VisualStatus(ref.watch(mqttStateProvider), "MQTT Connection"),
      VisualStatus(
          ref.watch(notificationFilterProvider(RegExp("^board[0-9]+/"))),
          "Environment"),
      VisualStatus(ref.watch(notificationFilterProvider(RegExp("^pbr[0-9]+/"))),
          "Photobioreactor")
    ];
  }
}
