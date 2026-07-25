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
    return Organization(
      id: doc.id,
      name: data['name'] ?? '',
      businessType: data['businessType'] ?? 'nightclub',
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      locationName: data['locationName'] as String?,
      logoUrl: data['logoUrl'] as String?,
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
