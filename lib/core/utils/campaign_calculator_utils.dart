import 'package:flutter/material.dart';

class CampaignCalculatorUtils {
  /// Calculates estimated budget for an ad campaign based on duration, frequency, and targeted days
  static double calculateBudget({
    required DateTimeRange? dateRange,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required List<int> selectedDays,
    required int frequencyMinutes,
    double ratePerImpression = 0.10,
    double minBudget = 5.0,
  }) {
    if (dateRange == null || selectedDays.isEmpty || frequencyMinutes <= 0) {
      return 0.0;
    }

    final totalDays = dateRange.end.difference(dateRange.start).inDays + 1;
    final activeDaysCount = selectedDays.length;

    final hours = (endTime.hour + endTime.minute / 60) - (startTime.hour + startTime.minute / 60);
    final playsPerDay = (hours * 60) / frequencyMinutes;
    final totalPlays = playsPerDay * totalDays * (activeDaysCount / 7);

    final calculated = totalPlays * ratePerImpression;
    return calculated < minBudget ? minBudget : calculated;
  }
}
