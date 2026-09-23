import 'package:intl/intl.dart';

/// Clean date formatting utilities parsing ISO-8601 UTC to local readable strings
class DateFormatter {
  static String formatTimestamp(String isoUtc) {
    try {
      final dateTime = DateTime.parse(isoUtc).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0 && now.day == dateTime.day) {
        return 'Today, ${DateFormat.jm().format(dateTime)}';
      } else if (difference.inDays <= 1 && now.day - dateTime.day == 1) {
        return 'Yesterday, ${DateFormat.jm().format(dateTime)}';
      } else {
        return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
      }
    } catch (_) {
      return isoUtc;
    }
  }

  static String formatShortDate(String isoUtc) {
    try {
      final dateTime = DateTime.parse(isoUtc).toLocal();
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (_) {
      return isoUtc;
    }
  }
}
