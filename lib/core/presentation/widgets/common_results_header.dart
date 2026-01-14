// lib/core/presentation/widgets/common_results_header.dart
import 'package:flutter/material.dart';

class CommonResultsHeader extends StatelessWidget {
  final int count;
  final String itemName;
  final String sortLabel;
  final bool sortAscending;
  final VoidCallback onSortToggle;

  const CommonResultsHeader({
    super.key,
    required this.count,
    required this.itemName,
    required this.sortLabel,
    required this.sortAscending,
    required this.onSortToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$count $itemName trouvé${count > 1 ? 's' : ''}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton.icon(
            onPressed: onSortToggle,
            icon: Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
            label: Text(sortLabel),
          ),
        ],
      ),
    );
  }
}
