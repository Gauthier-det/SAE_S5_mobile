// lib/features/races/presentation/widgets/race_form_date_field.dart
import 'package:flutter/material.dart';
import '../../../../shared/utils/date_formatter.dart';

class RaceFormDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
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
