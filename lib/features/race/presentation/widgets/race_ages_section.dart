// lib/features/race/presentation/widgets/race_ages_section.dart
import 'package:flutter/material.dart';
import '../../domain/race.dart';

/// Race age recommendations display section.
///
/// Shows color-coded age chips (min, middle, max) for race participation
/// recommendations. Only displays non-zero age values.
///
/// Example:
/// ```dart
/// RaceAgesSection(race: selectedRace);
/// ```
class RaceAgesSection extends StatelessWidget {
  /// The race entity containing age recommendations.
  final Race race;

  const RaceAgesSection({super.key, required this.race});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Âges recommandés',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Display age chips conditionally (only non-zero values)
        Row(
          children: [
            if (race.ageMin != 0)
              Expanded(
                child: _buildAgeChip(
                  label: 'Min',
                  age: race.ageMin,
                  color: Colors.blue,
                ),
              ),
            if (race.ageMin != 0 && race.ageMiddle != 0)
              const SizedBox(width: 8),
            if (race.ageMiddle != 0)
              Expanded(
                child: _buildAgeChip(
                  label: 'Moyen',
                  age: race.ageMiddle,
                  color: Colors.orange,
                ),
              ),
            if (race.ageMiddle != 0 && race.ageMax != 0)
              const SizedBox(width: 8),
            if (race.ageMax != 0)
              Expanded(
                child: _buildAgeChip(
                  label: 'Max',
                  age: race.ageMax,
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Builds a colored age chip with label and age value.
  Widget _buildAgeChip({
    required String label,
    required int age,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$age ans',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
