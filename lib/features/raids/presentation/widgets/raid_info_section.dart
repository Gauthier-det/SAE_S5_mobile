// lib/features/raids/presentation/widgets/raid_info_section.dart
import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/common_info_card.dart';
import '../../../../shared/utils/date_formatter.dart';
import '../../domain/raid.dart';

class RaidInfoSection extends StatelessWidget {
  final Raid raid;

  const RaidInfoSection({super.key, required this.raid});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonInfoCard(
          icon: Icons.place,
          title: 'Lieu',
          content: raid.address?.fullAddress ?? 'Non spécifié',
        ),
        const SizedBox(height: 12),
        CommonInfoCard(
          icon: Icons.event,
          title: 'Dates de l\'événement',
          content:
              '${DateFormatter.formatDateTime(raid.timeStart)}\n→ ${DateFormatter.formatDateTime(raid.timeEnd)}',
        ),
        const SizedBox(height: 12),
        CommonInfoCard(
          icon: Icons.app_registration,
          title: 'Inscriptions',
          content:
              '${DateFormatter.formatDateTime(raid.registrationStart)}\n→ ${DateFormatter.formatDateTime(raid.registrationEnd)}',
        ),
        const SizedBox(height: 12),
        if (raid.email != null || raid.phoneNumber != null)
          CommonInfoCard(
            icon: Icons.contact_mail,
            title: 'Contact',
            content: [
              if (raid.email != null) raid.email!,
              if (raid.phoneNumber != null) raid.phoneNumber!,
            ].join('\n'),
          ),
        const SizedBox(height: 12),
        if (raid.website != null)
          CommonInfoCard(
            icon: Icons.language,
            title: 'Site web',
            content: raid.website!,
          ),
      ],
    );
  }
}
