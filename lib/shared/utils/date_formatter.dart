// lib/shared/utils/date_formatter.dart

/// Lightweight French date formatter without intl package dependency [web:341][web:348].
///
/// Provides three common date/time formats in French locale using static methods.
/// Alternative to DateFormat from intl package when only French formatting needed
/// [web:341][web:346][web:348].
///
/// **Formats:**
/// - formatDate: "13 jan 2026" (short month, no time)
/// - formatDateTime: "13 janvier 2026 à 14h30" (full month with time)
/// - formatTime: "14h30" (time only)
///
/// **Why Not intl?**
/// - Lighter bundle size (no package dependency)
/// - Simpler for single-locale apps
/// - Full control over format strings
///
/// **Trade-offs:**
/// - French-only (not multi-locale)
/// - Manual month arrays instead of ICU data
/// - No timezone support
///
/// Example:
/// ```dart
/// final now = DateTime.now();
/// 
/// // "13 jan 2026"
/// final date = DateFormatter.formatDate(now);
/// 
/// // "13 janvier 2026 à 14h30"
/// final dateTime = DateFormatter.formatDateTime(now);
/// 
/// // "14h30"
/// final time = DateFormatter.formatTime(now);
/// ```
class DateFormatter {
  static const List<String> _monthsFull = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre'
  ];

  static const List<String> _monthsShort = [
    'jan',
    'fév',
    'mar',
    'avr',
    'mai',
    'juin',
    'juil',
    'août',
    'sep',
    'oct',
    'nov',
    'déc'
  ];

  /// Formats date with short month name: "13 jan 2026".
  static String formatDate(DateTime date) {
    return '${date.day} ${_monthsShort[date.month - 1]} ${date.year}';
  }

  /// Formats date with full month and time: "13 janvier 2026 à 14h30".
  static String formatDateTime(DateTime date) {
    return '${date.day} ${_monthsFull[date.month - 1]} ${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }

  /// Formats time only: "14h30".
  static String formatTime(DateTime date) {
    return '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }
}
