// lib/features/races/presentation/widgets/race_detail_section.dart
import 'package:flutter/material.dart';

/// Reusable section card for race detail screens.
///
/// Creates a card with colored header, optional subtitle, and custom content.
/// Used to organize race information into visual sections.
///
/// Example:
/// ```dart
/// RaceDetailSection(
///   title: 'Informations',
///   icon: Icons.info_outline,
///   color: Colors.blue,
///   subtitle: 'Détails de la course',
///   child: Text('Content here...'),
/// );
/// ```
class RaceDetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  final String? subtitle;

  const RaceDetailSection({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Optional subtitle
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

          const Divider(height: 1),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}
