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

  const Organization({
    required this.id,
    required this.name,
    required this.businessType,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.locationName,
    this.logoUrl,
  });

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
      ];
}
