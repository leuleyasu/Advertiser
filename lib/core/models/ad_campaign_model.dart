import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum CampaignStatus {
  pendingApproval,
  approved,
  active,
  completed,
  rejected
}

class AdCampaign extends Equatable {
  final String id;
  final String advertiserId;
  final String organizationId;
  final String? organizationName;
  final String title;
  final String mediaUrl;
  final String mediaType; // 'image' or 'video'
  final String caption;
  final DateTime startDate;
  final DateTime endDate;
  final List<int> daysOfWeek; // 1 = Mon, 7 = Sun
  final String startTime; // "HH:MM"
  final String endTime; // "HH:MM"
  final int displayDurationSeconds;
  final int frequencyMinutes;
  final CampaignStatus status;
  final double budget;
  final int impressionCount;
  final DateTime createdAt;
  final String? rejectionReason;

  const AdCampaign({
    required this.id,
    required this.advertiserId,
    required this.organizationId,
    this.organizationName,
    required this.title,
    required this.mediaUrl,
    required this.mediaType,
    required this.caption,
    required this.startDate,
    required this.endDate,
    required this.daysOfWeek,
    required this.startTime,
    required this.endTime,
    required this.displayDurationSeconds,
    required this.frequencyMinutes,
    required this.status,
    required this.budget,
    this.impressionCount = 0,
    required this.createdAt,
    this.rejectionReason,
  });

  AdCampaign copyWith({
    String? id,
    String? advertiserId,
    String? organizationId,
    String? organizationName,
    String? title,
    String? mediaUrl,
    String? mediaType,
    String? caption,
    DateTime? startDate,
    DateTime? endDate,
    List<int>? daysOfWeek,
    String? startTime,
    String? endTime,
    int? displayDurationSeconds,
    int? frequencyMinutes,
    CampaignStatus? status,
    double? budget,
    int? impressionCount,
    DateTime? createdAt,
    String? rejectionReason,
  }) {
    return AdCampaign(
      id: id ?? this.id,
      advertiserId: advertiserId ?? this.advertiserId,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      title: title ?? this.title,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      caption: caption ?? this.caption,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      displayDurationSeconds: displayDurationSeconds ?? this.displayDurationSeconds,
      frequencyMinutes: frequencyMinutes ?? this.frequencyMinutes,
      status: status ?? this.status,
      budget: budget ?? this.budget,
      impressionCount: impressionCount ?? this.impressionCount,
      createdAt: createdAt ?? this.createdAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  factory AdCampaign.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    CampaignStatus status = CampaignStatus.pendingApproval;
    final statusStr = data['status'] as String?;
    if (statusStr != null) {
      status = CampaignStatus.values.firstWhere(
        (e) => e.name == statusStr || _camelToSnake(e.name) == statusStr,
        orElse: () => CampaignStatus.pendingApproval,
      );
    }

    return AdCampaign(
      id: doc.id,
      advertiserId: data['advertiserId'] ?? '',
      organizationId: data['organizationId'] ?? '',
      organizationName: data['organizationName'],
      title: data['title'] ?? '',
      mediaUrl: data['mediaUrl'] ?? '',
      mediaType: data['mediaType'] ?? 'image',
      caption: data['caption'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      daysOfWeek: List<int>.from(data['daysOfWeek'] ?? []),
      startTime: data['startTime'] ?? '00:00',
      endTime: data['endTime'] ?? '23:59',
      displayDurationSeconds: data['displayDurationSeconds'] ?? 15,
      frequencyMinutes: data['frequencyMinutes'] ?? 10,
      status: status,
      budget: (data['budget'] ?? 0.0).toDouble(),
      impressionCount: data['impressionCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rejectionReason: data['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'advertiserId': advertiserId,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'title': title,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'caption': caption,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'daysOfWeek': daysOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'displayDurationSeconds': displayDurationSeconds,
      'frequencyMinutes': frequencyMinutes,
      'status': status.name,
      'budget': budget,
      'impressionCount': impressionCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'rejectionReason': rejectionReason,
    };
  }

  static String _camelToSnake(String str) {
    return str.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }

  String get statusText {
    switch (status) {
      case CampaignStatus.pendingApproval:
        return 'Pending Approval';
      case CampaignStatus.approved:
        return 'Approved';
      case CampaignStatus.active:
        return 'Active';
      case CampaignStatus.completed:
        return 'Completed';
      case CampaignStatus.rejected:
        return 'Rejected';
    }
  }

  @override
  List<Object?> get props => [
        id,
        advertiserId,
        organizationId,
        organizationName,
        title,
        mediaUrl,
        mediaType,
        caption,
        startDate,
        endDate,
        daysOfWeek,
        startTime,
        endTime,
        displayDurationSeconds,
        frequencyMinutes,
        status,
        budget,
        impressionCount,
        createdAt,
        rejectionReason,
      ];
}
