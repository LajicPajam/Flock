import 'package:flutter/foundation.dart';

/// Lightweight debug logger for local troubleshooting.
void debugLog({
  required String location,
  required String message,
  Map<String, dynamic>? data,
  String? hypothesisId,
  String runId = 'run1',
}) {
  if (kReleaseMode) {
    return;
  }

  final prefix = hypothesisId == null ? '[debug][$runId]' : '[debug][$runId][$hypothesisId]';
  if (data == null || data.isEmpty) {
    debugPrint('$prefix $location: $message');
    return;
  }
  debugPrint('$prefix $location: $message | $data');
}
