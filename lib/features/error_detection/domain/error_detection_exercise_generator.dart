import 'dart:math';

import 'error_detection_exercise.dart';

/// Génère des exercices de détection d'erreurs inédits.
///
/// Règles : la copie a exactement la même longueur que l'original, de 0 à 4
/// caractères diffèrent à la même position, seuls les lettres et chiffres sont
/// modifiés (une lettre reste une lettre de même casse, un chiffre reste un
/// chiffre) ; les séparateurs (espace, « @ », « . », « : », « / ») restent.
class ErrorDetectionExerciseGenerator {
  ErrorDetectionExerciseGenerator({Random? random})
    : _random = random ?? Random();

  static const maxDifferences = 4;

  final Random _random;

  List<ErrorDetectionExercise> generate(
    int count, {
    String idPrefix = 'timed-errors',
  }) {
    final targets = [
      for (var index = 0; index < count; index++) index % (maxDifferences + 1),
    ]..shuffle(_random);
    return [
      for (var index = 0; index < count; index++)
        generateOne('$idPrefix-${index + 1}', targets[index]),
    ];
  }

  ErrorDetectionExercise generateOne(String id, int differences) {
    if (differences < 0 || differences > maxDifferences) {
      throw RangeError.range(differences, 0, maxDifferences, 'differences');
    }
    final original = _randomOriginal();
    final mutable = [
      for (var index = 0; index < original.length; index++)
        if (_isLetter(original[index]) || _isDigit(original[index])) index,
    ]..shuffle(_random);
    final chars = original.split('');
    for (final index in mutable.take(differences)) {
      chars[index] = _differentChar(chars[index]);
    }
    return ErrorDetectionExercise(
      id: id,
      original: original,
      copy: chars.join(),
    );
  }

  String _randomOriginal() {
    final tld = _pick(const ['com', 'net', 'org', 'fr']);
    return switch (_random.nextInt(5)) {
      0 => '${_letters(3)}${_digits(3)}@${_letters(3)}.com',
      1 => '${_letters(_between(5, 8))}@${_letters(_between(4, 6))}.$tld',
      2 => 'http://www.${_letters(6)}.$tld',
      3 => '${_letters(2).toUpperCase()} ${_digits(5)}',
      _ =>
        '${_letters(1).toUpperCase()} ${_digits(3)} ${_letters(3).toUpperCase()}',
    };
  }

  String _letters(int length) => String.fromCharCodes([
    for (var i = 0; i < length; i++) 97 + _random.nextInt(26),
  ]);

  String _digits(int length) => String.fromCharCodes([
    for (var i = 0; i < length; i++) 48 + _random.nextInt(10),
  ]);

  String _differentChar(String char) {
    final base = _isDigit(char) ? 48 : (char == char.toUpperCase() ? 65 : 97);
    final size = _isDigit(char) ? 10 : 26;
    while (true) {
      final candidate = String.fromCharCode(base + _random.nextInt(size));
      if (candidate != char) return candidate;
    }
  }

  bool _isDigit(String char) =>
      char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;

  bool _isLetter(String char) {
    final code = char.toLowerCase().codeUnitAt(0);
    return code >= 97 && code <= 122;
  }

  int _between(int min, int max) => min + _random.nextInt(max - min + 1);

  T _pick<T>(List<T> values) => values[_random.nextInt(values.length)];
}
