/// Groups topics by hardware, instance and display group. Can show multiple
/// timeseries at once.
///
/// Authors:
///   * Heye Hamadmad
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/category_neighbour_provider.dart';
import '../../application/providers/timeseries_notifier_provider.dart';
import '../../application/time_series_provider_selector.dart';
import '../../models/display_group.dart';
import '../../models/time_series.dart';
import '../../routes/app_router.dart';
import '../widgets/multiple_time_series_display.dart';

@RoutePage()
class TimeSeriesOverviewPage extends ConsumerWidget {
  final String? highlightedTopic;
  final HwCategory? selectedHwCategory;
  final int? selectedHwInstance;
  final DisplayGroup? selectedDisplayGroup;
  const TimeSeriesOverviewPage(
      {super.key,
      this.highlightedTopic,
      this.selectedHwCategory,
      this.selectedHwInstance,
      this.selectedDisplayGroup});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var internalSelectedHwCategory = selectedHwCategory;
    var internalSelectedHwInstance = selectedHwInstance;
    var internalSelectedDisplayGroup = selectedDisplayGroup;
    if (highlightedTopic != null) {
      final highlightedTs =
          ref.watch(timeSeriesNotifierProvider(highlightedTopic!));
      switch (highlightedTs) {
        case SensorTimeSeries(:final setpointRule, :final hwInstance):
          if (setpointRule != null && hwInstance != null) {
            internalSelectedHwCategory = setpointRule.displayGroup.hwCategory;
            internalSelectedHwInstance = hwInstance;
            internalSelectedDisplayGroup = setpointRule.displayGroup;
          }
        case _:
      }
    }

    final hwCategories = ref.watch(hwCategoriesProvider);
    if (internalSelectedHwCategory == null ||
        !hwCategories.contains(internalSelectedHwCategory)) {
      internalSelectedHwCategory = hwCategories.firstOrNull;
    }

    final hwInstances = ref.watch(
        hwCategoryInstancesProvider(hwCategory: internalSelectedHwCategory));
    if (internalSelectedHwInstance == null ||
        !hwInstances.contains(internalSelectedHwInstance)) {
      internalSelectedHwInstance = hwInstances.firstOrNull;
    }

    final displayGroups = ref.watch(displayGroupsProvider(
        hwCategory: internalSelectedHwCategory,
        hwCategoryInstance: internalSelectedHwInstance));
    if (internalSelectedDisplayGroup == null ||
        !displayGroups.contains(internalSelectedDisplayGroup)) {
      internalSelectedDisplayGroup = displayGroups.firstOrNull;
    }
    List<SensorTimeSeries> relevantTs = [];

    if (internalSelectedHwCategory != null &&
        internalSelectedHwInstance != null &&
        internalSelectedDisplayGroup != null) {
      final allTimeSeries = ref.watch(allTimeSeriesProvider());

      for (final ts in allTimeSeries.entries) {
        switch (ts.value) {
          case SensorTimeSeries(:final setpointRule, :final hwInstance):
            if (setpointRule?.displayGroup == internalSelectedDisplayGroup &&
                hwInstance == internalSelectedHwInstance) {
              relevantTs.add(ts.value as SensorTimeSeries);
            }
          case _:
        }
      }
      relevantTs.sort((a, b) => (a.topic ?? "").compareTo(b.topic ?? ""));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Row with dropdowns
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: DropdownButton<HwCategory>(
                  value: internalSelectedHwCategory,
                  isExpanded: true,
                  items: hwCategories
                      .map((hwCategory) => DropdownMenuItem<HwCategory>(
                            value: hwCategory,
                            child: Text(hwCategory.title),
                          ))
                      .toList(),
                  onChanged: (value) {
                    context.router.replace(TimeSeriesOverviewRoute(
                        selectedHwCategory: value,
                        selectedHwInstance: internalSelectedHwInstance,
                        selectedDisplayGroup: internalSelectedDisplayGroup));
                  },
                  hint: const Text("Select Hardware Category"),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  dropdownColor: Colors.white,
                ),
              ),

              const SizedBox(width: 16), // Spacing between dropdowns

              Expanded(
                flex: 2,
                child: DropdownButton<int>(
                  value: internalSelectedHwInstance,
                  isExpanded: true,
                  items: hwInstances
                      .map((hwInstance) => DropdownMenuItem<int>(
                            value: hwInstance,
                            child: Text(hwInstance.toString()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    context.router.replace(TimeSeriesOverviewRoute(
                        selectedHwCategory: internalSelectedHwCategory,
                        selectedHwInstance: value,
                        selectedDisplayGroup: internalSelectedDisplayGroup));
                  },
                  hint: const Text("Select Hardware Instance"),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  dropdownColor: Colors.white,
                ),
              ),

              const SizedBox(width: 16), // Spacing between dropdowns

              Expanded(
                flex: 2,
                child: DropdownButton<DisplayGroup>(
                  value: internalSelectedDisplayGroup,
                  isExpanded: true,
                  items: displayGroups
                      .map((displayGroup) => DropdownMenuItem<DisplayGroup>(
                            value: displayGroup,
                            child: Text(displayGroup.title),
                          ))
                      .toList(),
                  onChanged: (value) {
                    context.router.replace(TimeSeriesOverviewRoute(
                        selectedHwCategory: internalSelectedHwCategory,
                        selectedHwInstance: internalSelectedHwInstance,
                        selectedDisplayGroup: value));
                  },
                  hint: const Text("Select Display Group"),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  dropdownColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Spacing between rows
          // Placeholder for content display
          Expanded(
            child: MultipleTimeSeriesDisplay(
                entries: relevantTs
                    .where((ts) => ts.topic != null)
                    .map((ts) => SensorTimeSeriesSelected(topic: ts.topic!))
                    .toList(),
                scrollToItem: relevantTs
                    .where((ts) => ts.topic != null)
                    .indexed
                    .where((item) => item.$2.topic == highlightedTopic)
                    .firstOrNull
                    ?.$1),
          )
        ],
      ),
    );
  }
}
