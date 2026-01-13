// lib/features/races/presentation/widgets/race_ages_section.dart
import 'package:flutter/material.dart';
import '../../domain/race.dart';

class RaceAgesSection extends StatelessWidget {
  final Race race;

  const RaceAgesSection({super.key, required this.race});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildAgeChip(label: 'Min', age: race.ageMin, color: Colors.blue),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildAgeChip(label: 'Moyen', age: race.ageMiddle, color: Colors.orange),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildAgeChip(label: 'Max', age: race.ageMax, color: Colors.red),
        ),
      ],
    );
  }

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
