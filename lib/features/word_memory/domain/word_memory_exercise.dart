import '../../session/domain/session_exercise.dart';

enum WordCategory {
  tool('Outil'),
  fish('Poisson'),
  tree('Arbre'),
  metal('Métal'),
  liquid('Liquide'),
  country('Pays'),
  clothing('Vêtements'),
  vehicle('Véhicule'),
  bird('Oiseau'),
  insect('Insecte'),
  building('Bâtiment'),
  vegetable('Légume');

  const WordCategory(this.label);

  final String label;
}

class WordMemoryExercise {
  const WordMemoryExercise({
    required this.id,
    required this.categories,
    required this.words,
  });

  final String id;
  final List<WordCategory> categories;
  final List<String> words;

  int get matchingCount {
    var count = 0;
    for (var index = 0; index < categories.length; index++) {
      if (categoryForWord(words[index]) == categories[index]) {
        count++;
      }
    }
    return count;
  }

  SessionExercise toSessionExercise() {
    return SessionExercise(
      id: id,
      memorizationContent: categories
          .map((category) => category.label)
          .join(' · '),
      prompt:
          'Combien de mots correspondent à la catégorie de leur position ?'
          '\n${words.join(' · ')}',
      options: const [
        SessionAnswerOption(id: '0', label: '0'),
        SessionAnswerOption(id: '1', label: '1'),
        SessionAnswerOption(id: '2', label: '2'),
        SessionAnswerOption(id: '3', label: '3'),
      ],
      correctOptionId: '$matchingCount',
      explanation: _buildExplanation(),
    );
  }

  String _buildExplanation() {
    final matches = <String>[];
    for (var index = 0; index < categories.length; index++) {
      final category = categoryForWord(words[index]);
      matches.add(
        '${words[index]} : ${category?.label ?? 'catégorie inconnue'} '
        '(${category == categories[index] ? 'correspond' : 'ne correspond pas'})',
      );
    }
    return '${matches.join('\n')}\n'
        'Nombre de correspondances : $matchingCount.';
  }
}

WordCategory? categoryForWord(String word) => _wordCategories[word];

const _wordCategories = <String, WordCategory>{
  'Tenailles': WordCategory.tool,
  'Cabillaud': WordCategory.fish,
  'Sardine': WordCategory.fish,
  'Bronze': WordCategory.metal,
  'Sapin': WordCategory.tree,
  'Bouleau': WordCategory.tree,
  'Diesel': WordCategory.liquid,
  'Jus': WordCategory.liquid,
  'Inde': WordCategory.country,
  'Haricot': WordCategory.vegetable,
  'Veste': WordCategory.clothing,
  'Gants': WordCategory.clothing,
  'Mouette': WordCategory.bird,
  'Vélo': WordCategory.vehicle,
  'Carrosse': WordCategory.vehicle,
  'Magasin': WordCategory.building,
  'Scarabée': WordCategory.insect,
  'Moustique': WordCategory.insect,
  'Hareng': WordCategory.fish,
  'Crème': WordCategory.liquid,
  'Eau': WordCategory.liquid,
  'Clef': WordCategory.tool,
  'Scie': WordCategory.tool,
  'Chêne': WordCategory.tree,
};
