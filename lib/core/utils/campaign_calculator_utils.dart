import 'package:flutter/material.dart';

class CampaignCalculatorUtils {
  /// Calculates dynamic budget for an ad campaign based on media type, duration, frequency, venue tier, and date ranges.
  static double calculateBudget({
    required DateTimeRange? dateRange,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required List<int> selectedDays,
    required int frequencyMinutes,
    String mediaType = 'image', // 'image', 'video', 'takeover'
    int displayDurationSeconds = 15,
    String venueTier = 'standard', // 'standard', 'premium_nightclub', 'all_venues'
    double minBudget = 100.0,
  }) {
    if (dateRange == null || selectedDays.isEmpty || frequencyMinutes <= 0) {
      return 0.0;
    }

    final totalCalendarDays = dateRange.end.difference(dateRange.start).inDays + 1;
    final activeDaysFraction = selectedDays.length / 7.0;
    final activeDaysCount = (totalCalendarDays * activeDaysFraction).round();
    final effectiveDays = activeDaysCount < 1 ? 1 : activeDaysCount;

    // 1. Base Daily Rate (ETB)
    double baseDailyRate = 100.0;
    if (venueTier == 'premium_nightclub') {
      baseDailyRate = 250.0;
    } else if (venueTier == 'all_venues') {
      baseDailyRate = 600.0;
    }

    // 2. Media Format Multiplier
    double mediaMultiplier = 1.0;
    if (mediaType == 'video') {
      mediaMultiplier = 1.5;
    } else if (mediaType == 'takeover') {
      mediaMultiplier = 2.0;
    }

    // 3. Display Spot Duration Multiplier
    double durationMultiplier = 1.0;
    if (displayDurationSeconds == 30) {
      durationMultiplier = 1.8;
    } else if (displayDurationSeconds >= 60) {
      durationMultiplier = 3.0;
    }

    // 4. Play Frequency Multiplier
    double frequencyMultiplier = 1.0;
    if (frequencyMinutes <= 5) {
      frequencyMultiplier = 4.0;
    } else if (frequencyMinutes <= 15) {
      frequencyMultiplier = 1.8;
    }

    // Calculate daily cost per active day
    final dailyRate = baseDailyRate * mediaMultiplier * durationMultiplier * frequencyMultiplier;
    final grossTotal = dailyRate * effectiveDays;

    // 5. Apply Bulk Duration Discount (Weekly & Monthly)
    double discountPercentage = 0.0;
    if (totalCalendarDays >= 30) {
      discountPercentage = 0.30; // 30% discount for monthly lock-in
    } else if (totalCalendarDays >= 7) {
      discountPercentage = 0.15; // 15% discount for weekly
    }

    final netTotal = grossTotal * (1.0 - discountPercentage);
    return netTotal < minBudget ? minBudget : netTotal;
  }
}

