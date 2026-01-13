// lib/features/races/presentation/widgets/race_header.dart
import 'package:flutter/material.dart';
import '../../domain/race.dart';

class RaceHeader extends StatelessWidget {
  final Race race;

  const RaceHeader({super.key, required this.race});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: race.type == 'Compétitif'
              ? [const Color(0xFFFF6B00), const Color(0xFFFF8C42)]
              : [const Color(0xFF52B788), const Color(0xFF74C69D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              race.type.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: race.type == 'Compétitif'
                    ? const Color(0xFFFF6B00)
                    : const Color(0xFF52B788),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Course ${race.type}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
