# Entraînement BTCA

## Objectif

Entraînement BTCA est une application Flutter de préparation aux cinq familles
d'exercices proposées par l'application dans le contexte « Préparation SAO ·
Belgique ». Elle permet de travailler les exercices du livret à son rythme ou
de s'exercer sur des séries inédites avec une limite de temps.

L'application est un outil d'entraînement : elle ne délivre pas de résultat
officiel et ne prétend pas remplacer une évaluation ou une procédure de
sélection.

## Fonctionnalités

- Entraînement aux cinq types d'exercices, avec correction et explication après
  chaque réponse.
- Mode Test, qui utilise des exercices générés plutôt que ceux du livret.
- Paramétrage indépendant de la limite de temps de chaque test.
- Choix du thème clair, sombre ou hérité de l'appareil.
- Historique local des sessions, avec exactitude, durées et bilan des tests
  chronométrés.
- Interface en français, conçue avec les composants Material 3 et adaptée aux
  écrans de tailles différentes.

### Les cinq types d'exercices

| Test | Compétence sollicitée | Exercice |
| --- | --- | --- |
| Aisance numérique | Calcul mental et comparaison | Mémoriser le résultat d'une opération, puis le comparer au résultat d'une seconde opération : plus grand, plus petit ou égal. |
| Orientation spatiale | Mémoire de consignes et repérage visuel | Mémoriser des consignes de couleur et de direction, puis choisir parmi six cases la seule qui les respecte. |
| Mémoire des mots | Mémoire associative | Mémoriser trois catégories, puis compter les mots qui correspondent à la catégorie de leur position. |
| Raisonnement | Déduction d'un ordre | Relier deux comparaisons entre trois entités et choisir l'entité la plus élevée ou la plus faible selon la question. |
| Détection d'erreurs | Mémoire visuelle et comparaison | Mémoriser une chaîne, puis compter les caractères différents dans sa copie. |

### Mode Entraînement

Le mode Entraînement charge l'ensemble des exercices du livret depuis les
fichiers JSON du dossier `assets/exercises/`. L'utilisateur contrôle le passage
de l'écran de mémorisation à la question. Après chaque réponse, l'application
indique si elle est correcte, affiche une explication, puis attend une action
pour continuer.

Le contenu actuel du livret comprend trois exercices numériques et huit
exercices pour chacun des quatre autres types. L'orientation spatiale affiche
les choix sous forme de cases avec des flèches graphiques ; leur description
textuelle reste disponible aux technologies d'assistance.

### Mode Test

Une session porte sur un seul type de test et contient 40 nouveaux exercices
par défaut. Le mode Test ne lit pas les exercices du livret : chaque type
dispose de son propre générateur, sélectionné par `TimedExerciseGenerator`.
L'instance de `Random` et le nombre d'exercices peuvent être injectés, notamment
pour rendre les tests reproductibles.

La limite doit être définie dans les paramètres avant de lancer le test. Aucun
temps par défaut n'est imposé. Le chronomètre démarre avec la session et continue
pendant la mémorisation et les réponses. Dans le parcours actuel, le bouton
« Afficher la question » permet de passer de la mémorisation à la question.
Après une réponse, l'écran de mémorisation de l'exercice suivant s'affiche sans
correction intermédiaire ; l'utilisateur appuie à nouveau sur le bouton pour
révéler sa question. Le test se termine quand tous les exercices ont reçu une
réponse ou quand la limite est atteinte.

Le bilan distingue :

- l'exactitude : réponses justes divisées par le nombre total d'exercices de la
  session ; une question laissée sans réponse à l'expiration du temps n'est donc
  pas comptée juste ;
- le temps moyen de réponse et le temps total passé à répondre, calculés sur les
  réponses enregistrées ;
- la réussite, qui exige au moins 95 % d'exactitude et une fin dans la limite de
  temps.

Le temps écoulé de la session inclut la mémorisation. Le temps de réponse
additionné au bilan, lui, mesure les intervalles consacrés aux questions.

### Paramètres et historique

Les limites se règlent en minutes pour chaque type de test. Les nombres
décimaux et la virgule comme séparateur décimal sont acceptés ; la durée est
convertie en secondes, avec un minimum d'une seconde. Un champ vide retire la
limite de ce test : celui-ci ne peut pas démarrer tant qu'une durée n'est pas
configurée.

L'historique conserve les résultats des sessions d'entraînement et de test :
date de début, type de test, mode, durée écoulée, nombre de bonnes réponses,
nombre total de questions et, pour un test, limite configurée. La page affiche
le nombre de sessions, la moyenne arithmétique de leur exactitude et le ratio
de tests chronométrés réussis.

## Règles des générateurs chronométrés

Les générateurs se trouvent dans le dossier `domain/` de la feature
correspondante. Ils construisent des modèles d'exercice valides puis les
convertissent en `SessionExercise`, le format commun utilisé par le moteur de
session. Les règles suivantes décrivent les contraintes effectivement
appliquées par le code.

### Aisance numérique

`NumericalExerciseGenerator` compose des additions, soustractions,
multiplications et divisions :

- les opérandes sont des entiers positifs ;
- une addition utilise deux termes compris entre 1 et 50 ;
- une soustraction utilise un premier terme compris entre 3 et 99 et un
  second terme strictement inférieur, pour obtenir un résultat positif ;
- les deux facteurs d'une multiplication sont compris entre 2 et 12 ;
- une division utilise un diviseur compris entre 2 et 12 et est toujours exacte,
  avec un quotient compris entre 2 et 12 ;
- le résultat d'une opération est compris entre 2 et 144 ;
- les deux expressions d'un même exercice sont distinctes.

Pour 40 questions, la série contient 8 égalités, 16 cas où la première
opération est supérieure et 16 cas où elle est inférieure. L'ordre des
questions est mélangé. La bonne option est calculée à partir des deux résultats
et l'explication les présente.

### Orientation spatiale

`SpatialExerciseGenerator` crée six cases composées chacune de deux flèches :
une noire et une jaune. Chaque flèche pointe dans l'une des quatre diagonales
(haut droite, haut gauche, bas droite ou bas gauche).

Les consignes précisent la couleur de la flèche du dessus et les directions des
flèches du dessus et du dessous ; la couleur de la flèche du dessous est
l'autre couleur. Une seule case satisfait simultanément toutes ces règles.
Les cases sont distinctes et leur ordre est mélangé afin de déplacer la bonne
réponse. Le mode chronométré et le mode Entraînement utilisent le même composant
de grille visuelle.

### Mémoire des mots

`WordMemoryExerciseGenerator` crée une séquence de trois catégories et trois
mots distincts. Les catégories peuvent se répéter. Chaque mot est pris dans le
dictionnaire de la feature, qui associe les mots à l'une de ces catégories :
outil, poisson, arbre, métal, liquide, pays, vêtement, véhicule, oiseau,
insecte, bâtiment ou légume.

Chaque exercice cible exactement 0, 1, 2 ou 3 correspondances entre la catégorie
à une position et le mot à la même position. Sur 40 questions, les quatre
résultats apparaissent chacun dix fois ; leur ordre est mélangé. Des mots
additionnels ont été ajoutés au dictionnaire pour disposer d'au moins trois
mots par catégorie et pouvoir construire des séquences distinctes.

### Raisonnement

`ReasoningExerciseGenerator` choisit un domaine, trois entités distinctes de ce
domaine et un ordre entre elles. Deux indices forment une chaîne complète :
une entité intermédiaire figure dans les deux indices, et les deux sont
nécessaires pour établir l'ordre unique.

Les domaines disponibles sont :

- vitesse : plus rapide / plus lent ;
- hauteur : plus haut / plus bas ;
- distance : plus loin / plus près ;
- taille : plus grand / plus petit ;
- poids : plus lourd / plus léger ;
- position horizontale : à droite / à gauche.

Chaque indice peut être formulé dans le sens direct ou inverse, par exemple
« A est plus rapide que B » ou « B est plus lent que A ». L'ordre des indices
et des choix est mélangé. La question demande aléatoirement l'extrême supérieur
ou inférieur.

### Détection d'erreurs

`ErrorDetectionExerciseGenerator` produit des chaînes originales selon cinq
formats inspirés du livret : identifiant de type courriel, adresse de type
courriel, URL, code de deux lettres suivi de cinq chiffres, ou code d'une lettre,
trois chiffres et trois lettres.

La copie a la même longueur que l'original et contient exactement le nombre de
différences demandé, entre zéro et quatre. Seules les lettres et les chiffres
peuvent changer ; les lettres conservent leur casse, les chiffres restent des
chiffres, et la ponctuation ainsi que les séparateurs restent en place. Une
série de 40 exercices répartit équitablement les cinq nombres de différences.

## Architecture

### Organisation générale

Le projet est une application Flutter en Dart. `lib/main.dart` démarre
`BtcaApp`, qui configure MaterialApp, le thème et les routes globales. Les
écrans sont organisés par fonctionnalité dans `lib/features/` plutôt que
regroupés par type technique à l'échelle de toute l'application.

Chaque feature suit, selon ses besoins, trois responsabilités :

- `domain/` : modèles, règles de calcul et générateurs d'exercices ;
- `data/` : chargement du livret ou persistance des données ;
- `presentation/` : écrans Flutter et rendu des interactions.

Les features transversales sont :

- `home` : accueil et accès aux modes ;
- `test_selection` : catalogue commun des cinq tests, sélection et présentation
  des consignes ;
- `session` : modèle commun d'exercice, machine à états, exécution d'une session
  et sélection du générateur chronométré ;
- `history` : modèle et affichage des résultats enregistrés ;
- `settings` : réglages de thème et limites de temps.

### Parcours et moteur de session

Les écrans de sélection et de présentation utilisent `CognitiveTestType` pour
choisir la feature et `TrainingMode` pour choisir le parcours. Les modèles
propres à chaque exercice exposent `toSessionExercise()`. Cette conversion
fournit au moteur commun l'identifiant, l'écran de mémorisation, la question,
les options, l'identifiant de la réponse correcte et l'explication.

`SessionController` valide que la session n'est pas vide, que les identifiants
d'exercices et d'options sont uniques et que chaque exercice référence une
option correcte. Il gère les états `memorization`, `answering`, `feedback` et
`completed`, enregistre les réponses et calcule l'exactitude.

Le parcours Entraînement suit les états
`memorization → answering → feedback → memorization` jusqu'au bilan. Le parcours
chronométré saute l'état de correction (`memorization → answering →
memorization`) et peut passer à `completed` après la dernière réponse ou à
l'expiration du chronomètre.

`SessionRunnerPage` orchestre l'interface, les chronomètres, l'avancement et le
bilan. En Entraînement, une réponse conduit à l'écran de correction avant
l'exercice suivant. En mode Test, elle fait avancer directement la session.
Le rendu des réponses est personnalisable : le composant spatial commun
remplace ainsi les boutons textuels standard par des cases visuelles.

### Livret et génération

Le livret est constitué de cinq fichiers JSON dans `assets/exercises/`. Un
dépôt par feature lit son fichier via Flutter `AssetBundle`, décode les objets,
valide leurs champs et leurs règles métier, puis renvoie des listes
non modifiables. Les données mal formées produisent une erreur explicite au lieu
d'être utilisées comme exercice valide.

Le mode Test suit un chemin distinct : `TimedExerciseGenerator` distribue la
demande au générateur de la feature choisie. Les générateurs utilisent Dart
`Random` et sont indépendants du rendu Flutter ; leur source de données est
définie dans le code (domaines, catégories, formats et contraintes), et non
dans les exercices JSON du livret. Les exercices générés sont convertis dans le
modèle de session commun avant d'être présentés.

### Données locales et absence de serveur

L'application n'utilise ni compte utilisateur, ni API, ni serveur distant. Les
paramètres et l'historique sont stockés localement avec
`shared_preferences` :

- le thème est enregistré sous forme de préférence ;
- les limites sont enregistrées en secondes, séparément pour chacun des cinq
  types de tests ;
- l'historique est une liste de sessions sérialisées en JSON, affichée de la
  plus récente à la plus ancienne et limitée aux 500 dernières entrées.

Les données dépendent donc de l'installation locale et ne sont pas synchronisées
entre appareils.

## Design de l'interface

L'application est francophone et utilise Material 3. Le thème dérive d'une
graine bleu marine (`#18324B`) avec une couleur secondaire ambre (`#F2B84B`).
Les modes clair et sombre sont créés à partir de la même palette, et le réglage
par défaut suit le thème de l'appareil.

L'accueil distingue clairement l'entraînement, le test chronométré et
l'historique. Les parcours de sélection et de consignes séparent le choix du
test de son lancement. Les contenus longs sont défilables et les principales
pages limitent la largeur de leur contenu pour rester lisibles sur grand écran.
La grille d'orientation décrit également chaque case dans sa sémantique
d'accessibilité.

## Contenu du livret

| Fichier | Structure et vérifications principales |
| --- | --- |
| `assets/exercises/numerical_fluency.json` | Identifiant et deux opérations décrites par leurs opérandes et un opérateur reconnu ; les divisions doivent être exactes. |
| `assets/exercises/spatial_orientation.json` | Consignes, six cases, indice de la réponse ; l'indice doit désigner l'unique case correspondant aux règles. |
| `assets/exercises/word_memory.json` | Trois catégories et trois mots connus par exercice. |
| `assets/exercises/reasoning.json` | Trois entités uniques, deux indices valides, question et extrême ; les indices doivent déterminer un ordre unique. |
| `assets/exercises/error_detection.json` | Chaîne originale et copie de même longueur, avec au plus quatre différences. |

Ces fichiers alimentent l'entraînement. Modifier un exercice JSON du livret ne
modifie pas les séries chronométrées. Le dictionnaire des mots est partagé par
la validation des exercices du livret et par le générateur de mémoire des mots ;
les autres générateurs gardent leurs domaines et contraintes dans leurs propres
fichiers de domaine.

## Structure du dépôt

```text
assets/
  exercises/                 Exercices statiques du livret (JSON)
lib/
  app/                        Composition de l'application, thèmes et modèles communs
  features/
    error_detection/          Détection d'erreurs
    history/                  Historique des sessions
    home/                     Accueil
    numerical_fluency/        Aisance numérique
    reasoning/                Raisonnement
    session/                  Moteur de session et mode chronométré
    settings/                 Paramètres locaux
    spatial_orientation/      Orientation spatiale et grille graphique
    test_selection/           Catalogue, sélection et consignes
    word_memory/              Mémoire des mots
test/                         Tests unitaires, widget et parcours
```

## Développement

### Prérequis

- Flutter installé et disponible dans le `PATH`.
- Dart SDK compatible avec la contrainte `^3.8.1` du fichier `pubspec.yaml`
  (Flutter fournit le SDK Dart).

### Installer et lancer

À la racine du dépôt :

```sh
flutter pub get
flutter run
```

Pour choisir un appareil ou une cible explicitement, consulter les appareils
disponibles avec `flutter devices`, puis lancer par exemple
`flutter run -d <device-id>`. Le dépôt contient les plateformes Flutter Android,
iOS, Linux, macOS, Web et Windows ; la disponibilité effective dépend de
l'environnement Flutter et de l'appareil utilisé.

### Vérifications

```sh
flutter analyze
flutter test
```

Les tests couvrent les règles des modèles, la validation des dépôts JSON, les
réglages et l'historique, les parcours des exercices du livret, la machine à
états des sessions et l'interface du mode chronométré. Des tests d'intégration
du parcours chronométré exercent les cinq types avec des réponses correctes et
incorrectes ; les tests des générateurs contrôlent leurs contraintes avec des
graines aléatoires fixes ou multiples.
