// lib/features/raids/presentation/widgets/raid_filter_dialog.dart
import 'package:flutter/material.dart';

class RaidFilterDialog extends StatefulWidget {
  final String? selectedStatus;
  final String? selectedRegistrationStatus;
  final Function(String?, String?) onApply;

  const RaidFilterDialog({
    super.key,
    this.selectedStatus,
    this.selectedRegistrationStatus,
    required this.onApply,
  });

  @override
  State<RaidFilterDialog> createState() => _RaidFilterDialogState();
}

class _RaidFilterDialogState extends State<RaidFilterDialog> {
  String? _tempStatus;
  String? _tempRegistrationStatus;

  @override
  void initState() {
    super.initState();
    _tempStatus = widget.selectedStatus;
    _tempRegistrationStatus = widget.selectedRegistrationStatus;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtres'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtre statut raid
            const Text(
              'Statut du raid',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('Tous', null, _tempStatus, (value) {
                  setState(() => _tempStatus = value);
                }),
                _buildFilterChip('À venir', 'upcoming', _tempStatus, (value) {
                  setState(() => _tempStatus = value);
                }),
                _buildFilterChip('En cours', 'ongoing', _tempStatus, (value) {
                  setState(() => _tempStatus = value);
                }),
                _buildFilterChip('Terminé', 'finished', _tempStatus, (value) {
                  setState(() => _tempStatus = value);
                }),
              ],
            ),
            const SizedBox(height: 16),

            // Filtre inscriptions
            const Text(
              'Inscriptions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('Toutes', null, _tempRegistrationStatus, (value) {
                  setState(() => _tempRegistrationStatus = value);
                }),
                _buildFilterChip('À venir', 'upcoming', _tempRegistrationStatus, (value) {
                  setState(() => _tempRegistrationStatus = value);
                }),
                _buildFilterChip('Ouvertes', 'open', _tempRegistrationStatus, (value) {
                  setState(() => _tempRegistrationStatus = value);
                }),
                _buildFilterChip('Closes', 'closed', _tempRegistrationStatus, (value) {
                  setState(() => _tempRegistrationStatus = value);
                }),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(_tempStatus, _tempRegistrationStatus);
            Navigator.pop(context);
          },
          child: const Text('Appliquer'),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    String? value,
    String? currentValue,
    ValueChanged<String?> onSelected,
  ) {
    return FilterChip(
      label: Text(label),
      selected: currentValue == value,
      onSelected: (selected) => onSelected(selected ? value : null),
    );
  }
}
