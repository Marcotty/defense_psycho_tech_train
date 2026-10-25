import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/word_memory_exercise.dart';

class WordMemoryRepository {
  const WordMemoryRepository({
    AssetBundle? assetBundle,
    this.assetPath = 'assets/exercises/word_memory.json',
  }) : _assetBundle = assetBundle;

  final AssetBundle? _assetBundle;
  final String assetPath;

  Future<List<WordMemoryExercise>> loadExercises() async {
    final source = await (_assetBundle ?? rootBundle).loadString(assetPath);
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw FormatException(
        'Invalid word-memory JSON in "$assetPath": ${error.message}',
      );
    }
    if (decoded is! List<Object?> || decoded.isEmpty) {
      throw FormatException('Expected a non-empty JSON list in "$assetPath".');
    }

    final exercises = <WordMemoryExercise>[];
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

  WordMemoryExercise _parseExercise(Map<String, Object?> value, int index) {
    final id = value['id'];
    final rawCategories = value['categories'];
    final rawWords = value['words'];
    if (id is! String || id.trim().isEmpty) {
      throw FormatException('Exercise $index must have a non-empty id.');
    }
    if (rawCategories is! List<Object?> ||
        rawCategories.length != 3 ||
        rawWords is! List<Object?> ||
        rawWords.length != 3) {
      throw FormatException(
        'Exercise "$id" must have three categories and words.',
      );
    }

    final categories = [
      for (var position = 0; position < rawCategories.length; position++)
        _parseCategory(rawCategories[position], id, position),
    ];
    final words = [
      for (var position = 0; position < rawWords.length; position++)
        _parseWord(rawWords[position], id, position),
    ];
    return WordMemoryExercise(
      id: id,
      categories: List.unmodifiable(categories),
      words: List.unmodifiable(words),
    );
  }

  WordCategory _parseCategory(Object? value, String id, int position) {
    if (value is! String) {
      throw FormatException('Category $position in "$id" must be a string.');
    }
    for (final category in WordCategory.values) {
      if (category.name == value) return category;
    }
    throw FormatException('Unknown category "$value" in "$id".');
  }

  String _parseWord(Object? value, String id, int position) {
    if (value is! String || categoryForWord(value) == null) {
      throw FormatException('Unknown word at position $position in "$id".');
    }
    return value;
  }
}
