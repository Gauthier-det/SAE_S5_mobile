// lib/core/presentation/widgets/common_filter_chip_row.dart
import 'package:flutter/material.dart';

class CommonFilterChipRow extends StatelessWidget {
  final List<String> filters;
  final VoidCallback onClear;

  const CommonFilterChipRow({
    super.key,
    required this.filters,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filters
                  .map((filter) => Chip(
                        label: Text(filter),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {}, // Géré par le parent
                      ))
                  .toList(),
            ),
          ),
          TextButton(
            onPressed: onClear,
            child: const Text('Tout effacer'),
          ),
        ],
      ),
    );
  }
}
