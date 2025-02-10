/// Displays all available hardware in a list of 3D models
///
/// Authors:
///   * Heye Hamadmad
library;

import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/category_neighbour_provider.dart';
import '../../models/display_group.dart';
import '../../routes/app_router.dart';
import 'photobioreactor.dart';
import 'sensor_board.dart';

class Hw3dDisplay extends ConsumerWidget {
  const Hw3dDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fill map of HWCategories to instance numbers with available devices
    final List<(HwCategory, int)> availableHw = [];
    for (final hwCategory in ref.watch(hwCategoriesProvider)) {
      for (final hwInstance
          in ref.watch(hwCategoryInstancesProvider(hwCategory: hwCategory))) {
        availableHw.add((hwCategory, hwInstance));
      }
    }
    availableHw.sort(
        (a, b) => a.$1 == b.$1 ? (a.$2.compareTo(b.$2)) : a.$1.compareTo(b.$1));

    final paddingHeight = 20;
    final itemHeight = 70;

    return SizedBox(
        width: 70,
        child: LayoutBuilder(
            builder: (context, constraints) => Padding(
                padding: EdgeInsets.only(
                    top: max(
                        ((constraints.maxHeight -
                                ((paddingHeight + itemHeight) *
                                    availableHw.length) -
                                paddingHeight) /
                            2),
                        0)),
                child: ListView.builder(
                    itemCount: availableHw.length,
                    itemBuilder: (ctx, index) => Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: GestureDetector(
                            onTap: () {
                              context.router.navigate(TimeSeriesOverviewRoute(
                                  selectedHwCategory: availableHw[index].$1,
                                  selectedHwInstance: availableHw[index].$2));
                            },
                            child: Tooltip(
                              margin: EdgeInsets.only(left: 140),
                              message:
                                  "${availableHw[index].$1.title} ${availableHw[index].$2}",
                              child: SizedBox(
                                  height: 70,
                                  child: availableHw[index].$1.fancyWidget),
                            )))))));
  }
}

extension FancyWidget on HwCategory {
  Widget? get fancyWidget {
    return switch (this) {
      HwCategory.board => SensorBoard(),
      HwCategory.pbr => Photobioreactor(),
      // ignore: unreachable_switch_case // In case of future expansion
      _ => Icon(Icons.question_mark),
    };
  }
}
