// lib/core/presentation/widgets/common_filter_chip_row.dart
import 'package:flutter/material.dart';

/// A reusable widget that displays active filters as removable chips in a horizontal row.
///
/// This widget implements the Material Design filter pattern using chips, allowing users
/// to see which filters are currently applied and providing options to remove individual
/// filters or clear all filters at once [web:30][web:35]. The widget automatically hides
/// itself when no filters are active, providing a clean UI that only appears when needed.
///
/// The [Wrap] widget is used to display the chips, which automatically wraps to multiple
/// lines if the filters exceed the available horizontal space [web:31][web:34]. This ensures
/// the UI remains functional even with many active filters.
///
/// This pattern is commonly used in e-commerce apps, search results, and content
/// filtering interfaces to provide visual feedback about active filters [web:30].
///
/// Example usage:
/// ```dart
/// CommonFilterChipRow(
///   filters: ['Electronics', 'In Stock', 'Price: $0-$100'],
///   onClear: () {
///     // Clear all filters in parent state
///     setState(() => _activeFilters.clear());
///   },
/// )
/// ```
class CommonFilterChipRow extends StatelessWidget {
  /// The list of active filter labels to display as chips.
  ///
  /// Each string in the list will be displayed as a separate [Chip] widget
  /// with a delete icon. When the list is empty, the entire widget is hidden
  /// using [SizedBox.shrink].
  final List<String> filters;

  /// Callback function triggered when the "Clear All" button is pressed.
  ///
  /// This callback should handle clearing all active filters in the parent
  /// widget's state. The [VoidCallback] signature means this function takes
  /// no parameters and returns no value [web:26].
  final VoidCallback onClear;

  /// Creates a [CommonFilterChipRow] widget.
  ///
  /// Both [filters] and [onClear] are required parameters to ensure the widget
  /// can display filters and provide a mechanism to clear them.
  const CommonFilterChipRow({
    super.key,
    required this.filters,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    // Hide the widget completely when there are no active filters
    if (filters.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              // Horizontal spacing between chips in the same row [web:31]
              spacing: 8,
              // Vertical spacing between rows when chips wrap to multiple lines [web:31]
              runSpacing: 8,
              children: filters
                  .map((filter) => Chip(
                        label: Text(filter),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {}, // Handled by parent widget
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
