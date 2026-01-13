// lib/core/presentation/widgets/common_list_header.dart
import 'package:flutter/material.dart';

class CommonListHeader extends StatelessWidget {
  final String title;
  final bool hasFilters;
  final bool sortAscending;
  final VoidCallback onSortToggle;
  final VoidCallback onFilterTap;

  const CommonListHeader({
    super.key,
    required this.title,
    required this.hasFilters,
    required this.sortAscending,
    required this.onSortToggle,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        // Bouton tri
        IconButton(
          icon: Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
          tooltip: 'Inverser le tri',
          onPressed: onSortToggle,
        ),
        // Bouton filtres avec badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filtres',
              onPressed: onFilterTap,
            ),
            if (hasFilters)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B00),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 8,
                    minHeight: 8,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
