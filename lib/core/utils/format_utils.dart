import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormatUtils {
  /// Formats TimeOfDay into HH:mm (24-hour padded string)
  static String formatTimeOfDay24(TimeOfDay time) {
    final hourStr = time.hour.toString().padLeft(2, '0');
    final minuteStr = time.minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  /// Formats double as currency string in ETB, e.g. 12.50 ETB
  static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} ETB';
  }

  /// Formats DateRange into a readable string
  static String formatDateRange(DateTimeRange? range, {String defaultText = 'Select Date Range'}) {
    if (range == null) return defaultText;
    final formatter = DateFormat('MMM dd, yyyy');
    return '${formatter.format(range.start)} - ${formatter.format(range.end)}';
  }

  /// Formats file size in bytes to MB string
  static String formatFileSizeMB(int sizeInBytes) {
    final sizeMb = sizeInBytes / (1024 * 1024);
    return '${sizeMb.toStringAsFixed(2)} MB';
  }
}
