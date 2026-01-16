// lib/core/presentation/widgets/common_list_header.dart
import 'package:flutter/material.dart';

/// A reusable app bar header widget for list screens with sorting and filtering controls.
///
/// This widget implements a common list header pattern that provides users with controls
/// to sort and filter list data [web:47][web:52]. The header displays a title and two
/// action buttons: a sort toggle button that switches between ascending and descending order,
/// and a filter button with an optional badge indicator when filters are active.
///
/// The sorting icon dynamically changes between an upward and downward arrow to indicate
/// the current sort direction, following common UI patterns for sortable lists [web:52].
/// The filter button uses a [Stack] with a [Positioned] badge to visually indicate when
/// filters are applied, improving user awareness of active filtering [web:54].
///
/// This widget extends [AppBar], which is a Material Design component that displays content
/// and actions related to the current screen [web:47][web:50].
///
/// Example usage:
/// ```dart
/// CommonListHeader(
///   title: 'Products',
///   hasFilters: _activeFilters.isNotEmpty,
///   sortAscending: _sortAscending,
///   onSortToggle: () {
///     setState(() => _sortAscending = !_sortAscending);
///     _sortProducts();
///   },
///   onFilterTap: () => _showFilterDialog(),
/// )
/// ```
class CommonListHeader extends StatelessWidget {
  /// The title text displayed in the app bar.
  ///
  /// This typically describes the content being displayed, such as "Products",
  /// "Users", or "Orders".
  final String title;

  /// Whether filters are currently active.
  ///
  /// When true, a colored badge indicator appears on the filter button to provide
  /// visual feedback that filters are applied [web:54]. This helps users understand
  /// that the displayed list is filtered.
  final bool hasFilters;

  /// The current sort direction.
  ///
  /// When true, displays an upward arrow icon indicating ascending sort order.
  /// When false, displays a downward arrow icon indicating descending sort order [web:52].
  final bool sortAscending;

  /// Callback function triggered when the sort button is tapped.
  ///
  /// This should handle toggling the sort direction and re-sorting the list data.
  /// The parent widget is responsible for managing the sort state and updating
  /// the list accordingly [web:52].
  final VoidCallback onSortToggle;

  /// Callback function triggered when the filter button is tapped.
  ///
  /// This typically opens a filter dialog or bottom sheet where users can
  /// select filter criteria. The parent widget manages the filter state and
  /// applies filters to the list.
  final VoidCallback onFilterTap;

  /// Creates a [CommonListHeader] widget.
  ///
  /// All parameters are required to ensure the header functions properly with
  /// complete sorting and filtering capabilities.
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
        // Sort toggle button
        IconButton(
          icon: Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
          tooltip: 'Inverser le tri',
          onPressed: onSortToggle,
        ),
        // Filter button with active state badge indicator
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
