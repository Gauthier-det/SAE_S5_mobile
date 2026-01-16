// lib/features/teams/presentation/widgets/user_autocomplete_selector.dart
import 'package:flutter/material.dart';
import '../../../user/domain/user.dart';

/// Multi-select autocomplete for team member selection with availability validation [web:262][web:264][web:267].
///
/// Combines Autocomplete widget with Chip display for selected members (max 5).
/// Shows availability indicators (conflicts, age restrictions, team membership)
/// and prevents selection of unavailable users [web:262][web:263][web:264].
///
/// **Features:**
/// - Search-as-you-type filtering [web:262][web:264]
/// - Chip-based selection display (removable via delete icon) [web:267]
/// - Empty state shows all available users [web:262]
/// - Custom optionsViewBuilder with availability badges [web:269]
/// - Disabled state for unavailable users with reason chips
///
/// **Availability Flags on User:**
/// - `isAvailable`: Overall availability (default true)
/// - `hasOverlappingRace`: Time conflict with other race
/// - `alreadyInTeam`: Already member of another team
/// - `isSelf`: Current logged-in user (shown with "Moi" badge)
/// - `invalidAge`: Below minimum age (12 years)
///
/// Example:
/// ```dart
/// UserAutocompleteSelector(
///   availableUsers: [
///     User(
///       id: 1,
///       name: 'John',
///       lastName: 'Doe',
///       email: 'john@example.com',
///       isAvailable: true,
///       isSelf: false,
///     ),
///     User(
///       id: 2,
///       name: 'Jane',
///       lastName: 'Smith',
///       email: 'jane@example.com',
///       isAvailable: false,
///       hasOverlappingRace: true,
///     ),
///   ],
///   selectedMembers: selectedUsers,
///   onUserSelected: (user) {
///     setState(() {
///       if (selectedUsers.contains(user)) {
///         selectedUsers.remove(user); // Toggle off
///       } else {
///         selectedUsers.add(user); // Toggle on
///       }
///     });
///   },
/// );
/// ```
class UserAutocompleteSelector extends StatefulWidget {
  final List<User> availableUsers;
  final List<User> selectedMembers;
  final ValueChanged<User> onUserSelected;

  const UserAutocompleteSelector({
    super.key,
    required this.availableUsers,
    required this.selectedMembers,
    required this.onUserSelected,
  });

  @override
  State<UserAutocompleteSelector> createState() =>
      _UserAutocompleteSelectorState();
}

class _UserAutocompleteSelectorState extends State<UserAutocompleteSelector> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected members as removable chips [web:267]
        if (widget.selectedMembers.isNotEmpty) ...[
          Text(
            'Membres sélectionnés (${widget.selectedMembers.length}/5)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedMembers.map((user) {
              return Chip(
                avatar: CircleAvatar(
                  backgroundColor: const Color(0xFF52B788),
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                label: Text(user.fullName),
                onDeleted: () => widget.onUserSelected(user),
                deleteIcon: const Icon(Icons.close, size: 18),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Autocomplete search field [web:262][web:264]
        Autocomplete<User>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            // Empty query: show all non-selected users [web:262]
            if (textEditingValue.text.isEmpty) {
              final nonSelected = widget.availableUsers
                  .where(
                    (user) =>
                        !widget.selectedMembers.any((m) => m.id == user.id),
                  )
                  .toList();

              return nonSelected;
            }

            // Filter by search query
            final filtered = widget.availableUsers.where((user) {
              final isNotSelected = !widget.selectedMembers.any(
                (m) => m.id == user.id,
              );
              final matchesSearch = user.fullName.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              );
              return isNotSelected && matchesSearch;
            }).toList();
            return filtered;
          },
          displayStringForOption: (User user) => user.fullName,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Rechercher et ajouter un membre...',
                prefixIcon: const Icon(Icons.person_add),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onTap: () {},
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  width: MediaQuery.of(context).size.width - 32,
                  margin: const EdgeInsets.only(top: 4),
                  child: options.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Aucun utilisateur trouvé'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final user = options.elementAt(index);
                            // Extract availability flags [web:251]
                            final isAvailable = user.isAvailable ?? true;
                            final hasOverlappingRace =
                                user.hasOverlappingRace ?? false;
                            final alreadyInTeam = user.alreadyInTeam ?? false;
                            final isSelf = user.isSelf ?? false;
                            final invalidAge = user.invalidAge ?? false;

                            return ListTile(
                              enabled: isAvailable,
                              leading: CircleAvatar(
                                backgroundColor: isAvailable
                                    ? const Color(0xFF52B788).withOpacity(0.2)
                                    : Colors.grey.shade300,
                                child: Text(
                                  user.name[0].toUpperCase(),
                                  style: TextStyle(
                                    color: isAvailable
                                        ? const Color(0xFF52B788)
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      user.fullName,
                                      style: TextStyle(
                                        color: isAvailable ? null : Colors.grey,
                                      ),
                                    ),
                                  ),
                                  if (isSelf) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'Moi',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.email,
                                    style: TextStyle(
                                      color: isAvailable ? null : Colors.grey,
                                    ),
                                  ),
                                  if (!isAvailable) ...[
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 4,
                                      children: [
                                        if (alreadyInTeam)
                                          _buildChip(
                                            'Déjà en équipe',
                                            Colors.red,
                                          ),
                                        if (hasOverlappingRace &&
                                            !alreadyInTeam)
                                          _buildChip(
                                            'Course en conflit',
                                            Colors.orange,
                                          ),
                                        if (invalidAge)
                                          _buildChip(
                                            'Âge invalide',
                                            Colors.purple,
                                          ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              onTap: isAvailable
                                  ? () {
                                      onSelected(user);
                                    }
                                  : null,
                            );
                          },
                        ),
                ),
              ),
            );
          },
          onSelected: (User user) {
            // Block if not available
            if (!(user.isAvailable ?? true)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cet utilisateur n\'est pas disponible'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            // Enforce max 5 members
            if (widget.selectedMembers.length >= 5) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Maximum 5 membres par équipe'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }
            widget.onUserSelected(user);
          },
        ),

        const SizedBox(height: 8),
        Text(
          'Cliquez dans le champ et tapez pour rechercher',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  /// Builds unavailability reason chip.
  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
