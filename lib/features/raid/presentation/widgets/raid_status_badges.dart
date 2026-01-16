// lib/features/raids/presentation/widgets/raid_status_badges.dart
import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/common_status_chip.dart';
import '../../../raid/domain/raid.dart';

/// Raid status badges widget.
///
/// Displays two status chips: event status (upcoming/ongoing/finished) and
/// registration status (upcoming/open/closed). Calculates status dynamically
/// based on current date vs raid dates.
///
/// **Event Status Colors:**
/// - À VENIR (upcoming): Blue
/// - EN COURS (ongoing): Green
/// - TERMINÉ (finished): Grey
///
/// **Registration Status Colors:**
/// - À VENIR (upcoming): Orange
/// - OUVERTES (open): Green
/// - CLOSES (closed): Red
///
/// Example:
/// ```dart
/// RaidStatusBadges(raid: raid);
/// ```
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

  /// Determines event status based on current date.
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

  /// Determines registration status based on current date.
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

/// Helper class for status label and color pairing.
class _StatusInfo {
  final String label;
  final Color color;
  _StatusInfo({required this.label, required this.color});
}
