/// Provides a list of [HwCategories] for every type of hardware, [HwCategoryInstances] for
/// any selected [HwCategory] and available [DisplayGroups] for each instance.
/// Grouped in a file due to contenual proximity.
///
/// Used in [TimeSeriesOverview] to organize and display data grouped by hardware.
///
/// Authors:
///   * Heye Hamadmad
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/display_group.dart';
import '../../models/time_series.dart';
import 'timeseries_notifier_provider.dart';

part 'category_neighbour_provider.g.dart';

/// Provides a list of [HwCategory] elements, depending on available
/// [SensorTimeSeries].
@riverpod
class HwCategories extends _$HwCategories {
  @override
  List<HwCategory> build() {
    List<HwCategory> categories = [];
    final allTimeSeries = ref.watch(allTimeSeriesProvider());
    for (final ts in allTimeSeries.values) {
      switch (ts) {
        case SensorTimeSeries(:final setpointRule):
          final newCategory = setpointRule?.displayGroup.hwCategory;
          if (!categories.contains(newCategory) && newCategory != null) {
            categories.add(newCategory);
          }
        case _:
      }
    }
    categories.sort();
    return categories;
  }
}

/// Takes a selected [HwCategory] and returns available instances of said Category.
@riverpod
class HwCategoryInstances extends _$HwCategoryInstances {
  @override
  List<int> build({HwCategory? hwCategory}) {
    if (hwCategory == null) {
      return [];
    }

    List<int> hwInstances = [];

    final allTimeSeries = ref.watch(allTimeSeriesProvider());
    for (final ts in allTimeSeries.values) {
      switch (ts) {
        case SensorTimeSeries(:final setpointRule, :final hwInstance):
          if (setpointRule?.displayGroup.hwCategory == hwCategory) {
            if (!hwInstances.contains(hwInstance) && hwInstance != null) {
              hwInstances.add(hwInstance);
            }
          }
        case _:
      }
    }
    hwInstances.sort();
    return hwInstances;
  }
}

/// Takes a selected [HwCategory] and a selected Instance and returns a list of
/// [DisplayGroup] for all available topics.
@riverpod
class DisplayGroups extends _$DisplayGroups {
  @override
  List<DisplayGroup> build({HwCategory? hwCategory, int? hwCategoryInstance}) {
    if (hwCategory == null || hwCategoryInstance == null) {
      return [];
    }

    List<DisplayGroup> displayGroups = [];

    final allTimeSeries = ref.watch(allTimeSeriesProvider());
    for (final ts in allTimeSeries.values) {
      switch (ts) {
        case SensorTimeSeries(:final setpointRule, :final hwInstance):
          if (setpointRule?.displayGroup.hwCategory == hwCategory &&
              hwInstance == hwCategoryInstance) {
            final newDisplayGroup = setpointRule?.displayGroup;
            if (!displayGroups.contains(newDisplayGroup) &&
                newDisplayGroup != null) {
              displayGroups.add(newDisplayGroup);
            }
          }
        case _:
      }
    }
    displayGroups.sort();
    return displayGroups;
  }
}
