// lib/features/teams/presentation/widgets/add_member_dialog.dart
import 'package:flutter/material.dart';
import '../../../user/domain/user.dart';

/// Dialog for selecting and adding a member to a team [web:204][web:209][web:212].
///
/// Features real-time search filtering by name/email, single-selection UI with
/// visual feedback, and returns selected User via Navigator.pop [web:209][web:212].
///
/// **Features:**
/// - Search field with case-insensitive filter [web:211]
/// - Single-selection with visual indicators (checkmark, bold text, color)
/// - Empty state when no users match search
/// - Disabled "Ajouter" button until user selected
///
/// **Returns:** Selected User or null if canceled [web:209][web:212].
///
/// Example:
/// ```dart
/// final selectedUser = await showDialog<User>(
///   context: context,
///   builder: (context) => AddMemberDialog(
///     availableUsers: eligibleUsers,
///   ),
/// );
/// 
/// if (selectedUser != null) {
///   await teamRepository.addTeamMember(teamId, selectedUser.id, raceId: raceId);
/// }
/// ```
class AddMemberDialog extends StatefulWidget {
  final List<User> availableUsers;

  const AddMemberDialog({
    super.key,
    required this.availableUsers,
  });

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  String _searchQuery = '';
  User? _selectedUser;

  /// Filters users by name or email (case-insensitive) [web:211].
  List<User> get _filteredUsers {
    if (_searchQuery.isEmpty) return widget.availableUsers;
    
    final query = _searchQuery.toLowerCase();
    return widget.availableUsers.where((user) {
      return user.fullName.toLowerCase().contains(query) ||
             user.email.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un membre'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSearchField(),
            const SizedBox(height: 16),
            _buildUserList(),
          ],
        ),
      ),
      actions: _buildActions(context),
    );
  }

  /// Search input with live filtering [web:211].
  Widget _buildSearchField() {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Rechercher',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onChanged: (value) => setState(() => _searchQuery = value),
    );
  }

  /// Scrollable user list with selection state [web:204][web:208].
  Widget _buildUserList() {
    return Flexible(
      child: _filteredUsers.isEmpty
          ? const Center(
              child: Text(
                'Aucun utilisateur trouvé',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                final isSelected = _selectedUser?.id == user.id;
                
                return ListTile(
                  leading: _buildUserAvatar(user, isSelected),
                  title: Text(
                    user.fullName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(user.email),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF52B788))
                      : null,
                  selected: isSelected,
                  selectedTileColor: const Color(0xFF52B788).withOpacity(0.1),
                  onTap: () => setState(() => _selectedUser = user),
                );
              },
            ),
    );
  }

  /// Avatar with selection state styling.
  Widget _buildUserAvatar(User user, bool isSelected) {
    return CircleAvatar(
      backgroundColor: isSelected ? const Color(0xFF52B788) : Colors.grey.shade300,
      child: Text(
        user.name[0].toUpperCase(),
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Cancel and confirm actions [web:209][web:212].
  List<Widget> _buildActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      ElevatedButton(
        onPressed: _selectedUser == null
            ? null
            : () => Navigator.pop(context, _selectedUser),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF52B788),
        ),
        child: const Text('Ajouter'),
      ),
    ];
  }
}
