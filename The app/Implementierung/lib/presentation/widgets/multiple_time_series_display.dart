/// Displays multiple time series on the same time axis. Link between [GraphWidget]
/// and [TimeSeriesOverviewPage]
///
/// Authors:
///   * Heye Hamadmad
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/time_series_provider_selector.dart';
import '../../application/util/current_time.dart';
import '../../models/time_series.dart';
import 'gauge_widget.dart';
import 'graph_widget.dart';

class MultipleTimeSeriesDisplay extends ConsumerStatefulWidget {
  /// Refers to both gauge and chart
  final double itemHeight = 300;
  final List<TimeSeriesProviderSelector> entries;

  /// When selected, on first build the list will startet out scrolled as far as
  /// possible toward the item
  final int? scrollToItem;

  const MultipleTimeSeriesDisplay(
      {super.key, required this.entries, this.scrollToItem});

  @override
  ConsumerState<MultipleTimeSeriesDisplay> createState() =>
      _MultipleTimeSeriesDisplayState();
}

class _MultipleTimeSeriesDisplayState
    extends ConsumerState<MultipleTimeSeriesDisplay> {
  late TransformationController _transformationController;
  late ValueNotifier<MartianTimeStamp> _startTime;
  late ValueNotifier<MartianTimeStamp> _endTime;

  /// Allows disabling vertical scrolling when the mouse is on a chart
  late ValueNotifier<bool> _listScrollingEnabled;
  late final ScrollController _scrollController;
  @override
  void initState() {
    // Handle horizontal scrolling and zooming in unison, also store the scroll
    // position between rebuilds

    _transformationController = TransformationController();
    _scrollController = ScrollController(
        initialScrollOffset: widget.itemHeight * (widget.scrollToItem ?? 0));

    _endTime = ValueNotifier(currentTime());
    _startTime =
        ValueNotifier(_getStartTime(ref: ref, entries: widget.entries));
    if (_startTime.value > _endTime.value) {
      throw Exception("Unexpected error: graph ends before it starts");
    }
    _listScrollingEnabled = ValueNotifier(true);
    super.initState();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _startTime.dispose();
    _endTime.dispose();
    _listScrollingEnabled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _listScrollingEnabled,
      builder: (myctx, canScroll, child) => SingleChildScrollView(
          physics: canScroll
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          controller: _scrollController,
          child: child),
      child: Table(
          columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: widget.entries
              .map((entry) => _getSingleTimeSeriesDisplay(entry))
              .toList()),
    );
  }

  TableRow _getSingleTimeSeriesDisplay(TimeSeriesProviderSelector entry) {
    return TableRow(children: [
      TableCell(
          child: SizedBox(
              height: widget.itemHeight,
              child: ConsumerGaugeWidget(tsProviderSelector: entry))),
      TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: MouseRegion(
              onEnter: (event) {
                _listScrollingEnabled.value = false;
              },
              onExit: (event) {
                _listScrollingEnabled.value = true;
              },
              child: ConsumerGraphWidget(
                startTimeNotifier: _startTime,
                endTimeNotifier: _endTime,
                tsProviderSelector: entry,
                transformationController: _transformationController,
              )))
    ]);
  }
}

MartianTimeStamp _getStartTime(
    {required WidgetRef ref,
    required List<TimeSeriesProviderSelector> entries}) {
  return entries
      .map((tsps) =>
          (ref.read(tsps.historicalMeasurementsProvider) as TimeSeries?)
              ?.firstOrNull
              ?.timestamp)
      .nonNulls
      .fold(currentTime() - 3600, (a, b) => a < b ? a : b);
}
