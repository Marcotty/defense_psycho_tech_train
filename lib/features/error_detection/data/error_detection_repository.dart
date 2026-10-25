import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/error_detection_exercise.dart';

class ErrorDetectionRepository {
  const ErrorDetectionRepository({
    AssetBundle? assetBundle,
    this.assetPath = 'assets/exercises/error_detection.json',
  }) : _assetBundle = assetBundle;

  final AssetBundle? _assetBundle;
  final String assetPath;

  Future<List<ErrorDetectionExercise>> loadExercises() async {
    final source = await (_assetBundle ?? rootBundle).loadString(assetPath);
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw FormatException(
        'Invalid error-detection JSON in "$assetPath": ${error.message}',
      );
    }
    if (decoded is! List<Object?> || decoded.isEmpty) {
      throw FormatException('Expected a non-empty JSON list in "$assetPath".');
    }

    final exercises = <ErrorDetectionExercise>[];
    for (var index = 0; index < decoded.length; index++) {
      final value = decoded[index];
      if (value is! Map<String, Object?>) {
        throw FormatException(
          'Exercise $index in "$assetPath" must be an object.',
        );
      }
      exercises.add(_parseExercise(value, index));
    }
    return List.unmodifiable(exercises);
  }

  ErrorDetectionExercise _parseExercise(Map<String, Object?> value, int index) {
    final id = value['id'];
    final original = value['original'];
    final copy = value['copy'];
    if (id is! String || id.trim().isEmpty) {
      throw FormatException('Exercise $index must have a non-empty id.');
    }
    if (original is! String ||
        copy is! String ||
        original.length != copy.length) {
      throw FormatException(
        'Exercise "$id" must contain original and copy strings of equal length.',
      );
    }

    final exercise = ErrorDetectionExercise(
      id: id,
      original: original,
      copy: copy,
    );
    if (exercise.differenceCount > 4) {
      throw FormatException('Exercise "$id" has more than four differences.');
    }
    return exercise;
  }
}
