// lib/core/presentation/widgets/common_loading_view.dart
import 'package:flutter/material.dart';

class CommonLoadingView extends StatelessWidget {
  final String? message;

  const CommonLoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: theme.textTheme.bodyLarge),
          ],
        ],
      ),
    );
  }
}
