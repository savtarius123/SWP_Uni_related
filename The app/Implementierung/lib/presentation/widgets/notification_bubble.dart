/// This code defines a `NotificationBubble` widget that displays a single notification with details about its status,
/// associated setpoint rule, and measurement information.
///
/// **Key Features**:
/// - Dynamically updates the content and appearance of the notification based on the status (`ok`, `abnormal`, `critical`).
/// - Provides an option to dismiss notifications when their status is resolved.
///
/// **How it works**:
/// - Fetches the notification details from `singularTopicNotificationProvider`.
/// - Determines the background color of the bubble based on the notification status:
///   - Green for `ok`, yellow for `abnormal`, red for `critical`.
/// - Displays the notification's title, status message, topic, and timestamp of the first appearance.
/// - If the notification is resolved (`ok`), shows a "Dismiss" button to remove it from the list.
///
/// Authors:
///   * Heye Hamadmad
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/timeseries_notifier_provider.dart';
import '../../application/providers/topic_notifications_provider.dart';
import '../../application/util/current_time.dart';
import '../../models/ternary_status.dart';
import '../../models/topic_notification.dart';
import '../../routes/app_router.dart';
import 'visual_status_entry.dart';

class NotificationBubble extends ConsumerWidget {
  final TopicNotification topicNotification;

  const NotificationBubble({super.key, required this.topicNotification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TernaryStatus? notificationStatus =
        ref.watch(topicNotificationStatusProvider(topicNotification));

    if (notificationStatus == null) {
      return const Placeholder(); // Should never occur. Maybe throw instead?
    }

    final backgroundColor = switch (notificationStatus) {
      TernaryStatus.ok => Colors.green,
      TernaryStatus.abnormal => Colors.yellow,
      TernaryStatus.critical => Colors.red,
    }
        .withValues(alpha: 0.2);

    final latestMeasurement =
        ref.watch(timeSeriesNotifierProvider(topicNotification.topic))?.last;

    final String title =
        "${topicNotification.setpointRule.title} ${switch (topicNotification.status) {
      TernaryStatus.ok => "Status",
      _ => "Warning"
    }}";
    late String statusMessage;

    if (latestMeasurement != null) {
      if (topicNotification.status == TernaryStatus.ok) {
        statusMessage =
            "${topicNotification.setpointRule.title} has been out of range from ${topicNotification.firstAppearance.toTimeOfDay()} to ${topicNotification.okSince!.toTimeOfDay()}.";
      } else if (latestMeasurement.value <
          topicNotification.setpointRule.setpointRanges.rangeOk.$1) {
        statusMessage =
            "${topicNotification.setpointRule.title} too low: ${latestMeasurement.value.toStringAsFixed(2)} ${topicNotification.setpointRule.unit}";
      } else if (latestMeasurement.value >
          topicNotification.setpointRule.setpointRanges.rangeOk.$2) {
        statusMessage =
            "${topicNotification.setpointRule.title} too high: ${latestMeasurement.value.toStringAsFixed(2)} ${topicNotification.setpointRule.unit}";
      } else {
        statusMessage = "Error: value is in range but status is not ok!";
      }
    } else {
      statusMessage =
          "Error: topicNotification.setpointRule or latestMeasurement is null";
    }

    return Padding(
        padding: const EdgeInsets.all(4),
        child: InkWell(
          child: Container(
              decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(),
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: IntrinsicHeight(
                  child: Row(
                children: [
                  topicNotification.status.icon,
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(title),
                        Text(statusMessage),
                        Text(topicNotification.topic),
                      ])),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                        Visibility(
                            visible:
                                topicNotification.status == TernaryStatus.ok,
                            child: TextButton(
                                onPressed: () {
                                  ref
                                      .read(topicNotificationsProvider.notifier)
                                      .dismiss(topicNotification);
                                },
                                child: const Text("Dismiss"))),
                        const Spacer(),
                        Text(topicNotification.firstAppearance.toTimeOfDay())
                      ]))
                ],
              ))),
          onTap: () {
            AutoRouter.of(context).navigate(TimeSeriesOverviewRoute(
                highlightedTopic: topicNotification.topic));
          },
        ));
  }
}
