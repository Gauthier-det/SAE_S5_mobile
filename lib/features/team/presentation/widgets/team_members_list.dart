// lib/features/teams/presentation/widgets/team_members_list.dart
import 'package:flutter/material.dart';

/// List of team members with granular permission-based actions [web:243][web:249][web:251].
///
/// Displays members with licence/PPS/chip info and conditional edit/remove
/// actions. Uses two permission levels: canManageTeam (add/remove) and
/// canEditMember (edit PPS/chip per member) [web:228][web:231][web:250].
///
/// **Permission Model:**
/// - canManageTeam: Add members, remove any member
/// - canEditMember(userId): Edit specific member's PPS/chip (race managers)
/// - Separate permissions allow team creator != race manager scenarios
///
/// **Business Rules:**
/// - If member has licence → PPS not shown/editable
/// - If no licence → PPS shown with edit button (if canEditMember)
/// - Chip number always editable by race managers
///
/// Example:
/// ```dart
/// TeamMembersList(
///   members: [
///     {
///       'USE_ID': 1,
///       'USE_NAME': 'John',
///       'USE_LAST_NAME': 'Doe',
///       'USE_LICENCE_NUMBER': 12345,
///       'USR_PPS_FORM': null,
///       'USR_CHIP_NUMBER': 42,
///     },
///   ],
///   canManageTeam: isTeamCreator,
///   isRaceManager: isManager,
///   currentUserId: userId,
///   canEditMember: (userId) => isManager || isTeamCreator,
///   raceId: raceId,
///   onAddMember: () => _showAddDialog(),
///   onRemoveMember: (id, name) => _confirmRemove(id),
///   onEditPPS: (id, pps, name) => _showPPSDialog(id, pps),
///   onEditChipNumber: (id, chip, name) => _showChipDialog(id, chip),
/// );
/// ```
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
                (member['USE_LICENCE_NUMBER']) != null;
            final hasPPS = member['USR_PPS_FORM'] != null &&
                (member['USR_PPS_FORM'] as String).isNotEmpty;
            final chipNumber = member['USR_CHIP_NUMBER'] as int?;
            
            // Check if current user can edit this specific member [web:250]
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
                    // Licence or PPS (mutually exclusive)
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
                          // Edit PPS only if no licence and user can edit [web:228][web:231]
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
                    
                    // Chip number (always shown)
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
                        // Edit chip if user can edit this member [web:250]
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
                // Remove only if can manage team [web:228]
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
