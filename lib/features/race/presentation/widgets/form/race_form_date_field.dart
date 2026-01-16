// lib/features/races/presentation/widgets/race_form_date_field.dart
import 'package:flutter/material.dart';
import '../../../../../shared/utils/date_formatter.dart';

/// Date picker field for race forms.
///
/// Displays a read-only field that opens a date picker when tapped [web:150].
/// Shows formatted date or placeholder text if no date is selected.
///
/// Example:
/// ```dart
/// RaceFormDateField(
///   label: 'Date de début',
///   date: _startDate,
///   onTap: () => _selectDate(context),
/// );
/// ```
class RaceFormDateField extends StatelessWidget {
  /// Field label text.
  final String label;

  /// Currently selected date, or null if none selected.
  final DateTime? date;

  /// Callback when field is tapped (typically opens date picker).
  final VoidCallback onTap;

  const RaceFormDateField({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          date == null
              ? 'Sélectionner une date'
              : DateFormatter.formatDateTime(date!),
          style: TextStyle(
            color: date == null ? Colors.grey.shade600 : Colors.black,
          ),
        ),
      ),
    );
  }
}
