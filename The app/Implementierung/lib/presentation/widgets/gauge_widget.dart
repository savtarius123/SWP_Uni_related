/// Displays a value within some ranges.
///
/// Authors:
///   * Heye Hamadmad
///   * Mohamed Aziz Mani
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';

import '../../application/time_series_provider_selector.dart';
import '../../models/measurement.dart';
import '../../models/setpoint_rule.dart';
import '../../models/time_series.dart';

/// Allows directly adapting a gauge widget to data from a provider
class ConsumerGaugeWidget extends ConsumerWidget {
  final TimeSeriesProviderSelector tsProviderSelector;

  const ConsumerGaugeWidget({super.key, required this.tsProviderSelector});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(tsProviderSelector.currentMeasurementProvider)
        as Measurement?;

    switch (tsProviderSelector) {
      case SensorTimeSeriesSelected():
        final setpointRule =
            (ref.read(tsProviderSelector.historicalMeasurementsProvider)
                    as SensorTimeSeries)
                .setpointRule!;
        return _RuleGaugeWidget(
          setpointRule: setpointRule,
          value: current?.value,
        );
      case AveragedTimeSeriesSelected(:final setpointRule):
        return _RuleGaugeWidget(
          setpointRule: setpointRule,
          value: current?.value,
        );
      case AqiTimeSeriesSelected():
        return _LinearGaugeWidget(
          // AQI has a different color scheme
          unit: ' ',
          title: "Air Quality Index",
          value: current?.value,
          start: 0,
          end: 500,
          ranges: [
            RangeLinearGauge(start: 0, end: 50, color: Colors.green),
            RangeLinearGauge(start: 50, end: 100, color: Colors.yellow),
            RangeLinearGauge(
              start: 100,
              end: 150,
              color: const Color.fromRGBO(255, 126, 0, 1),
            ),
            RangeLinearGauge(start: 150, end: 200, color: Colors.red),
            RangeLinearGauge(
              start: 200,
              end: 300,
              color: const Color.fromRGBO(143, 63, 151, 1),
            ),
            RangeLinearGauge(
              start: 300,
              end: 500,
              color: const Color.fromRGBO(126, 0, 35, 1),
            ),
          ],
        );
    }
  }
}

/// Default color scheme; take ranges from a [SetpointRule]
class _RuleGaugeWidget extends StatelessWidget {
  final SetpointRule setpointRule;
  final double? value;

  const _RuleGaugeWidget({required this.setpointRule, this.value});

  @override
  Widget build(BuildContext context) {
    return _LinearGaugeWidget(
        title:
            '${setpointRule.title}${setpointRule.unit != null ? " (${setpointRule.unit})" : ""}',
        unit: setpointRule.unit,
        value: value,
        start: setpointRule.setpointRanges.rangeCritical.$1,
        end: setpointRule.setpointRanges.rangeCritical.$2,
        ranges: [
          RangeLinearGauge(
            start: setpointRule.setpointRanges.rangeCritical.$1,
            end: setpointRule.setpointRanges.rangeAbnormal.$1,
            color: Colors.red,
          ),
          RangeLinearGauge(
            start: setpointRule.setpointRanges.rangeAbnormal.$1,
            end: setpointRule.setpointRanges.rangeOk.$1,
            color: Colors.yellow,
          ),
          RangeLinearGauge(
            start: setpointRule.setpointRanges.rangeOk.$1,
            end: setpointRule.setpointRanges.rangeOk.$2,
            color: Colors.green,
          ),
          RangeLinearGauge(
            start: setpointRule.setpointRanges.rangeOk.$2,
            end: setpointRule.setpointRanges.rangeAbnormal.$2,
            color: Colors.yellow,
          ),
          RangeLinearGauge(
            start: setpointRule.setpointRanges.rangeAbnormal.$2,
            end: setpointRule.setpointRanges.rangeCritical.$2,
            color: Colors.red,
          ),
        ].where((rlg) => rlg.start != rlg.end).toList());
  }
}

/// Display a singular value on a vertical bar with defined ranges
class _LinearGaugeWidget extends StatelessWidget {
  final String title;
  final double start;
  final double end;
  final double? value;
  final String? unit;
  final PointerShape pointerShape = PointerShape.triangle;
  final List<RangeLinearGauge> ranges;
  final GaugeOrientation orientation = GaugeOrientation.vertical;
  final TextStyle rulerTextStyle = const TextStyle(
      fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black);
  final RulerPosition rulerPosition = RulerPosition.right;

  const _LinearGaugeWidget({
    required this.title,
    required this.start,
    required this.end,
    required this.value,
    required this.unit,
    required this.ranges,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Take full width of the parent
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: LinearGauge(
              fillExtend: true,
              enableGaugeAnimation: true,
              extendLinearGauge: 0.1,
              linearGaugeBoxDecoration: const LinearGaugeBoxDecoration(
                thickness: 30,
                edgeStyle: LinearEdgeStyle.bothCurve,
                linearGaugeValueColor: Colors.black,
              ),
              animationDuration: 2000,
              animationType: Easing.emphasizedDecelerate,
              start: start,
              end: end,
              pointers: value != null
                  ? [
                      Pointer(
                        value: value! >= start && value! <= end
                            ? value!
                            : (value! < start
                                ? start
                                : end), // Clamp pointer to top or bottom if value is out of range
                        shape: pointerShape,
                        pointerPosition: PointerPosition.left,
                        color: value! >= start && value! <= end
                            ? Colors.black
                            : Colors.black.withValues(alpha: 0.2),
                        animationType: Easing.emphasizedDecelerate,
                        showLabel: false,
                        isInteractive: false,
                        width: 20,
                        height: 20,
                      ),
                    ]
                  : [],
              rangeLinearGauge: ranges,
              gaugeOrientation: orientation,
              rulers: RulerStyle(
                rulerPosition: rulerPosition,
                textStyle: rulerTextStyle,
                secondaryRulersWidth: 1,
                primaryRulersWidth: 2,
                showLabel: true,
                primaryRulerColor: Colors.black,
                secondaryRulerColor: Colors.black,
              ),
            ),
          ),
          if (value != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${value!.toStringAsFixed(1)} ${unit ?? ''}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
