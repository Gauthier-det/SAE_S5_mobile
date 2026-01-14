// lib/features/races/presentation/widgets/raid_info_banner.dart
import 'package:flutter/material.dart';
import '../../../../shared/utils/date_formatter.dart';
import '../../../raid/domain/raid.dart';

class RaidInfoBanner extends StatelessWidget {
  final Raid raid;

  const RaidInfoBanner({super.key, required this.raid});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Raid : ${raid.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${DateFormatter.formatDateTime(raid.timeStart)} - ${DateFormatter.formatDateTime(raid.timeEnd)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
