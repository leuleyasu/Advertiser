import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Organization extends Equatable {
  final String id;
  final String name;
  final String businessType;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? locationName;
  final String? logoUrl;
  final String? description;
  final int? screenCount;
  final String? audienceDemographic;
  final String? footTrafficEstimate;
  final double? advertisementPrice;
  final String? adStartTime;
  final String? adEndTime;
  final double? weeklyPrice;
  final double? monthlyPrice;
  final double? quarterlyPrice;
  final int? adFrequencyMinutes;

  const Organization({
    required this.id,
    required this.name,
    required this.businessType,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.locationName,
    this.logoUrl,
    this.description,
    this.screenCount,
    this.audienceDemographic,
    this.footTrafficEstimate,
    this.advertisementPrice,
    this.adStartTime,
    this.adEndTime,
    this.weeklyPrice,
    this.monthlyPrice,
    this.quarterlyPrice,
    this.adFrequencyMinutes,
  });

  /// Smart default base daily rate according to business type
  static double getDefaultDailyRate(String businessType) {
    final lower = businessType.toLowerCase();
    if (lower == 'nightclub') return 250.0;
    if (lower == 'cafe' || lower == 'gym') return 100.0;
    return 150.0;
  }

  /// Effective daily rate (custom Firestore price with smart fallback)
  double get effectiveDailyRate =>
      advertisementPrice ?? getDefaultDailyRate(businessType);

  /// Effective description with fallback according to venue type
  String get effectiveDescription {
    if (description != null && description!.trim().isNotEmpty) {
      return description!.trim();
    }
    final lower = businessType.toLowerCase();
    if (lower == 'nightclub') {
      return 'Premier nightlife venue with high-energy ambience, VIP seating, and multiple high-definition commercial display screens reaching music lovers, partygoers, and weekend crowds.';
    }
    if (lower == 'cafe') {
      return 'Popular urban cafe and social hub with continuous daytime foot traffic, ideal for reaching students, remote workers, and morning coffee patrons.';
    }
    if (lower == 'gym') {
      return 'High-traffic fitness center and wellness facility with strategically mounted screens seen by active, health-conscious urban professionals.';
    }
    return 'Modern commercial establishment featuring prominent digital screens with high daily customer dwell times and captive audience attention.';
  }

  /// Effective screen count
  int get effectiveScreenCount {
    if (screenCount != null && screenCount! > 0) return screenCount!;
    final lower = businessType.toLowerCase();
    if (lower == 'nightclub') return 4;
    if (lower == 'gym') return 3;
    return 2;
  }

  /// Effective target audience demographic
  String get effectiveAudienceDemographic {
    if (audienceDemographic != null && audienceDemographic!.trim().isNotEmpty) {
      return audienceDemographic!.trim();
    }
    final lower = businessType.toLowerCase();
    if (lower == 'nightclub') return '21–38 Urban Trendsetters & Partygoers';
    if (lower == 'cafe') return '18–45 Students & Young Professionals';
    if (lower == 'gym') return '20–50 Health & Fitness Enthusiasts';
    return '21–45 General Urban Consumers';
  }

  /// Effective foot traffic estimate
  String get effectiveFootTraffic {
    if (footTrafficEstimate != null && footTrafficEstimate!.trim().isNotEmpty) {
      return footTrafficEstimate!.trim();
    }
    final lower = businessType.toLowerCase();
    if (lower == 'nightclub') return '600+ Daily Nightlife Visitors';
    if (lower == 'cafe') return '450+ Daily Coffee & Meal Guests';
    if (lower == 'gym') return '350+ Daily Active Members';
    return '400+ Daily Visitors';
  }

  /// Effective start hour for broadcast
  String get effectiveStartTime {
    if (adStartTime != null && adStartTime!.trim().isNotEmpty) {
      return adStartTime!.trim();
    }
    final lower = businessType.toLowerCase();
    if (lower == 'nightclub') return '20:00';
    if (lower == 'cafe' || lower == 'gym') return '08:00';
    return '12:00';
  }

  /// Effective end hour for broadcast
  String get effectiveEndTime {
    if (adEndTime != null && adEndTime!.trim().isNotEmpty) {
      return adEndTime!.trim();
    }
    final lower = businessType.toLowerCase();
    if (lower == 'nightclub') return '03:00';
    if (lower == 'cafe' || lower == 'gym') return '21:00';
    return '23:00';
  }

  /// Effective 7-Day Starter Package Price (10% built-in discount)
  double get effectiveWeeklyPrice =>
      weeklyPrice ?? (effectiveDailyRate * 7 * 0.90);

  /// Effective 30-Day Pro Package Price (20% built-in discount)
  double get effectiveMonthlyPrice =>
      monthlyPrice ?? (effectiveDailyRate * 30 * 0.80);

  /// Effective 90-Day Master Package Price (35% built-in discount)
  double get effectiveQuarterlyPrice =>
      quarterlyPrice ?? (effectiveDailyRate * 90 * 0.65);

  /// Effective play frequency in minutes
  int get effectiveFrequencyMinutes => adFrequencyMinutes ?? 15;

  factory Organization.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? <String, dynamic>{};

    final resolvedName = (data['organizationName'] as String?)?.trim().isNotEmpty == true
        ? (data['organizationName'] as String).trim()
        : (data['houseName'] as String?)?.trim().isNotEmpty == true
            ? (data['houseName'] as String).trim()
            : (data['name'] as String?)?.trim().isNotEmpty == true
                ? (data['name'] as String).trim()
                : 'Unnamed Organization';

    final resolvedBusinessType = (data['businessType'] as String?) ??
        (data['musicType'] as String?) ??
        'nightclub';

    final adPrice = (data['advertisementPrice'] as num?)?.toDouble() ??
        (data['adPrice'] as num?)?.toDouble();

    final resolvedDesc = (data['description'] as String?) ??
        (data['slogan'] as String?) ??
        (data['about'] as String?);

    return Organization(
      id: doc.id,
      name: resolvedName,
      businessType: resolvedBusinessType,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: data['createdAt'] != null && data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null && data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      locationName: data['locationName'] as String?,
      logoUrl: (data['logoUrl'] as String?) ?? (data['bannerImageUrl'] as String?),
      description: resolvedDesc,
      screenCount: (data['screenCount'] as num?)?.toInt(),
      audienceDemographic: data['audienceDemographic'] as String?,
      footTrafficEstimate: data['footTrafficEstimate'] as String?,
      advertisementPrice: adPrice,
      adStartTime: data['adStartTime'] as String?,
      adEndTime: data['adEndTime'] as String?,
      weeklyPrice: (data['weeklyPrice'] as num?)?.toDouble(),
      monthlyPrice: (data['monthlyPrice'] as num?)?.toDouble(),
      quarterlyPrice: (data['quarterlyPrice'] as num?)?.toDouble(),
      adFrequencyMinutes: (data['adFrequencyMinutes'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'businessType': businessType,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'locationName': locationName,
      'logoUrl': logoUrl,
      'description': description,
      'screenCount': screenCount,
      'audienceDemographic': audienceDemographic,
      'footTrafficEstimate': footTrafficEstimate,
      'advertisementPrice': advertisementPrice,
      'adStartTime': adStartTime,
      'adEndTime': adEndTime,
      'weeklyPrice': weeklyPrice,
      'monthlyPrice': monthlyPrice,
      'quarterlyPrice': quarterlyPrice,
      'adFrequencyMinutes': adFrequencyMinutes,
    };
  }

  Organization copyWith({
    String? id,
    String? name,
    String? businessType,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? locationName,
    String? logoUrl,
    String? description,
    int? screenCount,
    String? audienceDemographic,
    String? footTrafficEstimate,
    double? advertisementPrice,
    String? adStartTime,
    String? adEndTime,
    double? weeklyPrice,
    double? monthlyPrice,
    double? quarterlyPrice,
    int? adFrequencyMinutes,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      businessType: businessType ?? this.businessType,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      locationName: locationName ?? this.locationName,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      screenCount: screenCount ?? this.screenCount,
      audienceDemographic: audienceDemographic ?? this.audienceDemographic,
      footTrafficEstimate: footTrafficEstimate ?? this.footTrafficEstimate,
      advertisementPrice: advertisementPrice ?? this.advertisementPrice,
      adStartTime: adStartTime ?? this.adStartTime,
      adEndTime: adEndTime ?? this.adEndTime,
      weeklyPrice: weeklyPrice ?? this.weeklyPrice,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      quarterlyPrice: quarterlyPrice ?? this.quarterlyPrice,
      adFrequencyMinutes: adFrequencyMinutes ?? this.adFrequencyMinutes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        businessType,
        isActive,
        createdAt,
        updatedAt,
        locationName,
        logoUrl,
        description,
        screenCount,
        audienceDemographic,
        footTrafficEstimate,
        advertisementPrice,
        adStartTime,
        adEndTime,
        weeklyPrice,
        monthlyPrice,
        quarterlyPrice,
        adFrequencyMinutes,
      ];
}
