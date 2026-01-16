// lib/core/presentation/widgets/common_info_card.dart
import 'package:flutter/material.dart';

/// A reusable card widget that displays information with an icon, title, and content.
///
/// This widget implements a Material Design card pattern that presents related information
/// in a structured, visually appealing format [web:37][web:44]. The card includes a colored
/// icon container, a title label, main content text, and an optional trailing widget for
/// actions or additional UI elements.
///
/// The [Card] widget follows Material Design specifications by providing a panel with
/// rounded corners and elevation shadows, creating visual separation and depth in the UI [web:38][web:40].
/// This pattern is commonly used for displaying statistics, user information, or any
/// grouped data that benefits from visual organization [web:41].
///
/// Example usage:
/// ```dart
/// CommonInfoCard(
///   icon: Icons.person,
///   title: 'Total Users',
///   content: '1,234',
///   color: Colors.blue,
///   trailing: IconButton(
///     icon: Icon(Icons.arrow_forward),
///     onPressed: () => Navigator.push(...),
///   ),
/// )
/// ```
class CommonInfoCard extends StatelessWidget {
  /// The icon to display in the colored container on the left side.
  ///
  /// This icon provides a visual representation of the information type
  /// being displayed in the card [web:38].
  final IconData icon;

  /// The label text displayed above the main content.
  ///
  /// This should be a short, descriptive label like "Temperature", "Users",
  /// or "Revenue" that identifies what the content represents.
  final String title;

  /// The main content text displayed prominently in the card.
  ///
  /// This is typically a value, statistic, or key information that corresponds
  /// to the title, such as "23°C", "1,234 users", or "$45,678".
  final String content;

  /// Optional color for the icon container and icon.
  ///
  /// When null, defaults to the theme's primary color. This allows customization
  /// of the card's appearance to match different categories or importance levels [web:38].
  final Color? color;

  /// Optional widget displayed on the right side of the card.
  ///
  /// The trailing widget is commonly used for action buttons, navigation icons,
  /// or additional UI elements related to the card's content [web:42][web:45].
  /// When null, no trailing widget is displayed.
  final Widget? trailing;

  /// Creates a [CommonInfoCard] widget.
  ///
  /// The [icon], [title], and [content] parameters are required to ensure
  /// the card always displays meaningful information to users.
  const CommonInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24, color: cardColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[?trailing],
          ],
        ),
      ),
    );
  }
}
