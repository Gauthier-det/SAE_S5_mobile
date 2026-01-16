// lib/features/raids/presentation/widgets/raid_card.dart
import 'package:flutter/material.dart';
import '../../../../shared/utils/date_formatter.dart';
import '../../../raid/domain/raid.dart';
import 'raid_status_badges.dart';

/// Raid list card widget.
///
/// Displays raid summary with optional image, name, status badges, location,
/// and date range. Shows placeholder icon if image fails to load [web:138].
///
/// Example:
/// ```dart
/// RaidCard(
///   raid: raid,
///   onTap: () => Navigator.push(...),
/// );
/// ```
class RaidCard extends StatelessWidget {
  final Raid raid;
  final VoidCallback onTap;

  const RaidCard({
    super.key,
    required this.raid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with fallback [web:138]
            if (raid.image != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  raid.image!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.landscape,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    raid.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RaidStatusBadges(raid: raid),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.place,
                    raid.address?.cityName ?? 'Non spécifié',
                    theme,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.calendar_today,
                    '${DateFormatter.formatDate(raid.timeStart)} - ${DateFormatter.formatDate(raid.timeEnd)}',
                    theme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds info row with icon and text.
  Widget _buildInfoRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
