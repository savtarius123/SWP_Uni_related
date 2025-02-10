/// Integrates [Clock], [VisualStatusList], [NotificationList] and [LastUpdated]
/// into a side bar
///
/// Authors:
///   * Heye Hamadmad
library;

import 'package:flutter/material.dart';
import 'clock.dart';
import 'last_updated.dart';
import 'notification_list.dart';
import 'visual_status_list.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
        width: 250,
        child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  child: Clock(),
                ),
                VisualStatusList(),
                Expanded(
                  child: NotificationList(),
                ),
                LastUpdated()
              ],
            )));
  }
}
