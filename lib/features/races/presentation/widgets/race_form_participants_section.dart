// lib/features/races/presentation/widgets/race_form_participants_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RaceFormParticipantsSection extends StatelessWidget {
  final TextEditingController minParticipantsController;
  final TextEditingController maxParticipantsController;
  final TextEditingController minTeamsController;
  final TextEditingController maxTeamsController;
  final TextEditingController teamMembersController;

  const RaceFormParticipantsSection({
    super.key,
    required this.minParticipantsController,
    required this.maxParticipantsController,
    required this.minTeamsController,
    required this.maxTeamsController,
    required this.teamMembersController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participants',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: minParticipantsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Min participants',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: maxParticipantsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Max participants',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Équipes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: minTeamsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Min équipes',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: maxTeamsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Max équipes',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: teamMembersController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Membres par équipe * (max 5)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.people),
            helperText: 'Maximum 5 membres par équipe',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Obligatoire';
            final members = int.tryParse(value);
            if (members == null || members < 1) {
              return 'Doit être >= 1';
            }
            if (members > 5) {
              return 'Maximum 5 membres';
            }
            return null;
          },
        ),
      ],
    );
  }
}
