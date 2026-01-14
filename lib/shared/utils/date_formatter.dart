// lib/shared/utils/date_formatter.dart

class DateFormatter {
  static const List<String> _monthsFull = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
  ];

  static const List<String> _monthsShort = [
    'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
    'juil', 'août', 'sep', 'oct', 'nov', 'déc'
  ];

  /// Format: "13 janvier 2026"
  static String formatDate(DateTime date) {
    return '${date.day} ${_monthsShort[date.month - 1]} ${date.year}';
  }

  /// Format: "13 janvier 2026 à 14h30"
  static String formatDateTime(DateTime date) {
    return '${date.day} ${_monthsFull[date.month - 1]} ${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }

  /// Format: "14h30"
  static String formatTime(DateTime date) {
    return '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }
}
