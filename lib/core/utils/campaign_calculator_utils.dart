import 'package:flutter/material.dart';
import '../models/organization_model.dart';

class CampaignCalculatorUtils {
  /// Base daily rate in ETB dynamically resolved from organization rate card or business type
  static double getVenueDailyRate(dynamic target) {
    if (target is Organization) {
      return target.effectiveDailyRate;
    }
    if (target is String) {
      return Organization.getDefaultDailyRate(target);
    }
    return 150.0;
  }

  /// Dynamically computes the total price for a given package tier across all selected venues
  static double getDynamicPackagePrice({
    required String packageTier,
    required List<Organization> selectedOrgs,
  }) {
    if (selectedOrgs.isEmpty) {
      // Default baseline when no venue is selected yet
      if (packageTier == 'weekly') return 945.0;
      if (packageTier == 'monthly') return 3600.0;
      if (packageTier == 'quarterly') return 8775.0;
      return 1500.0;
    }

    double total = 0.0;
    for (final org in selectedOrgs) {
      if (packageTier == 'weekly') {
        total += org.effectiveWeeklyPrice;
      } else if (packageTier == 'monthly') {
        total += org.effectiveMonthlyPrice;
      } else if (packageTier == 'quarterly') {
        total += org.effectiveQuarterlyPrice;
      } else {
        total += org.effectiveDailyRate * 14;
      }
    }
    return total;
  }

  /// Calculates dynamic budget for an ad campaign based on media type, duration, frequency, selected venues, and date ranges.
  /// NOTE: Set to 1.0 ETB for live test payments.
  static double calculateBudget({
    required DateTimeRange? dateRange,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required List<int> selectedDays,
    required int frequencyMinutes,
    List<Organization> selectedOrgs = const [],
    String mediaType = 'image', // 'image', 'video', 'takeover'
    int displayDurationSeconds = 15,
    String venueTier = 'standard',
    double? minBudget,
  }) {
    if (dateRange == null || selectedDays.isEmpty || frequencyMinutes <= 0) {
      return 0.0;
    }

    // Fixed 1.0 ETB for live test payments
    return 1.0;
  }
}
