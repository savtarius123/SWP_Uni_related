/// A simple list of [VisualStatusEntry] elements
///
/// Authors:
///   * Heye Hamadmad
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/visual_primary_status_provider.dart';

import 'visual_status_entry.dart';

class VisualStatusList extends ConsumerWidget {
  const VisualStatusList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visualPrimaryStatus = ref.watch(visualPrimaryStatusProvider);

    return Column(
        children: visualPrimaryStatus
            .map(
                (visualStatus) => VisualStatusEntry(visualStatus: visualStatus))
            .toList());
  }
}
