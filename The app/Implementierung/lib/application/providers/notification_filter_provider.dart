/// Monitors notifications related to MQTT topics,
/// filters them based on a regular expression, and determines the worst status.
/// Used for generating the visual primary status
///
/// Authors:
///   * Heye Hamadmad
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/ternary_status.dart';
import 'topic_notifications_provider.dart';

part 'notification_filter_provider.g.dart';

@riverpod
class NotificationFilter extends _$NotificationFilter {
  @override
  TernaryStatus build(RegExp topicMatcher) {
    var notificationsList = ref.watch(topicNotificationsProvider);
    TernaryStatus worstStatus = TernaryStatus.ok;
    for (final notification in notificationsList
        .where((notification) => topicMatcher.hasMatch(notification.topic))) {
      if (worstStatus == TernaryStatus.ok &&
          notification.status != TernaryStatus.ok) {
        worstStatus = notification.status;
      } else if (worstStatus == TernaryStatus.abnormal &&
          notification.status == TernaryStatus.critical) {
        worstStatus = notification.status;
      }
    }
    ref.notifyListeners();
    return worstStatus;
  }
}
