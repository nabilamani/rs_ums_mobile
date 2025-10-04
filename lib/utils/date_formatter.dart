import 'package:intl/intl.dart';

class DateFormatter {
  // Format: 15 Januari 2024
  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Format: 15 Jan 2024
  static String formatDateShort(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Format: 15 Januari 2024, 14:30
  static String formatDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Format relatif: "2 jam yang lalu", "3 hari yang lalu"
  static String formatRelative(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 60) {
        return 'Baru saja';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} menit yang lalu';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari yang lalu';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks minggu yang lalu';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '$months bulan yang lalu';
      } else {
        final years = (difference.inDays / 365).floor();
        return '$years tahun yang lalu';
      }
    } catch (e) {
      return dateString;
    }
  }

  // Format: Senin, 15 Januari 2024
  static String formatDateWithDay(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Format jam: 14:30
  static String formatTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('HH:mm', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Check apakah tanggal hari ini
  static bool isToday(String? dateString) {
    if (dateString == null || dateString.isEmpty) return false;
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    } catch (e) {
      return false;
    }
  }

  // Check apakah tanggal kemarin
  static bool isYesterday(String? dateString) {
    if (dateString == null || dateString.isEmpty) return false;
    
    try {
      final date = DateTime.parse(dateString);
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      return date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day;
    } catch (e) {
      return false;
    }
  }
}

// Number formatter untuk views, likes, dll
class NumberFormatter {
  // Format: 1234 -> 1.2K, 1234567 -> 1.2M
  static String formatCompact(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
  }

  // Format dengan separator: 1234567 -> 1.234.567
  static String formatWithSeparator(int number) {
    return NumberFormat('#,###', 'id_ID').format(number);
  }
}