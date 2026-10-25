import 'dart:math';

import 'word_memory_exercise.dart';

/// Génère des exercices de mémoire des mots inédits.
///
/// Règles : trois catégories (répétitions autorisées) et trois mots distincts
/// issus du dictionnaire ; le nombre de mots correspondant à la catégorie de
/// leur position est compris entre 0 et 3 et réparti de façon équilibrée.
class WordMemoryExerciseGenerator {
  WordMemoryExerciseGenerator({Random? random}) : _random = random ?? Random();

  static const wordCount = 3;

  final Random _random;

  List<WordMemoryExercise> generate(
    int count, {
    String idPrefix = 'timed-words',
  }) {
    final targets = [
      for (var index = 0; index < count; index++) index % (wordCount + 1),
    ]..shuffle(_random);
    return [
      for (var index = 0; index < count; index++)
        generateOne('$idPrefix-${index + 1}', targets[index]),
    ];
  }

  WordMemoryExercise generateOne(String id, int matchingCount) {
    if (matchingCount < 0 || matchingCount > wordCount) {
      throw RangeError.range(matchingCount, 0, wordCount, 'matchingCount');
    }

    final categories = [
      for (var i = 0; i < wordCount; i++)
        WordCategory.values[_random.nextInt(WordCategory.values.length)],
    ];
    final matchingPositions = (List.generate(
      wordCount,
      (i) => i,
    )..shuffle(_random)).take(matchingCount).toSet();

    final words = <String>[];
    for (var position = 0; position < wordCount; position++) {
      final candidates = [
        for (final category in WordCategory.values)
          if ((category == categories[position]) ==
              matchingPositions.contains(position))
            ...wordsForCategory(category),
      ]..removeWhere(words.contains);
      words.add(candidates[_random.nextInt(candidates.length)]);
    }

    return WordMemoryExercise(
      id: id,
      categories: List.unmodifiable(categories),
      words: List.unmodifiable(words),
    );
  }
}
