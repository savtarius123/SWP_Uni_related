/// Displays and updates a digital clock
///
/// Authors:
///   * Heye Hamadmad
///   * Arin Tanriverdi
library;

import 'dart:async';

import 'package:flutter/widgets.dart';
import '../../application/util/current_time.dart';

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  State<StatefulWidget> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  String _currentTime = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    //Might be modified here to update at the exact time, ideally without expensive polling
    _timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    setState(() {
      _currentTime = currentTime().toTimeOfDay();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Text(_currentTime),
    );
  }
}
