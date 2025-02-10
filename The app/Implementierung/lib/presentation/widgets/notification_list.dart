/// This code creates a widget called `NotificationList` that shows a scrollable list of notifications.
///
/// - It listens to a provider (`topicNotificationsProvider`) to get a list of notifications.
/// - Each notification is displayed as a `NotificationBubble` widget.
/// - The list updates automatically when the notifications change.
///
/// Authors:
///   * Heye Hamadmad
library;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/topic_notifications_provider.dart';
import 'notification_bubble.dart';

class NotificationList extends ConsumerWidget {
  const NotificationList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(topicNotificationsProvider);

    return ListView(
        children: notifications
            .map((topicNotification) =>
                NotificationBubble(topicNotification: topicNotification))
            .toList());
  }
}
