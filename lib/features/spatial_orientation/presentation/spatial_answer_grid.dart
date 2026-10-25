import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../session/domain/session_exercise.dart';
import '../domain/spatial_exercise.dart';

class SpatialAnswerGrid extends StatelessWidget {
  const SpatialAnswerGrid({
    required this.options,
    required this.tiles,
    required this.onSelected,
    super.key,
  });

  final List<SessionAnswerOption> options;
  final Map<String, SpatialTile> tiles;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 3 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: columns == 3 ? 1.25 : 1.1,
          ),
          itemBuilder: (context, index) {
            final option = options[index];
            final tile = tiles[option.id];
            if (tile == null) {
              throw StateError('No arrow tile is registered for ${option.id}.');
            }

            return Semantics(
              button: true,
              label: option.label,
              child: OutlinedButton(
                onPressed: () => onSelected(option.id),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ArrowGlyph(arrow: tile.above),
                    const SizedBox(height: 2),
                    _ArrowGlyph(arrow: tile.below),
                    const SizedBox(height: 4),
                    Text(
                      'Case ${index + 1}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ArrowGlyph extends StatelessWidget {
  const _ArrowGlyph({required this.arrow});

  final SpatialArrow arrow;

  @override
  Widget build(BuildContext context) {
    final angle = switch (arrow.direction) {
      ArrowDirection.upRight => math.pi / 4,
      ArrowDirection.upLeft => -math.pi / 4,
      ArrowDirection.downRight => 3 * math.pi / 4,
      ArrowDirection.downLeft => -3 * math.pi / 4,
    };
    final color = switch (arrow.color) {
      ArrowColor.black => Colors.black,
      ArrowColor.yellow => const Color(0xFFFFD600),
    };

    return Transform.rotate(
      angle: angle,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (arrow.color == ArrowColor.black)
            const Icon(
              Icons.arrow_upward_rounded,
              size: 40,
              color: Colors.white,
            ),
          Icon(
            Icons.arrow_upward_rounded,
            size: 34,
            color: color,
            shadows: arrow.color == ArrowColor.yellow
                ? const [Shadow(color: Colors.black87, blurRadius: 1)]
                : null,
          ),
        ],
      ),
    );
  }
}
