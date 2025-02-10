/// Stores and provides a list of existing notifications, generates new
/// notifications if necessary and dismisses notifications on command.
///
/// Authors:
///   * Heye Hamadmad
///   * Arin Tanriverdi
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/ternary_status.dart';
import '../../models/topic_notification.dart';
import 'setpoint_rules_provider.dart';

part 'topic_notifications_provider.g.dart';

List<TopicNotification> _topicNotifications = [];

/// Notifies listeners if a new notification is generated or an existing one is
/// dismissed
@riverpod
class TopicNotifications extends _$TopicNotifications {
  @override
  List<TopicNotification> build() {
    return List.from(_topicNotifications);
  }

  /// Removes a notification only if it exists and is in "OK" state
  void dismiss(TopicNotification topicNotification) {
    if (_topicNotifications.contains(topicNotification) &&
        topicNotification.status == TernaryStatus.ok) {
      _topicNotifications.remove(topicNotification);
      ref.invalidateSelf();
    }
  }

  /// Checks a new value for a topic against the first matching setpoint rule.
  /// Then creates or updates a notification if necessary
  void dataUpdate({required String topic, required double value}) {
    final setpointRule = ref.watch(setpointRuleByTopicProvider(topic));

    // Notifications with OK status don't get touched again (as clarified by Tutor)
    final matchingNonOkNotifications = _topicNotifications.where(
        (topicNotification) =>
            topicNotification.topic == topic &&
            topicNotification.status != TernaryStatus.ok);

    // First handle the case where a rule was removed
    if (setpointRule == null) {
      for (final matching in matchingNonOkNotifications) {
        matching.status = TernaryStatus.ok;
        ref.invalidateSelf();
        ref.invalidate(topicNotificationStatusProvider(matching));
      }
      return;
    }

    final newStatus = setpointRule.checkStatus(value);

    if (matchingNonOkNotifications.isNotEmpty) {
      // Handle updating pre-existing notifications
      for (final matching in matchingNonOkNotifications) {
        if (matching.status != newStatus) {
          matching.status = newStatus;
          ref.invalidateSelf();
          ref.invalidate(topicNotificationStatusProvider(matching));
        }
      }
    } else {
      if (newStatus != TernaryStatus.ok) {
        _topicNotifications.add(TopicNotification(
            status: newStatus, topic: topic, setpointRule: setpointRule));
        ref.invalidateSelf();
      }
    }
  }
}

/// Allows watching changes of any singular notification
@riverpod
class TopicNotificationStatus extends _$TopicNotificationStatus {
  @override
  TernaryStatus? build(TopicNotification topicNotification) {
    if (_topicNotifications.contains(topicNotification)) {
      return topicNotification.status;
    }
    return null;
  }
}
