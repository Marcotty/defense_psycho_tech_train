import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/reasoning_exercise.dart';

class ReasoningRepository {
  const ReasoningRepository({
    AssetBundle? assetBundle,
    this.assetPath = 'assets/exercises/reasoning.json',
  }) : _assetBundle = assetBundle;

  final AssetBundle? _assetBundle;
  final String assetPath;

  Future<List<ReasoningExercise>> loadExercises() async {
    final source = await (_assetBundle ?? rootBundle).loadString(assetPath);
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw FormatException(
        'Invalid reasoning JSON in "$assetPath": ${error.message}',
      );
    }
    if (decoded is! List<Object?> || decoded.isEmpty) {
      throw FormatException('Expected a non-empty JSON list in "$assetPath".');
    }

    final exercises = <ReasoningExercise>[];
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

  ReasoningExercise _parseExercise(Map<String, Object?> value, int index) {
    final id = value['id'];
    final rawEntities = value['entities'];
    final rawClues = value['clues'];
    final question = value['question'];
    final extremeValue = value['extreme'];
    if (id is! String || id.trim().isEmpty) {
      throw FormatException('Exercise $index must have a non-empty id.');
    }
    if (rawEntities is! List<Object?> ||
        rawEntities.length != 3 ||
        rawEntities.any((entity) => entity is! String) ||
        rawEntities.toSet().length != 3) {
      throw FormatException('Exercise "$id" must have three unique entities.');
    }
    if (rawClues is! List<Object?> || rawClues.length != 2) {
      throw FormatException('Exercise "$id" must have exactly two clues.');
    }
    if (question is! String || question.trim().isEmpty) {
      throw FormatException('Exercise "$id" must have a question.');
    }
    final extreme = switch (extremeValue) {
      'maximum' => OrderExtreme.maximum,
      'minimum' => OrderExtreme.minimum,
      _ => throw FormatException('Exercise "$id" has an invalid extreme.'),
    };

    final entities = rawEntities.cast<String>();
    final clues = [
      for (var clueIndex = 0; clueIndex < rawClues.length; clueIndex++)
        _parseClue(rawClues[clueIndex], id, clueIndex, entities),
    ];
    final exercise = ReasoningExercise(
      id: id,
      entities: List.unmodifiable(entities),
      clues: List.unmodifiable(clues),
      question: question,
      extreme: extreme,
    );
    try {
      exercise.orderedEntities;
    } on StateError catch (error) {
      throw FormatException('Invalid ordering in "$id": ${error.message}');
    }
    return exercise;
  }

  OrderingClue _parseClue(
    Object? value,
    String exerciseId,
    int index,
    List<String> entities,
  ) {
    if (value is! Map<String, Object?>) {
      throw FormatException('Clue $index in "$exerciseId" must be an object.');
    }
    final greater = value['greater'];
    final lesser = value['lesser'];
    final statement = value['statement'];
    if (greater is! String ||
        lesser is! String ||
        greater == lesser ||
        !entities.contains(greater) ||
        !entities.contains(lesser)) {
      throw FormatException(
        'Clue $index in "$exerciseId" has invalid entities.',
      );
    }
    if (statement is! String || statement.trim().isEmpty) {
      throw FormatException(
        'Clue $index in "$exerciseId" must have a statement.',
      );
    }
    return OrderingClue(
      greaterEntity: greater,
      lesserEntity: lesser,
      statement: statement,
    );
  }
}
