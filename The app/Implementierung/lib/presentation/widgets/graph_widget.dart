/// Display a TimeSeries as a plot of values over time
///
/// Authors:
///   * Heye Hamadmad
///   * Mohamed Aziz Mani
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/time_series_provider_selector.dart';
import '../../application/util/current_time.dart';
import '../../models/time_series.dart';

/// Directly read (and get updated by) values from a provider
///
/// [transformationController] and the [ValueNotifier]s enable the ability of
/// multiple graphs to be moved in unison
class ConsumerGraphWidget extends ConsumerWidget {
  final TimeSeriesProviderSelector tsProviderSelector;
  final TransformationController? transformationController;
  final ValueNotifier<MartianTimeStamp> startTimeNotifier;
  final ValueNotifier<MartianTimeStamp> endTimeNotifier;

  const ConsumerGraphWidget({
    super.key,
    required this.tsProviderSelector,
    this.transformationController,
    required this.startTimeNotifier,
    required this.endTimeNotifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late final double min, max;
    String? title;

    switch (tsProviderSelector) {
      case SensorTimeSeriesSelected(
          :final String topic,
          :final historicalMeasurementsProvider
        ):
        final setpointRule =
            (ref.watch(historicalMeasurementsProvider) as SensorTimeSeries)
                .setpointRule!;
        min = setpointRule.setpointRanges.rangeCritical.$1;
        max = setpointRule.setpointRanges.rangeCritical.$2;
        title = topic;
      case AveragedTimeSeriesSelected(:final setpointRule):
        min = setpointRule.setpointRanges.rangeCritical.$1;
        max = setpointRule.setpointRanges.rangeCritical.$2;
      case AqiTimeSeriesSelected():
        min = 0;
        max = 500;
    }

    final ts = ref.watch(tsProviderSelector.historicalMeasurementsProvider)
        as TimeSeries?;
    ref.watch(tsProviderSelector.currentMeasurementProvider);

    final lastTimestamp = ts?.lastOrNull?.timestamp;
    Future.microtask(() {
      // Can't update state within build
      if (lastTimestamp != null && lastTimestamp > endTimeNotifier.value) {
        endTimeNotifier.value = lastTimestamp;
      }
    });
    final firstTimestamp = ts?.firstOrNull?.timestamp;
    Future.microtask(() {
      // Can't update state within build
      if (firstTimestamp != null && firstTimestamp < startTimeNotifier.value) {
        startTimeNotifier.value = firstTimestamp;
      }
    });

    return ValueListenableBuilder(
        valueListenable: endTimeNotifier,
        builder: (endCtx, endTime, _) => ValueListenableBuilder(
            valueListenable: startTimeNotifier,
            builder: (startCtx, startTime, _) => _GraphWidget(
                data: ts ?? PlainTimeSeries(),
                min: min,
                max: max,
                transformationController: transformationController,
                startTime: startTime,
                endTime: endTime,
                title: title)));
  }
}

class _GraphWidget extends StatelessWidget {
  final TimeSeries data;
  final double min;
  final double max;
  final MartianTimeStamp startTime;
  final MartianTimeStamp endTime;
  final TransformationController? transformationController;
  final String? title;

  const _GraphWidget({
    required this.data,
    required this.min,
    required this.max,
    required this.startTime,
    required this.endTime,
    this.transformationController,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    double minScale = 1;
    double maxScale = (endTime - startTime) / 300; // 5 minutes
    if (maxScale < minScale) {
      maxScale = 2 * minScale;
    }
    return SafeArea(
      //so the chart doesn't collide with other parts of the page
      minimum: const EdgeInsets.only(top: 5, right: 15), //applied padding
      child: Center(
          child: Stack(
        children: [
          LineChart(
            transformationConfig: FlTransformationConfig(
              transformationController: transformationController,
              scaleAxis: FlScaleAxis.horizontal,
              minScale: minScale,
              maxScale: maxScale,
            ),
            LineChartData(
              gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (value) =>
                    const FlLine(color: Colors.grey, strokeWidth: 0.5),
                getDrawingVerticalLine: (value) =>
                    const FlLine(color: Colors.grey, strokeWidth: 0.5),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toTimeOfDay(),
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      );
                    },
                    reservedSize: 25,
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey),
              ),
              minX: startTime,
              maxX: endTime,
              minY: min,
              maxY: max,
              lineBarsData: [
                LineChartBarData(
                  dotData:
                      FlDotData(getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius:
                          3.0, // Decrease the radius value to reduce the size of the dot
                      color: Colors.black, // You can set the color of the dot
                      strokeColor: Colors.black,
                      strokeWidth: 0.0, // You can also adjust the stroke width
                    );
                  }),
                  preventCurveOverShooting: true,
                  spots: data.map((e) => FlSpot(e.timestamp, e.value)).toList(),
                  isCurved: true,
                  color: const Color.fromARGB(255, 71, 71, 71),
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Color.fromARGB((255 * 0.2).toInt(), 60, 15, 68),
                  ),
                ),
              ],
              lineTouchData: const LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
              )),
              clipData: const FlClipData.vertical(),
            ),
          ),
          Positioned(
            top: 3,
            left: 40,
            child: Text(
              title ?? "",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      )),
    );
  }
}
