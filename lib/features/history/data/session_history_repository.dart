import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/models/training_mode.dart';
import '../domain/session_result.dart';

class SessionHistoryRepository {
  const SessionHistoryRepository();

  static const _historyKey = 'sessionHistory';
  static const _maximumEntries = 500;

  Future<List<SessionResult>> loadSessions() async {
    final preferences = await SharedPreferences.getInstance();
    final values = preferences.getStringList(_historyKey) ?? const [];
    return List.unmodifiable(values.map(_decode));
  }

  Future<void> saveSession(SessionResult result) async {
    if (result.questionCount <= 0 ||
        result.correctCount < 0 ||
        result.correctCount > result.questionCount ||
        result.elapsed.isNegative ||
        result.testTitle.trim().isEmpty ||
        (result.mode == TrainingMode.timedTest && result.timeLimit == null) ||
        (result.timeLimit != null && result.timeLimit!.inSeconds <= 0)) {
      throw ArgumentError.value(result, 'result', 'Invalid session result.');
    }

    final preferences = await SharedPreferences.getInstance();
    final existing = preferences.getStringList(_historyKey) ?? <String>[];
    final next = [
      jsonEncode(_encode(result)),
      ...existing,
    ].take(_maximumEntries).toList();
    await preferences.setStringList(_historyKey, next);
  }

  Map<String, Object?> _encode(SessionResult result) => {
    'testTitle': result.testTitle,
    'mode': result.mode.name,
    'startedAt': result.startedAt.toIso8601String(),
    'elapsedSeconds': result.elapsed.inSeconds,
    'elapsedMilliseconds': result.elapsed.inMilliseconds,
    'correctCount': result.correctCount,
    'questionCount': result.questionCount,
    'timeLimitSeconds': result.timeLimit?.inSeconds,
  };

  SessionResult _decode(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw FormatException('Invalid saved session record: ${error.message}');
    }
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Saved session record must be an object.');
    }

    final title = decoded['testTitle'];
    final modeName = decoded['mode'];
    final startedAtValue = decoded['startedAt'];
    final elapsedSeconds = decoded['elapsedSeconds'];
    final elapsedMilliseconds = decoded['elapsedMilliseconds'];
    final correctCount = decoded['correctCount'];
    final questionCount = decoded['questionCount'];
    final timeLimitSeconds = decoded['timeLimitSeconds'];
    final mode = switch (modeName) {
      'practice' => TrainingMode.practice,
      'timedTest' => TrainingMode.timedTest,
      _ => null,
    };

    if (title is! String ||
        title.isEmpty ||
        mode == null ||
        startedAtValue is! String ||
        DateTime.tryParse(startedAtValue) == null ||
        elapsedSeconds is! int ||
        elapsedMilliseconds is! int ||
        correctCount is! int ||
        questionCount is! int ||
        (timeLimitSeconds != null && timeLimitSeconds is! int)) {
      throw const FormatException('Saved session record has invalid fields.');
    }

    final timeLimit = timeLimitSeconds == null
        ? null
        : Duration(seconds: timeLimitSeconds as int);
    if (elapsedSeconds < 0 ||
        elapsedMilliseconds < 0 ||
        correctCount < 0 ||
        questionCount <= 0 ||
        correctCount > questionCount ||
        (timeLimit != null && timeLimit <= Duration.zero) ||
        (mode == TrainingMode.timedTest && timeLimit == null)) {
      throw const FormatException('Saved session record is out of range.');
    }

    return SessionResult(
      testTitle: title,
      mode: mode,
      startedAt: DateTime.parse(startedAtValue),
      elapsed: Duration(milliseconds: elapsedMilliseconds),
      correctCount: correctCount,
      questionCount: questionCount,
      timeLimit: timeLimit,
    );
  }
}
