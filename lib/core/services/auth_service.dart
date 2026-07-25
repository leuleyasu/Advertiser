import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _adminUsersCollection = 'admin_users';

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Stream auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Authenticate user
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) throw Exception('Authentication failed');

      // 2. Verify user has the advertiser role in admin_users
      final userDoc = await _firestore.collection(_adminUsersCollection).doc(uid).get();
      if (!userDoc.exists) {
        // If not exist, we sign out and error out
        await _auth.signOut();
        throw Exception('Access Denied: No platform profile found for this account.');
      }

      final data = userDoc.data();
      final role = data?['role'] as String?;
      if (role != 'advertiser' && role != 'superAdmin') {
        await _auth.signOut();
        throw Exception('Access Denied: Only advertisers can sign in here.');
      }

      return userCredential;
    } catch (e) {
      debugPrint('❌ AuthService: Error signing in: $e');
      rethrow;
    }
  }

  /// Register a new advertiser account
  Future<UserCredential> registerAdvertiser({
    required String email,
    required String password,
    required String companyName,
    required String contactName,
  }) async {
    try {
      // 1. Create firebase auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) throw Exception('Failed to register user');

      // 2. Set display name in auth profile
      await userCredential.user?.updateDisplayName(contactName);

      // 3. Create document in admin_users
      await _firestore.collection(_adminUsersCollection).doc(uid).set({
        'uid': uid,
        'email': email.trim().toLowerCase(),
        'displayName': contactName,
        'companyName': companyName.trim(),
        'role': 'advertiser',
        'createdAt': FieldValue.serverTimestamp(),
        'permissions': ['create_campaign', 'view_metrics'],
      });

      return userCredential;
    } catch (e) {
      debugPrint('❌ AuthService: Error registering advertiser: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
