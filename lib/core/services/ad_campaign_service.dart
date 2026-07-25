import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/ad_campaign_model.dart';
import '../models/organization_model.dart';

class AdCampaignService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _campaignsCollection = 'ad_campaigns';
  static const String _organizationsCollection = 'organizations';

  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserEmail => _auth.currentUser?.email;

  /// Stream all campaigns for the currently logged-in advertiser
  Stream<List<AdCampaign>> streamMyCampaigns() {
    debugPrint('📡 AdCampaignService.streamMyCampaigns() called');
    final userId = currentUserId;
    if (userId == null) {
      debugPrint(
          '⚠️ AdCampaignService: User not authenticated, returning empty stream');
      return Stream.value([]);
    }

    debugPrint('🔍 AdCampaignService: Fetching campaigns for user: $userId');
    return _firestore
        .collection(_campaignsCollection)
        .where('advertiserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      debugPrint(
          '📦 AdCampaignService: Received ${snapshot.docs.length} campaigns');
      return snapshot.docs.map((doc) => AdCampaign.fromFirestore(doc)).toList();
    });
  }

  /// Stream all active organizations available for targeting
  Stream<List<Organization>> streamOrganizations() {
    debugPrint('📡 AdCampaignService.streamOrganizations() called');
    return _firestore
        .collection(_organizationsCollection)
        .snapshots()
        .map((snapshot) {
      debugPrint(
          '📦 AdCampaignService: Received ${snapshot.docs.length} total organization docs');
      final orgs = snapshot.docs
          .map((doc) => Organization.fromFirestore(doc))
          .where((org) => org.isActive)
          .toList();
      debugPrint('✅ AdCampaignService: Mapped ${orgs.length} active organizations');
      return orgs;
    });
  }

  /// Create a new campaign
  Future<void> createCampaign({
    required String title,
    required String caption,
    required String organizationId,
    required String organizationName,
    required String mediaUrl,
    required String mediaType,
    required DateTime startDate,
    required DateTime endDate,
    required List<int> daysOfWeek,
    required String startTime,
    required String endTime,
    required int displayDurationSeconds,
    required int frequencyMinutes,
    required double budget,
  }) async {
    debugPrint('🚀 AdCampaignService.createCampaign() called');
    debugPrint('📝 Title: $title, Org: $organizationName, Budget: $budget');
    final userId = currentUserId;
    if (userId == null) {
      debugPrint(
          '❌ AdCampaignService: User not authenticated, throwing exception');
      throw Exception('User must be logged in to create a campaign');
    }

    final docRef = _firestore.collection(_campaignsCollection).doc();
    final campaign = AdCampaign(
      id: docRef.id,
      advertiserId: userId,
      organizationId: organizationId,
      organizationName: organizationName,
      title: title,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      caption: caption,
      startDate: startDate,
      endDate: endDate,
      daysOfWeek: daysOfWeek,
      startTime: startTime,
      endTime: endTime,
      displayDurationSeconds: displayDurationSeconds,
      frequencyMinutes: frequencyMinutes,
      status: CampaignStatus.pendingApproval,
      budget: budget,
      createdAt: DateTime.now(),
    );

    debugPrint(
        '💾 AdCampaignService: Saving campaign ${docRef.id} to Firestore');
    await docRef.set(campaign.toJson());
    debugPrint(
        '✅ AdCampaignService: Campaign ${docRef.id} created successfully');
  }

  /// Upload ad creative file to Firebase Storage
  Future<String> uploadAdMedia({
    required String fileName,
    required Uint8List fileBytes,
    required String mimeType,
  }) async {
    debugPrint('📤 AdCampaignService.uploadAdMedia() called');
    debugPrint(
        '📄 File: $fileName, Type: $mimeType, Size: ${fileBytes.length} bytes');
    final userId = currentUserId;
    if (userId == null) {
      debugPrint(
          '❌ AdCampaignService: User not authenticated, throwing exception');
      throw Exception('User must be logged in to upload media');
    }

    final ref = _storage.ref().child(
        'advertiser_creatives/$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName');
    debugPrint('📁 AdCampaignService: Uploading to ${ref.fullPath}');

    final metadata = SettableMetadata(contentType: mimeType);
    final uploadTask = ref.putData(fileBytes, metadata);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    debugPrint('✅ AdCampaignService: Media uploaded, URL: $downloadUrl');
    return downloadUrl;
  }

  /// Fetch dashboard metrics
  Future<Map<String, dynamic>> fetchMetrics() async {
    debugPrint('📊 AdCampaignService.fetchMetrics() called');
    final userId = currentUserId;
    if (userId == null) {
      debugPrint(
          '⚠️ AdCampaignService: User not authenticated, returning zeros');
      return {
        'totalCampaigns': 0,
        'activeCampaigns': 0,
        'budgetSpent': 0.0,
        'totalImpressions': 0,
      };
    }

    debugPrint('🔍 AdCampaignService: Fetching metrics for user: $userId');
    final query = await _firestore
        .collection(_campaignsCollection)
        .where('advertiserId', isEqualTo: userId)
        .get();

    final campaigns =
        query.docs.map((doc) => AdCampaign.fromFirestore(doc)).toList();
    debugPrint(
        '📦 AdCampaignService: Found ${campaigns.length} campaigns for metrics');

    int totalCampaigns = campaigns.length;
    int activeCampaigns =
        campaigns.where((c) => c.status == CampaignStatus.active).length;
    double budgetSpent = campaigns.fold(0.0, (sum, c) => sum + c.budget);
    int totalImpressions =
        campaigns.fold(0, (sum, c) => sum + c.impressionCount);

    debugPrint(
        '✅ AdCampaignService: Metrics — total: $totalCampaigns, active: $activeCampaigns, budget: $budgetSpent, impressions: $totalImpressions');
    return {
      'totalCampaigns': totalCampaigns,
      'activeCampaigns': activeCampaigns,
      'budgetSpent': budgetSpent,
      'totalImpressions': totalImpressions,
    };
  }
}
