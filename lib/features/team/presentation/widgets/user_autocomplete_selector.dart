// lib/features/teams/presentation/widgets/user_autocomplete_selector.dart
import 'package:flutter/material.dart';
import '../../../user/domain/user.dart';

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
  State<UserAutocompleteSelector> createState() => _UserAutocompleteSelectorState();
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
        // Membres sélectionnés
        if (widget.selectedMembers.isNotEmpty) ...[
          Text(
            'Membres sélectionnés (${widget.selectedMembers.length}/5)',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
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

        // Autocomplete
        Autocomplete<User>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            
            
            // Si vide, afficher tous les users non sélectionnés
            if (textEditingValue.text.isEmpty) {
              final nonSelected = widget.availableUsers
                  .where((user) => !widget.selectedMembers.any((m) => m.id == user.id))
                  .toList();
              
              
              return nonSelected;
            }
            
            // Sinon filtrer
            final filtered = widget.availableUsers.where((user) {
              final isNotSelected = !widget.selectedMembers.any((m) => m.id == user.id);
              final matchesSearch = user.fullName
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
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
              onTap: () {
                print('🖱️ DEBUG TextField cliqué');
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            print('👁️ DEBUG optionsViewBuilder: ${options.length} options à afficher');
            
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
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF52B788).withOpacity(0.2),
                                child: Text(
                                  user.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF52B788),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(user.fullName),
                              subtitle: Text(user.email),
                              onTap: () {
                                print('✅ DEBUG User sélectionné: ${user.fullName}');
                                onSelected(user);
                              },
                            );
                          },
                        ),
                ),
              ),
            );
          },
          onSelected: (User user) {
            print('🎯 DEBUG onSelected appelé pour: ${user.fullName}');
            
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
