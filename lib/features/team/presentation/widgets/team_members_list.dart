// lib/features/teams/presentation/widgets/team_members_list.dart
import 'package:flutter/material.dart';
import 'member_card.dart';

class TeamMembersList extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  final bool canManageTeam;
  final bool isRaceManager;
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
            children: [
              const Icon(Icons.people, color: Color(0xFF1B3022)),
              const SizedBox(width: 8),
              Text(
                'Membres (${members.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (canManageTeam)
                IconButton(
                  icon: const Icon(Icons.person_add),
                  color: const Color(0xFF52B788),
                  onPressed: onAddMember,
                  tooltip: 'Ajouter un membre',
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...members.map((member) => MemberCard(
                member: member,
                canRemove: canManageTeam,
                isRaceManager: isRaceManager,
                onRemove: onRemoveMember,
                onEditPPS: onEditPPS,
                onEditChipNumber: onEditChipNumber,
              )),
        ],
      ),
    );
  }
}
