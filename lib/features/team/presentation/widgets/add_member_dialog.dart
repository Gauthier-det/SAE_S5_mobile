// lib/features/teams/presentation/widgets/add_member_dialog.dart
import 'package:flutter/material.dart';
import '../../../user/domain/user.dart';

class AddMemberDialog extends StatefulWidget {
  final List<User> availableUsers;

  const AddMemberDialog({super.key, required this.availableUsers});

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  String _searchQuery = '';
  User? _selectedUser;

  List<User> get _filteredUsers {
    List<User> filtered = widget.availableUsers;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((user) {
        return user.fullName.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query);
      }).toList();
    }

    // sort: available first, then alphabetical
    filtered.sort((a, b) {
      if ((a.isAvailable ?? true) && !(b.isAvailable ?? true)) return -1;
      if (!(a.isAvailable ?? true) && (b.isAvailable ?? true)) return 1;
      return a.fullName.compareTo(b.fullName);
    });

    return filtered;
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
                final isAvailable = user.isAvailable ?? true;

                String? conflictReason;
                if (!isAvailable) {
                  if (user.alreadyInTeam == true) {
                    conflictReason = 'Déjà dans une équipe pour cette course';
                  } else if (user.hasOverlappingRace == true) {
                    conflictReason = 'Inscrit à une course en même temps';
                  } else {
                    conflictReason = 'Indisponible';
                  }
                }

                return ListTile(
                  leading: _buildUserAvatar(user, isSelected, isAvailable),
                  title: Text(
                    user.fullName,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isAvailable ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.email,
                        style: TextStyle(
                          color: isAvailable
                              ? Colors.grey[600]
                              : Colors.grey[400],
                        ),
                      ),
                      if (conflictReason != null)
                        Text(
                          conflictReason,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF52B788))
                      : null,
                  selected: isSelected,
                  selectedTileColor: const Color(0xFF52B788).withOpacity(0.1),
                  enabled: isAvailable,
                  onTap: isAvailable
                      ? () => setState(() => _selectedUser = user)
                      : null,
                );
              },
            ),
    );
  }

  Widget _buildUserAvatar(User user, bool isSelected, bool isAvailable) {
    return CircleAvatar(
      backgroundColor: isAvailable
          ? (isSelected ? const Color(0xFF52B788) : Colors.grey.shade300)
          : Colors.grey.shade200,
      child: Text(
        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
        style: TextStyle(
          color: isAvailable
              ? (isSelected ? Colors.white : Colors.black87)
              : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

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
