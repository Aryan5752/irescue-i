// date_formatter.dart
import 'package:intl/intl.dart';

class DateFormatter {
  // Format date to yyyy-MM-dd
  static String toYMD(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Format date to dd/MM/yyyy
  static String toDMY(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Format date to Month dd, yyyy (e.g. January 1, 2023)
  static String toFullDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  // Format date to Month dd (e.g. January 1)
  static String toMonthDay(DateTime date) {
    return DateFormat('MMMM dd').format(date);
  }

  // Format date to time (e.g. 3:30 PM)
  static String toTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  // Format date to date and time (e.g. Jan 1, 2023 3:30 PM)
  static String toDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy h:mm a').format(date);
  }

  // Format to relative time (e.g. 5 minutes ago, 2 hours ago, Yesterday, etc.)
  static String toRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 2) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  // Format to relative short time (e.g. 5m, 2h, 1d, etc.)
  static String toShortRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y';
    }
  }

  // Format remaining time (e.g. "2d 5h remaining" or "30m remaining")
  static String toRemainingTime(DateTime endDate) {
    final now = DateTime.now();
    
    // If date is in the past
    if (endDate.isBefore(now)) {
      return 'Expired';
    }
    
    final difference = endDate.difference(now);
    
    if (difference.inDays > 0) {
      final hours = difference.inHours % 24;
      return '${difference.inDays}d ${hours}h remaining';
    } else if (difference.inHours > 0) {
      final minutes = difference.inMinutes % 60;
      return '${difference.inHours}h ${minutes}m remaining';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m remaining';
    } else {
      return '${difference.inSeconds}s remaining';
    }
  }

  // Get date range string (e.g. "Jan 1 - Jan 5, 2023" or "Jan 1 - Feb 5, 2023")
  static String getDateRange(DateTime startDate, DateTime endDate) {
    final isSameYear = startDate.year == endDate.year;
    final isSameMonth = startDate.month == endDate.month && isSameYear;
    
    if (isSameMonth) {
      // Jan 1 - 5, 2023
      return '${DateFormat('MMM d').format(startDate)} - ${DateFormat('d, yyyy').format(endDate)}';
    } else if (isSameYear) {
      // Jan 1 - Feb 5, 2023
      return '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}';
    } else {
      // Jan 1, 2023 - Feb 5, 2024
      return '${DateFormat('MMM d, yyyy').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}';
    }
  }

  // Parse string to DateTime
  static DateTime? parseString(String dateString, {String format = 'yyyy-MM-dd'}) {
    try {
      return DateFormat(format).parse(dateString);
    } catch (e) {
      return null;
    }
  }
}