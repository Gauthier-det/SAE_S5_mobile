// lib/features/races/presentation/widgets/race_quick_stats.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/race.dart';
import '../../domain/race_repository.dart';

class RaceQuickStats extends StatelessWidget {
  final Race race;

  const RaceQuickStats({super.key, required this.race});

  @override
  Widget build(BuildContext context) {
    final repository = Provider.of<RacesRepository>(context, listen: false);

    return FutureBuilder<int>(
      future: repository.getRegisteredTeamsCount(race.id),
      builder: (context, snapshot) {
        final registeredTeams = snapshot.data ?? 0;
        final spotsLeft = race.maxTeams - registeredTeams;
        final fillPercentage = (registeredTeams / race.maxTeams * 100).round();

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1B3022).withOpacity(0.9),
                const Color(0xFF52B788).withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.groups,
                    label: 'Équipes',
                    value: '$registeredTeams/${race.maxTeams}',
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildStatItem(
                    icon: Icons.event_available,
                    label: 'Places restantes',
                    value: '$spotsLeft',
                    valueColor: spotsLeft < 10 ? Colors.orange : Colors.white,
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildStatItem(
                    icon: Icons.percent,
                    label: 'Remplissage',
                    value: '$fillPercentage%',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: registeredTeams / race.maxTeams,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    spotsLeft < 10 ? Colors.orange : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
