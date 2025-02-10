/// Show average values (historical and current) for temperature, air pressure
/// and Air Quality Index
///
/// Authors:
///   * Heye Hamadmad
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/setpoint_rules_provider.dart';
import '../../application/time_series_provider_selector.dart';
import '../widgets/multiple_time_series_display.dart';

@RoutePage()
class EnvValuesAvgPage extends ConsumerWidget {
  const EnvValuesAvgPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var tempRule = ref.watch(setpointRulesProvider("board_temperature"));
    var pressureRule = ref.watch(setpointRulesProvider("board_pressure"));

    return MultipleTimeSeriesDisplay(entries: [
      AveragedTimeSeriesSelected(
          topics: tempRule!.topicMatcher, setpointRule: tempRule),
      AveragedTimeSeriesSelected(
          topics: pressureRule!.topicMatcher, setpointRule: pressureRule),
      AqiTimeSeriesSelected()
    ]);
  }
}
