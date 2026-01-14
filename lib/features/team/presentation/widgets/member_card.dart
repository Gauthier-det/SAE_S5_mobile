// lib/features/teams/presentation/widgets/member_card.dart
import 'package:flutter/material.dart';
import 'member_info_row.dart';

class MemberCard extends StatelessWidget {
  final Map<String, dynamic> member;
  final bool canRemove;
  final bool isRaceManager;
  final Function(int userId, String memberName) onRemove;
  final Function(int userId, String currentPPS, String memberName) onEditPPS;
  final Function(int userId, int? currentChip, String memberName) onEditChipNumber;

  const MemberCard({
    super.key,
    required this.member,
    required this.canRemove,
    required this.isRaceManager,
    required this.onRemove,
    required this.onEditPPS,
    required this.onEditChipNumber,
  });

  @override
  Widget build(BuildContext context) {
    final userId = member['USE_ID'] as int;
    final fullName = '${member['USE_NAME']} ${member['USE_LAST_NAME']}';
    final email = member['USE_MAIL'] as String;
    final licenceNumber = member['USE_LICENCE_NUMBER'] as int?;
    final ppsForm = member['USR_PPS_FORM'] as String?;
    final chipNumber = member['USR_CHIP_NUMBER'] as int?;
    
    final hasLicence = licenceNumber != null;
    final showPPS = !hasLicence;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(fullName, email, userId, context),
            const SizedBox(height: 16),
            _buildInfoSection(
              licenceNumber,
              ppsForm,
              chipNumber,
              hasLicence,
              showPPS,
              userId,
              fullName,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String fullName, String email, int userId, BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFF52B788),
          radius: 24,
          child: Text(
            (member['USE_NAME'] as String)[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                email,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        if (canRemove)
          IconButton(
            icon: const Icon(Icons.person_remove, color: Colors.red),
            onPressed: () => onRemove(userId, fullName),
            tooltip: 'Retirer du groupe',
          ),
      ],
    );
  }

  Widget _buildInfoSection(
    int? licenceNumber,
    String? ppsForm,
    int? chipNumber,
    bool hasLicence,
    bool showPPS,
    int userId,
    String fullName,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          MemberInfoRow(
            icon: Icons.credit_card,
            label: 'N° Licence',
            value: licenceNumber?.toString() ?? 'Non renseigné',
            isComplete: hasLicence,
          ),
          
          if (showPPS) ...[
            const Divider(height: 16),
            MemberInfoRow(
              icon: Icons.description,
              label: 'Formulaire PPS',
              value: (ppsForm != null && ppsForm.isNotEmpty) ? 'Fourni' : 'Non fourni',
              isComplete: ppsForm != null && ppsForm.isNotEmpty,
              isEditable: isRaceManager,
              onEdit: () => onEditPPS(userId, ppsForm ?? '', fullName),
            ),
          ],
          
          const Divider(height: 16),
          MemberInfoRow(
            icon: Icons.sensors,
            label: 'N° de puce',
            value: chipNumber?.toString() ?? 'Non attribué',
            isComplete: chipNumber != null,
            isEditable: isRaceManager,
            onEdit: () => onEditChipNumber(userId, chipNumber, fullName),
          ),
        ],
      ),
    );
  }
}
