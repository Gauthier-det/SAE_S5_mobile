// lib/features/races/presentation/widgets/race_form_ages_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RaceFormAgesSection extends StatelessWidget {
  final TextEditingController ageMinController;
  final TextEditingController ageMiddleController;
  final TextEditingController ageMaxController;

  const RaceFormAgesSection({
    super.key,
    required this.ageMinController,
    required this.ageMiddleController,
    required this.ageMaxController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégories d\'âge *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'A < B < C : Si une personne entre A et B, une autre >= C, sinon tout le monde >= B',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: ageMinController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Âge A (min)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Obligatoire';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: ageMiddleController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Âge B (moyen)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Obligatoire';
                  final ageMin = int.tryParse(ageMinController.text);
                  final ageMiddle = int.tryParse(value);
                  if (ageMin != null &&
                      ageMiddle != null &&
                      ageMiddle <= ageMin) {
                    return 'B > A';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: ageMaxController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Âge C (max)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Obligatoire';
                  final ageMiddle = int.tryParse(ageMiddleController.text);
                  final ageMax = int.tryParse(value);
                  if (ageMiddle != null &&
                      ageMax != null &&
                      ageMax <= ageMiddle) {
                    return 'C > B';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
