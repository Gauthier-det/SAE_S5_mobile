// lib/features/races/presentation/widgets/race_filter_dialog.dart
import 'package:flutter/material.dart';

/// Race filter dialog widget.
///
/// Modal dialog for filtering races by type (Compétitif/Rando) and difficulty
/// level. Uses FilterChip widgets for selection [web:184].
///
/// Example:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => RaceFilterDialog(
///     selectedType: _currentType,
///     selectedDifficulty: _currentDifficulty,
///     onApply: (type, difficulty) {
///       setState(() {
///         _currentType = type;
///         _currentDifficulty = difficulty;
///       });
///     },
///   ),
/// );
/// ```
class RaceFilterDialog extends StatefulWidget {
  final String? selectedType;
  final String? selectedDifficulty;
  final Function(String?, String?) onApply;

  const RaceFilterDialog({
    super.key,
    this.selectedType,
    this.selectedDifficulty,
    required this.onApply,
  });

  @override
  State<RaceFilterDialog> createState() => _RaceFilterDialogState();
}

class _RaceFilterDialogState extends State<RaceFilterDialog> {
  String? _tempType;
  String? _tempDifficulty;

  @override
  void initState() {
    super.initState();
    _tempType = widget.selectedType;
    _tempDifficulty = widget.selectedDifficulty;
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
            // Type filter
            const Text(
              'Type de course',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('Tous', null, _tempType, (value) {
                  setState(() => _tempType = value);
                }),
                _buildFilterChip('Compétitif', 'Compétitif', _tempType, (value) {
                  setState(() => _tempType = value);
                }),
                _buildFilterChip('Rando/Loisirs', 'Rando/Loisirs', _tempType,
                    (value) {
                  setState(() => _tempType = value);
                }),
              ],
            ),
            const SizedBox(height: 16),

            // Difficulty filter
            const Text(
              'Difficulté',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('Toutes', null, _tempDifficulty, (value) {
                  setState(() => _tempDifficulty = value);
                }),
                for (var difficulty in [
                  'Facile',
                  'Moyen',
                  'Difficile',
                  'Expert',
                  'Très Expert'
                ])
                  _buildFilterChip(difficulty, difficulty, _tempDifficulty,
                      (value) {
                    setState(() => _tempDifficulty = value);
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
            widget.onApply(_tempType, _tempDifficulty);
            Navigator.pop(context);
          },
          child: const Text('Appliquer'),
        ),
      ],
    );
  }

  /// Builds a filter chip with selection state [web:184].
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
