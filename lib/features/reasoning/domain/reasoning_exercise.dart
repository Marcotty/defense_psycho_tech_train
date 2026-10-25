import '../../session/domain/session_exercise.dart';

enum OrderExtreme { maximum, minimum }

class OrderingClue {
  const OrderingClue({
    required this.greaterEntity,
    required this.lesserEntity,
    required this.statement,
  });

  final String greaterEntity;
  final String lesserEntity;
  final String statement;
}

class ReasoningExercise {
  const ReasoningExercise({
    required this.id,
    required this.entities,
    required this.clues,
    required this.question,
    required this.extreme,
  });

  final String id;
  final List<String> entities;
  final List<OrderingClue> clues;
  final String question;
  final OrderExtreme extreme;

  List<String> get orderedEntities {
    final lessThan = {for (final entity in entities) entity: <String>{}};
    for (final clue in clues) {
      lessThan[clue.greaterEntity]!.add(clue.lesserEntity);
    }

    final visitState = <String, int>{};
    bool containsCycle(String entity) {
      final state = visitState[entity] ?? 0;
      if (state == 1) return true;
      if (state == 2) return false;
      visitState[entity] = 1;
      for (final lesser in lessThan[entity]!) {
        if (containsCycle(lesser)) return true;
      }
      visitState[entity] = 2;
      return false;
    }

    if (entities.any(containsCycle)) {
      throw StateError('Ordering clues in "$id" contain a cycle.');
    }

    Set<String> reachableFrom(String entity, Set<String> visited) {
      if (!visited.add(entity)) return {};
      final reachable = <String>{};
      for (final lesser in lessThan[entity]!) {
        reachable.add(lesser);
        reachable.addAll(reachableFrom(lesser, visited));
      }
      return reachable;
    }

    final reachability = {
      for (final entity in entities) entity: reachableFrom(entity, {}),
    };
    for (var first = 0; first < entities.length; first++) {
      for (var second = first + 1; second < entities.length; second++) {
        final a = entities[first];
        final b = entities[second];
        if (!reachability[a]!.contains(b) && !reachability[b]!.contains(a)) {
          throw StateError(
            'Ordering clues in "$id" do not determine a unique order.',
          );
        }
      }
    }

    return List.unmodifiable(
      [...entities]..sort(
        (a, b) => reachability[b]!.length.compareTo(reachability[a]!.length),
      ),
    );
  }

  String get correctEntity => extreme == OrderExtreme.maximum
      ? orderedEntities.first
      : orderedEntities.last;

  SessionExercise toSessionExercise() {
    return SessionExercise(
      id: id,
      memorizationContent: clues.map((clue) => clue.statement).join('\n'),
      prompt: question,
      options: [
        for (var index = 0; index < entities.length; index++)
          SessionAnswerOption(id: '$id-option-$index', label: entities[index]),
      ],
      correctOptionId: '$id-option-${entities.indexOf(correctEntity)}',
      explanation:
          '${orderedEntities.join(' → ')}. '
          '${extreme == OrderExtreme.maximum ? 'La valeur la plus élevée' : 'La valeur la plus faible'} '
          'est $correctEntity.',
    );
  }
}
