/// Displays a [VisualStatus] with a colored icon and a title
///
/// Authors:
///   * Heye Hamadmad
library;

import 'package:flutter/material.dart';
import '../../models/ternary_status.dart';
import '../../models/visual_status.dart';

class VisualStatusEntry extends StatelessWidget {
  final VisualStatus visualStatus;
  const VisualStatusEntry({super.key, required this.visualStatus});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Align(
            alignment: Alignment.centerLeft, child: visualStatus.status.icon),
      ),
      Expanded(
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(visualStatus.title),
        ),
      ),
    ]);
  }
}

extension TernaryStatusIcon on TernaryStatus {
  Icon get icon {
    switch (this) {
      case TernaryStatus.ok:
        return const Icon(
          Icons.check_box,
          color: Colors.green,
        );
      case TernaryStatus.abnormal:
        return const Icon(
          Icons.warning,
          color: Colors.yellow,
        );
      case TernaryStatus.critical:
        return const Icon(
          Icons.error,
          color: Colors.red,
        );
    }
  }
}
