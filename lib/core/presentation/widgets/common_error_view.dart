// lib/core/presentation/widgets/common_error_view.dart
import 'package:flutter/material.dart';

/// A reusable widget that displays an error state view with an error icon,
/// error message, and optional retry button.
///
/// This widget provides a consistent way to display error states throughout
/// the application when data loading fails or when exceptions occur [web:17].
/// It follows Flutter best practices for error handling by providing visual
/// feedback to users and offering a recovery mechanism through the retry callback [web:16].
///
/// The widget is typically used in conjunction with state management patterns
/// (such as BLoC or Cubit) to display error states when API calls fail or
/// when data fetching encounters issues [web:25].
///
/// Example usage:
/// ```dart
/// CommonErrorView(
///   error: 'Failed to load data from server',
///   onRetry: () {
///     // Trigger data reload
///     context.read<DataBloc>().add(LoadDataEvent());
///   },
/// )
/// ```
class CommonErrorView extends StatelessWidget {
  /// The error message to display to the user.
  ///
  /// This should be a user-friendly message explaining what went wrong,
  /// such as "Network connection failed" or "Unable to load data".
  /// The message is displayed below the error icon and title.
  final String error;

  /// An optional callback function triggered when the user taps the retry button.
  ///
  /// [VoidCallback] is a function type that takes no parameters and returns no value [web:21].
  /// When provided, a retry button with a refresh icon will be displayed below
  /// the error message, allowing users to attempt to recover from the error [web:16].
  /// If null, no retry button will be shown.
  final VoidCallback? onRetry;

  /// Creates a [CommonErrorView] widget.
  ///
  /// The [error] parameter is required to ensure users always receive
  /// information about what went wrong [web:17].
  const CommonErrorView({
    super.key,
    required this.error,
    this.onRetry,
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
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('RÉESSAYER'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
