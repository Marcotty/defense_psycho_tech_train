import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/spatial_exercise.dart';

class SpatialExerciseRepository {
  const SpatialExerciseRepository({
    AssetBundle? assetBundle,
    this.assetPath = 'assets/exercises/spatial_orientation.json',
  }) : _assetBundle = assetBundle;

  final AssetBundle? _assetBundle;
  final String assetPath;

  Future<List<SpatialExercise>> loadExercises() async {
    final source = await (_assetBundle ?? rootBundle).loadString(assetPath);
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw FormatException(
        'Invalid spatial exercise JSON in "$assetPath": ${error.message}',
      );
    }

    if (decoded is! List<Object?>) {
      throw FormatException(
        'Expected a JSON list of exercises in "$assetPath".',
      );
    }

    final exercises = <SpatialExercise>[];
    for (var index = 0; index < decoded.length; index++) {
      final value = decoded[index];
      if (value is! Map<String, Object?>) {
        throw FormatException(
          'Exercise at index $index in "$assetPath" must be an object.',
        );
      }
      exercises.add(_parseExercise(value, index));
    }
    if (exercises.isEmpty) {
      throw FormatException('No exercises found in "$assetPath".');
    }

    return List.unmodifiable(exercises);
  }

  SpatialExercise _parseExercise(Map<String, Object?> value, int index) {
    final id = value['id'];
    final correctTileIndex = value['correctTileIndex'];
    if (id is! String || id.trim().isEmpty) {
      throw FormatException(
        'Exercise at index $index must have a non-empty id.',
      );
    }
    if (correctTileIndex is! int ||
        correctTileIndex < 0 ||
        correctTileIndex >= 6) {
      throw FormatException(
        'Exercise "$id" must have a correctTileIndex between 0 and 5.',
      );
    }

    final rules = _parseRules(value['rules'], id);
    final rawTiles = value['tiles'];
    if (rawTiles is! List<Object?> || rawTiles.length != 6) {
      throw FormatException('Exercise "$id" must contain exactly six tiles.');
    }
    final tiles = [
      for (var tileIndex = 0; tileIndex < rawTiles.length; tileIndex++)
        _parseTile(rawTiles[tileIndex], id, tileIndex),
    ];

    final exercise = SpatialExercise(
      id: id,
      rules: rules,
      tiles: List.unmodifiable(tiles),
      correctTileIndex: correctTileIndex,
    );
    final matches = exercise.matchingTileIndexes;
    if (matches.length != 1 || matches.single != correctTileIndex) {
      throw FormatException(
        'Exercise "$id" must have exactly one matching tile at the '
        'declared correctTileIndex.',
      );
    }
    return exercise;
  }

  SpatialRules _parseRules(Object? value, String exerciseId) {
    if (value is! Map<String, Object?>) {
      throw FormatException('Exercise "$exerciseId" must define its rules.');
    }

    return SpatialRules(
      colorAbove: _parseEnum(
        value['colorAbove'],
        ArrowColor.values,
        'color',
        exerciseId,
      ),
      directionAbove: _parseEnum(
        value['directionAbove'],
        ArrowDirection.values,
        'directionAbove',
        exerciseId,
      ),
      directionBelow: _parseEnum(
        value['directionBelow'],
        ArrowDirection.values,
        'directionBelow',
        exerciseId,
      ),
    );
  }

  SpatialTile _parseTile(Object? value, String exerciseId, int tileIndex) {
    if (value is! Map<String, Object?>) {
      throw FormatException(
        'Tile $tileIndex in "$exerciseId" must be an object.',
      );
    }

    return SpatialTile(
      above: _parseArrow(value['above'], exerciseId, tileIndex, 'above'),
      below: _parseArrow(value['below'], exerciseId, tileIndex, 'below'),
    );
  }

  SpatialArrow _parseArrow(
    Object? value,
    String exerciseId,
    int tileIndex,
    String position,
  ) {
    if (value is! Map<String, Object?>) {
      throw FormatException(
        'The "$position" arrow in tile $tileIndex of "$exerciseId" '
        'must be an object.',
      );
    }

    return SpatialArrow(
      color: _parseEnum(value['color'], ArrowColor.values, 'color', exerciseId),
      direction: _parseEnum(
        value['direction'],
        ArrowDirection.values,
        'direction',
        exerciseId,
      ),
    );
  }

  T _parseEnum<T extends Enum>(
    Object? value,
    List<T> values,
    String field,
    String exerciseId,
  ) {
    if (value is! String) {
      throw FormatException(
        'Field "$field" in "$exerciseId" must be a string.',
      );
    }
    for (final enumValue in values) {
      if (enumValue.name == value) {
        return enumValue;
      }
    }
    throw FormatException(
      'Unsupported value "$value" for "$field" in "$exerciseId".',
    );
  }
}
