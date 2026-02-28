import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

const _kIngestUrl = 'http://127.0.0.1:7615/ingest/9ea8c523-8fb1-4823-a780-24e89fc330a3';
const _kSessionId = '92fef5';

/// Appends one NDJSON log line for this debug session (POST to ingest; server writes to debug-92fef5.log).
void debugLog({
  required String location,
  required String message,
  Map<String, dynamic>? data,
  String? hypothesisId,
  String runId = 'run1',
}) {
  final payload = {
    'sessionId': _kSessionId,
    'runId': runId,
    ...? (hypothesisId != null ? {'hypothesisId': hypothesisId} : null),
    'location': location,
    'message': message,
    ...? (data != null ? {'data': data} : null),
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };
  if (kReleaseMode) return;
  http
      .post(
        Uri.parse(_kIngestUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Debug-Session-Id': _kSessionId,
        },
        body: jsonEncode(payload),
      )
      .catchError((_) => http.Response('', 0));
}
