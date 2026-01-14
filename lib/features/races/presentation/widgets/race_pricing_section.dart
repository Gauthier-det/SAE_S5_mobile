// lib/features/races/presentation/widgets/race_pricing_section.dart (SIMPLIFIÉ)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sae5_g13_mobile/features/races/domain/category.dart';
import '../../domain/race_repository.dart';

class RacePricingSection extends StatelessWidget {
  final int raceId;

  const RacePricingSection({super.key, required this.raceId});

  @override
  Widget build(BuildContext context) {
    final repository = Provider.of<RacesRepository>(context, listen: false);

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        repository.getRaceCategoryPrices(raceId),
        repository.getCategories(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final prices = (snapshot.data?[0] as Map<int, double>?) ?? {};
        final categories = (snapshot.data?[1] as List<Category>?) ?? [];

        if (prices.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Aucun tarif défini'),
          );
        }

        return Column(
          children: prices.entries.map((entry) {
            final category = categories.firstWhere(
              (c) => c.id == entry.key,
              orElse: () => Category(
                id: entry.key,
                label: 'Catégorie ${entry.key}',
              ),
            );

            return _buildPriceRow(category.label, entry.value);
          }).toList(),
        );
      },
    );
  }

  Widget _buildPriceRow(String categoryName, double price) {
    Color color;

    if (categoryName.contains('Mineur')) {
      color = Colors.blue;
    } else if (categoryName.contains('Licencié')) {
      color = const Color(0xFF52B788);
    } else {
      color = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              categoryName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            '${price.toStringAsFixed(2)} €',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
