/// Show the date and time of the most current update
///
/// Authors:
///   * Heye Hamadmad
///   * Arin Tanriverdi
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/timeseries_notifier_provider.dart';
import '../../application/util/current_time.dart';

class LastUpdated extends ConsumerWidget {
  const LastUpdated({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestUpdate = ref.watch(latestUpdateProvider);

    String latestUpdateText;
    if (latestUpdate == null) {
      latestUpdateText = "No data";
    } else {
      latestUpdateText =
          "Last updated: ${latestUpdate.toDate()} ${latestUpdate.toTimeOfDay()}";
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Text(latestUpdateText),
    );
  }
}
