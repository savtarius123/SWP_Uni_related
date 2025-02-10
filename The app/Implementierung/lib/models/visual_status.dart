/// A visual status always has a [TernaryStatus] and an assigned [Title]
///
/// Authors:
///   * Heye Hamadmad
library;

import 'ternary_status.dart';

class VisualStatus {
  final TernaryStatus status;
  final String title;

  VisualStatus(this.status, this.title);
}
