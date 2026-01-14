// lib/features/races/presentation/widgets/category_price_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sae5_g13_mobile/features/race/domain/category.dart';

class CategoryPriceSelector extends StatefulWidget {
  final List<Category> categories;
  final Map<int, double> initialPrices;
  final ValueChanged<Map<int, double>> onChanged;

  const CategoryPriceSelector({
    super.key,
    required this.categories,
    required this.initialPrices,
    required this.onChanged,
  });

  @override
  State<CategoryPriceSelector> createState() => _CategoryPriceSelectorState();
}

class _CategoryPriceSelectorState extends State<CategoryPriceSelector> {
  late Map<int, TextEditingController> _controllers;
  late Map<int, double> _prices;
  final Map<int, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    _prices = Map.from(widget.initialPrices);
    _controllers = {};

    for (var category in widget.categories) {
      _controllers[category.id] = TextEditingController(
        text: _prices[category.id]?.toStringAsFixed(2) ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updatePrice(int categoryId, String value) {
    final price = double.tryParse(value);
    setState(() {
      if (price != null && price > 0) {
        _prices[categoryId] = price;
        _validatePrices();
      } else {
        _prices.remove(categoryId);
        _errors.remove(categoryId);
      }
      widget.onChanged(_prices);
    });
  }

  void _validatePrices() {
    _errors.clear();

    // Trouver les catégories par leur label
    final mineurCat = widget.categories.firstWhere(
      (c) => c.label == 'Mineur',
      orElse: () => widget.categories.first,
    );
    final licencieCat = widget.categories.firstWhere(
      (c) => c.label == 'Licencié',
      orElse: () => widget.categories.last,
    );
    final nonLicencieCat = widget.categories.firstWhere(
      (c) => c.label == 'Majeur non licencié',
      orElse: () => widget.categories[1],
    );

    final prixMineur = _prices[mineurCat.id];
    final prixLicencie = _prices[licencieCat.id];
    final prixNonLicencie = _prices[nonLicencieCat.id];

    // Validation 1 : Prix licencié <= Prix mineur
    if (prixLicencie != null && prixMineur != null && prixLicencie > prixMineur) {
      _errors[licencieCat.id] = 'Doit être ≤ au prix Mineur (${prixMineur.toStringAsFixed(2)}€)';
    }

    // Validation 2 : Prix non licencié >= Prix mineur
    if (prixNonLicencie != null && prixMineur != null && prixNonLicencie < prixMineur) {
      _errors[nonLicencieCat.id] = 'Doit être ≥ au prix Mineur (${prixMineur.toStringAsFixed(2)}€)';
    }
  }

  bool hasErrors() => _errors.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Prix par catégorie (€)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.info_outline,
              size: 18,
              color: Colors.grey.shade600,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.rule, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  const Text(
                    'Règles de tarification :',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '• Prix Licencié ≤ Prix Mineur\n'
                '• Prix Non licencié ≥ Prix Mineur',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...widget.categories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    category.label,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _controllers[category.id],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      hintText: '0.00',
                      suffixText: '€',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _errors.containsKey(category.id)
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      errorText: _errors[category.id],
                      errorStyle: const TextStyle(fontSize: 10),
                    ),
                    onChanged: (value) => _updatePrice(category.id, value),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obligatoire';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalide';
                      }
                      if (_errors.containsKey(category.id)) {
                        return _errors[category.id];
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
