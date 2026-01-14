// lib/features/raids/presentation/widgets/raid_info_section.dart
import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/common_info_card.dart';
import '../../../../shared/utils/date_formatter.dart';
import '../../../raid/domain/raid.dart';

class RaidInfoSection extends StatelessWidget {
  final Raid raid;

  const RaidInfoSection({super.key, required this.raid});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Dates (plus importante)
        _buildSectionTitle(context, 'Dates importantes', Icons.event),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildCompactCard(
                context,
                icon: Icons.calendar_today,
                label: 'Événement',
                value: '${DateFormatter.formatDate(raid.timeStart)} - ${DateFormatter.formatDate(raid.timeEnd)}',
                color: const Color(0xFFFF6B00),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCompactCard(
                context,
                icon: Icons.app_registration,
                label: 'Inscriptions',
                value: '${DateFormatter.formatDate(raid.registrationStart)} - ${DateFormatter.formatDate(raid.registrationEnd)}',
                color: const Color(0xFF52B788),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Section Lieu
        _buildSectionTitle(context, 'Localisation', Icons.place),
        const SizedBox(height: 12),
        CommonInfoCard(
          icon: Icons.location_on,
          title: 'Adresse',
          content: raid.address?.fullAddress ?? 'Non spécifié',
          color: Colors.red.shade400,
        ),

        const SizedBox(height: 24),

        // Section Contact
        if (raid.email != null || raid.phoneNumber != null || raid.website != null) ...[
          _buildSectionTitle(context, 'Contact', Icons.contact_mail),
          const SizedBox(height: 12),
          
          if (raid.email != null)
            _buildContactRow(context, Icons.email, 'Email', raid.email!),
          
          if (raid.phoneNumber != null)
            _buildContactRow(context, Icons.phone, 'Téléphone', raid.phoneNumber!),
          
          if (raid.website != null)
            _buildContactRow(context, Icons.language, 'Site web', raid.website!),
          
          const SizedBox(height: 24),
        ],

        // Section Responsable (en dernier)
        if (raid.manager != null) ...[
          _buildSectionTitle(context, 'Organisation', Icons.people),
          const SizedBox(height: 12),
          CommonInfoCard(
            icon: Icons.person_outline,
            title: 'Responsable du raid',
            content: raid.manager!.fullName,
            color: const Color(0xFF1B3022),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }

  Widget _buildCompactCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
