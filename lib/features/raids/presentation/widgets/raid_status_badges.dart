// lib/features/raids/presentation/widgets/raid_status_badges.dart
import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/common_status_chip.dart';
import '../../domain/raid.dart';

class RaidStatusBadges extends StatelessWidget {
  final Raid raid;

  const RaidStatusBadges({super.key, required this.raid});

  @override
  Widget build(BuildContext context) {
    final raidStatus = _getRaidStatus(raid);
    final registrationStatus = _getRegistrationStatus(raid);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        CommonStatusChip(
          label: raidStatus.label,
          color: raidStatus.color,
          icon: Icons.event,
        ),
        CommonStatusChip(
          label: registrationStatus.label,
          color: registrationStatus.color,
          icon: Icons.app_registration,
        ),
      ],
    );
  }

  _StatusInfo _getRaidStatus(Raid raid) {
    final now = DateTime.now();
    
    if (now.isBefore(raid.timeStart)) {
      return _StatusInfo(label: 'À VENIR', color: Colors.blue);
    } else if (now.isAfter(raid.timeEnd)) {
      return _StatusInfo(label: 'TERMINÉ', color: Colors.grey);
    } else {
      return _StatusInfo(label: 'EN COURS', color: Colors.green);
    }
  }

  _StatusInfo _getRegistrationStatus(Raid raid) {
    final now = DateTime.now();
    
    if (now.isBefore(raid.registrationStart)) {
      return _StatusInfo(label: 'À VENIR', color: Colors.orange);
    } else if (now.isAfter(raid.registrationEnd)) {
      return _StatusInfo(label: 'CLOSES', color: Colors.red);
    } else {
      return _StatusInfo(label: 'OUVERTES', color: Colors.green);
    }
  }
}

class _StatusInfo {
  final String label;
  final Color color;
  _StatusInfo({required this.label, required this.color});
}
