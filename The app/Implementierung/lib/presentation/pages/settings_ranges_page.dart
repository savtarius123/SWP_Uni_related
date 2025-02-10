/// Allows reading out and setting setpoints / ranges
///
/// Authors:
///   * Cem Igci
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/setpoint_rules_provider.dart';
import '../../models/setpoint_rule.dart';

@RoutePage()
class SettingsRangesPage extends StatefulWidget {
  const SettingsRangesPage({super.key});

  @override
  State<SettingsRangesPage> createState() => _SettingsRangesPageState();
}

class _SettingsRangesPageState extends State<SettingsRangesPage> {
  final List<TextEditingController> _controllers =
      []; // List to store controllers
  Iterable<String> ruleIds = [];

  @override
  void initState() {
    super.initState();
    final container = ProviderScope.containerOf(context, listen: false);
    ruleIds = container.read(setpointRuleIdsProvider);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ruleIds.isEmpty
        ? const Center(child: Text("No rules available"))
        : SingleChildScrollView(
            child: Column(
              children: [
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: _buildColumns(),
                      rows: _buildRows(ruleIds),
                    )),
                const SizedBox(height: 20),
              ],
            ),
          );
  }

  List<DataColumn> _buildColumns() {
    return [
      const DataColumn(label: SizedBox.shrink()),
      const DataColumn(label: Text("Lower Limit")),
      const DataColumn(label: Text("Yellow Min")),
      const DataColumn(label: Text("Min OK")),
      const DataColumn(label: Text("Max OK")),
      const DataColumn(label: Text("Yellow Max")),
      const DataColumn(label: Text("Upper Limit")),
      const DataColumn(label: Text("Unit")),
    ];
  }

  List<DataRow> _buildRows(Iterable<String> ruleIds) {
    return ruleIds.map((ruleId) {
      final container = ProviderScope.containerOf(context, listen: false);
      final rule = container.read(setpointRulesProvider(ruleId));
      if (rule == null) {
        throw Exception("Setpoint rule for ruleId is null: \$ruleId");
      }

      return DataRow(cells: [
        DataCell(Text(rule.title)),
        _editableCell(
          rule.setpointRanges.rangeCritical.$1.toString(),
          (value) {
            _updateRange(ruleId, rangeCriticalLower: double.tryParse(value));
          },
        ),
        _editableCell(
          rule.setpointRanges.rangeAbnormal.$1.toString(),
          (value) {
            _updateRange(ruleId, rangeAbnormalLower: double.tryParse(value));
          },
        ),
        _editableCell(
          rule.setpointRanges.rangeOk.$1.toString(),
          (value) {
            _updateRange(ruleId, rangeOkLower: double.tryParse(value));
          },
        ),
        _editableCell(
          rule.setpointRanges.rangeOk.$2.toString(),
          (value) {
            _updateRange(ruleId, rangeOkUpper: double.tryParse(value));
          },
        ),
        _editableCell(
          rule.setpointRanges.rangeAbnormal.$2.toString(),
          (value) {
            _updateRange(ruleId, rangeAbnormalUpper: double.tryParse(value));
          },
        ),
        _editableCell(
          rule.setpointRanges.rangeCritical.$2.toString(),
          (value) {
            _updateRange(ruleId, rangeCriticalUpper: double.tryParse(value));
          },
        ),
        DataCell(Text(rule.unit ?? "")),
      ]);
    }).toList();
  }

  DataCell _editableCell(String initialValue, Function(String) onChanged) {
    return DataCell(
      Builder(
        builder: (context) {
          final controller = TextEditingController(text: initialValue);
          _controllers.add(controller);
          return TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            onSubmitted: (value) {
              if (value.isNotEmpty && double.tryParse(value) != null) {
                onChanged(value);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Settings applied successfully!")));
              }
            },
            decoration: const InputDecoration(border: InputBorder.none),
          );
        },
      ),
    );
  }

  void _updateRange(
    String ruleId, {
    double? rangeCriticalLower,
    double? rangeCriticalUpper,
    double? rangeAbnormalLower,
    double? rangeAbnormalUpper,
    double? rangeOkLower,
    double? rangeOkUpper,
  }) {
    final container = ProviderScope.containerOf(context, listen: false);
    final notifier = container.read(setpointRulesProvider(ruleId).notifier);
    final currentRule = container.read(setpointRulesProvider(ruleId));

    if (currentRule == null) {
      throw Exception("Setpoint rule for ruleId is null: \$ruleId");
    }

    final ruleSetpoint = currentRule.setpointRanges;
    final updatedRanges = SetpointRanges(rangeOk: (
      rangeOkLower ?? ruleSetpoint.rangeOk.$1,
      rangeOkUpper ?? ruleSetpoint.rangeOk.$2
    ), rangeAbnormal: (
      rangeAbnormalLower ?? ruleSetpoint.rangeAbnormal.$1,
      rangeAbnormalUpper ?? ruleSetpoint.rangeAbnormal.$2
    ), rangeCritical: (
      rangeCriticalLower ?? ruleSetpoint.rangeCritical.$1,
      rangeCriticalUpper ?? ruleSetpoint.rangeCritical.$2
    ));

    notifier.setSetpointRanges(updatedRanges);
  }
}
