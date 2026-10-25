import 'dart:math';

import 'package:defense_psycho_tech_train/features/reasoning/domain/reasoning_exercise.dart';
import 'package:defense_psycho_tech_train/features/reasoning/domain/reasoning_exercise_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each exercise has three unique entities and exactly two clues', () {
    for (var seed = 0; seed < 200; seed++) {
      final exercises = ReasoningExerciseGenerator(
        random: Random(seed),
      ).generate(20);
      for (final exercise in exercises) {
        expect(exercise.entities.toSet(), hasLength(3));
        expect(exercise.clues, hasLength(2));
        for (final clue in exercise.clues) {
          expect(exercise.entities, contains(clue.greaterEntity));
          expect(exercise.entities, contains(clue.lesserEntity));
          expect(clue.greaterEntity, isNot(clue.lesserEntity));
          expect(clue.statement, contains(clue.greaterEntity));
          expect(clue.statement, contains(clue.lesserEntity));
        }
      }
    }
  });

  test('clues form a chain through a shared middle entity and need both', () {
    final exercises = ReasoningExerciseGenerator(
      random: Random(1),
    ).generate(200);
    for (final exercise in exercises) {
      final [a, b] = exercise.clues;
      final shared = {
        a.greaterEntity,
        a.lesserEntity,
      }.intersection({b.greaterEntity, b.lesserEntity});
      expect(shared, hasLength(1));
      expect(exercise.orderedEntities, hasLength(3));
      final single = ReasoningExercise(
        id: 'x',
        entities: exercise.entities,
        clues: [a],
        question: exercise.question,
        extreme: exercise.extreme,
      );
      expect(() => single.orderedEntities, throwsStateError);
    }
  });

  test('the correct entity matches the question extreme', () {
    final exercises = ReasoningExerciseGenerator(
      random: Random(2),
    ).generate(200);
    for (final exercise in exercises) {
      final ordered = exercise.orderedEntities;
      expect(
        exercise.correctEntity,
        exercise.extreme == OrderExtreme.maximum ? ordered.first : ordered.last,
      );
      final domain = reasoningDomains.singleWhere(
        (d) =>
            d.highQuestion == exercise.question ||
            d.lowQuestion == exercise.question,
      );
      expect(
        exercise.extreme == OrderExtreme.maximum,
        domain.highQuestion == exercise.question,
      );
      expect(domain.entities, containsAll(exercise.entities));
    }
  });

  test('statements use the domain vocabulary and French elision', () {
    final vowel = RegExp('^[AEIOUYÉÈÊÂÎÔÛHaeiouyéèêâîôûh]');
    final exercises = ReasoningExerciseGenerator(
      random: Random(3),
    ).generate(300);
    for (final exercise in exercises) {
      final domain = reasoningDomains.singleWhere(
        (d) => d.entities.contains(exercise.entities.first),
      );
      for (final clue in exercise.clues) {
        final isHighForm = clue.statement.startsWith('${clue.greaterEntity} ');
        final subject = isHighForm ? clue.greaterEntity : clue.lesserEntity;
        final object = isHighForm ? clue.lesserEntity : clue.greaterEntity;
        final phrase = isHighForm ? domain.highPhrase : domain.lowPhrase;
        final connector = domain.connector;
        final link = vowel.hasMatch(object)
            ? '${connector.substring(0, connector.length - 1)}’$object'
            : '$connector $object';
        expect(clue.statement, '$subject $phrase $link');
      }
    }
  });

  test('both directions of phrasing and both extremes occur', () {
    final exercises = ReasoningExerciseGenerator(
      random: Random(4),
    ).generate(200);
    expect(
      exercises.map((e) => e.extreme).toSet(),
      OrderExtreme.values.toSet(),
    );
    final clues = exercises.expand((e) => e.clues);
    expect(
      clues.any((c) => c.statement.startsWith('${c.greaterEntity} ')),
      isTrue,
    );
    expect(
      clues.any((c) => c.statement.startsWith('${c.lesserEntity} ')),
      isTrue,
    );
    expect(
      exercises.map((e) => e.correctEntity).toSet().length,
      greaterThan(5),
    );
  });

  test('session exercise has one option per entity and the right answer', () {
    final exercises = ReasoningExerciseGenerator(
      random: Random(5),
    ).generate(100);
    for (final exercise in exercises) {
      final session = exercise.toSessionExercise();
      final correct = session.options.singleWhere(
        (o) => o.id == session.correctOptionId,
      );
      expect(correct.label, exercise.correctEntity);
      expect(session.options, hasLength(3));
      expect(session.id, startsWith('timed-'));
    }
  });
}
