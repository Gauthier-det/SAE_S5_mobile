// lib/features/teams/presentation/widgets/team_members_list.dart
// ... (début inchangé)

import 'package:flutter/material.dart';

class TeamMembersList extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  final bool canManageTeam;
  final bool isRaceManager;
  final int currentUserId; 
  final bool Function(int userId) canEditMember; 
  final int raceId;
  final VoidCallback onAddMember;
  final Function(int userId, String memberName) onRemoveMember;
  final Function(int userId, String currentPPS, String memberName) onEditPPS;
  final Function(int userId, int? currentChip, String memberName) onEditChipNumber;

  const TeamMembersList({
    super.key,
    required this.members,
    required this.canManageTeam,
    required this.isRaceManager,
    required this.currentUserId, 
    required this.canEditMember, 
    required this.raceId,
    required this.onAddMember,
    required this.onRemoveMember,
    required this.onEditPPS,
    required this.onEditChipNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Membres de l\'équipe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (canManageTeam)
                IconButton(
                  onPressed: onAddMember,
                  icon: const Icon(Icons.person_add),
                  tooltip: 'Ajouter un membre',
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...members.map((member) {
            final userId = member['USE_ID'] as int;
            final memberName = '${member['USE_NAME']} ${member['USE_LAST_NAME']}';
            final hasLicence = member['USE_LICENCE_NUMBER'] != null &&
                (member['USE_LICENCE_NUMBER']) != null ;
            final hasPPS = member['USR_PPS_FORM'] != null &&
                (member['USR_PPS_FORM'] as String).isNotEmpty;
            final chipNumber = member['USR_CHIP_NUMBER'] as int?;
            
            // ✅ Vérifier si on peut éditer CE membre
            final canEdit = canEditMember(userId);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF52B788),
                  child: Text(
                    member['USE_NAME'].toString()[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(memberName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Licence ou PPS
                    if (hasLicence)
                      Row(
                        children: [
                          const Icon(Icons.verified, size: 16, color: Color(0xFF52B788)),
                          const SizedBox(width: 4),
                          Text('Licence: ${member['USE_LICENCE_NUMBER']}'),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Icon(
                            hasPPS ? Icons.check_circle : Icons.warning,
                            size: 16,
                            color: hasPPS ? Colors.blue : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              hasPPS
                                  ? 'PPS: ${member['USR_PPS_FORM']}'
                                  : 'PPS non renseigné',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // ✅ Modifier PPS seulement si canEdit
                          if (canEdit && !hasLicence)
                            IconButton(
                              icon: const Icon(Icons.edit, size: 16),
                              onPressed: () => onEditPPS(
                                userId,
                                member['USR_PPS_FORM'] ?? '',
                                memberName,
                              ),
                            ),
                        ],
                      ),
                    
                    // Puce
                    Row(
                      children: [
                        const Icon(Icons.credit_card, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            chipNumber != null
                                ? 'Puce: $chipNumber'
                                : 'Puce non attribuée',
                          ),
                        ),
                        // ✅ Modifier puce seulement si canEdit
                        if (canEdit)
                          IconButton(
                            icon: const Icon(Icons.edit, size: 16),
                            onPressed: () => onEditChipNumber(
                              userId,
                              chipNumber,
                              memberName,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                // ✅ Retirer seulement si peut gérer l'équipe
                trailing: canManageTeam
                    ? IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => onRemoveMember(userId, memberName),
                      )
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }
}
