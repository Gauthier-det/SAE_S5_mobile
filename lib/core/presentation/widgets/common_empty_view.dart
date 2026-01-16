// lib/core/presentation/widgets/common_empty_view.dart
import 'package:flutter/material.dart';

/// A reusable widget that displays an empty state view with an icon, title,
/// optional subtitle, and optional action button.
///
/// This widget is typically used to inform users when there is no data to display,
/// such as empty lists, failed API responses, or initial states before data is loaded.
/// It provides a consistent and user-friendly way to communicate empty states
/// throughout the application [web:5].
///
/// Example usage:
/// ```dart
/// CommonEmptyView(
///   icon: Icons.inbox,
///   title: 'No Messages',
///   subtitle: 'You don\'t have any messages yet',
///   action: ElevatedButton(
///     onPressed: () => _refreshData(),
///     child: Text('Refresh'),
///   ),
/// )
/// ```
class CommonEmptyView extends StatelessWidget {
  /// The icon to display at the top of the empty view.
  ///
  /// This icon provides a visual representation of the empty state [web:10].
  final IconData icon;

  /// The main title text displayed below the icon.
  ///
  /// This should be a short, descriptive message explaining the empty state,
  /// such as "No Data Available" or "List is Empty".
  final String title;

  /// An optional subtitle providing additional context or instructions.
  ///
  /// This can be used to give users more information about why the view is empty
  /// or what they can do next. If null, no subtitle will be displayed.
  final String? subtitle;

  /// An optional action widget, typically a button, displayed at the bottom.
  ///
  /// This can be used to provide users with a call-to-action, such as a refresh
  /// button or navigation to another screen [web:5]. If null, no action will be displayed.
  final Widget? action;

  /// Creates a [CommonEmptyView] widget.
  ///
  /// The [icon] and [title] parameters are required to ensure the empty view
  /// always communicates its purpose clearly to users.
  const CommonEmptyView({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.headlineSmall),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
