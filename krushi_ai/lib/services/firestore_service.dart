import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:krushi_ai/models/history_model.dart';

/// FirestoreService - Firebase Firestore Database Service
///
/// Purpose: Handles all Firestore database operations
/// Implements: CRUD operations for model history
/// Pattern: Singleton pattern for single instance across app

class FirestoreService {
  // Singleton instance
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection names
  static const String _historyCollection = 'model_history';
  static const String _usersCollection = 'users';

  /// Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Get current user email
  String? get _currentUserEmail => _auth.currentUser?.email;

  // ==================== HISTORY OPERATIONS ====================

  /// Save model output to history
  ///
  /// Parameters:
  /// - modelType: Type of model (e.g., 'crop_disease', 'soil_analysis')
  /// - input: User's input/query
  /// - output: Model's prediction/response
  /// - metadata: Additional data (optional)
  ///
  /// Returns: Document ID of saved history
  Future<String> saveHistory({
    required String modelType,
    required String input,
    required String output,
    Map<String, dynamic>? metadata,
  }) async {
    print('💾 [FIRESTORE] Saving history to Firestore...');
    
    try {
      if (_currentUserId == null) {
        throw 'User not authenticated';
      }

      final historyData = HistoryModel(
        id: '', // Will be set by Firestore
        userId: _currentUserId!,
        userEmail: _currentUserEmail ?? '',
        modelType: modelType,
        input: input,
        output: output,
        metadata: metadata,
        timestamp: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(_historyCollection)
          .add(historyData.toMap());

      print('✅ [FIRESTORE] History saved with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ [FIRESTORE] Error saving history: $e');
      throw 'Failed to save history: $e';
    }
  }

  /// Get all history for current user
  ///
  /// Parameters:
  /// - limit: Maximum number of records to fetch (default: 50)
  /// - modelType: Filter by model type (optional)
  ///
  /// Returns: List of HistoryModel
  Future<List<HistoryModel>> getUserHistory({
    int limit = 50,
    String? modelType,
  }) async {
    print('📖 [FIRESTORE] Fetching user history...');
    
    try {
      if (_currentUserId == null) {
        throw 'User not authenticated';
      }

      Query query = _firestore
          .collection(_historyCollection)
          .where('userId', isEqualTo: _currentUserId)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      // Add modelType filter if provided
      if (modelType != null && modelType.isNotEmpty) {
        query = query.where('modelType', isEqualTo: modelType);
      }

      final querySnapshot = await query.get();

      final historyList = querySnapshot.docs
          .map((doc) => HistoryModel.fromFirestore(doc))
          .toList();

      print('✅ [FIRESTORE] Fetched ${historyList.length} history records');
      return historyList;
    } catch (e) {
      print('❌ [FIRESTORE] Error fetching history: $e');
      throw 'Failed to fetch history: $e';
    }
  }

  /// Get history by model type with real-time updates
  ///
  /// Returns: Stream of history list
  Stream<List<HistoryModel>> getHistoryStream({
    int limit = 50,
    String? modelType,
  }) {
    print('📡 [FIRESTORE] Creating history stream...');
    
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    Query query = _firestore
        .collection(_historyCollection)
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (modelType != null && modelType.isNotEmpty) {
      query = query.where('modelType', isEqualTo: modelType);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => HistoryModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get single history record by ID
  Future<HistoryModel?> getHistoryById(String historyId) async {
    print('🔍 [FIRESTORE] Fetching history by ID: $historyId');
    
    try {
      final doc = await _firestore
          .collection(_historyCollection)
          .doc(historyId)
          .get();

      if (!doc.exists) {
        print('⚠️ [FIRESTORE] History not found');
        return null;
      }

      return HistoryModel.fromFirestore(doc);
    } catch (e) {
      print('❌ [FIRESTORE] Error fetching history by ID: $e');
      throw 'Failed to fetch history: $e';
    }
  }

  /// Update history record
  Future<void> updateHistory({
    required String historyId,
    String? input,
    String? output,
    Map<String, dynamic>? metadata,
  }) async {
    print('✏️ [FIRESTORE] Updating history: $historyId');
    
    try {
      final updateData = <String, dynamic>{};
      
      if (input != null) updateData['input'] = input;
      if (output != null) updateData['output'] = output;
      if (metadata != null) updateData['metadata'] = metadata;
      
      if (updateData.isEmpty) {
        print('⚠️ [FIRESTORE] No fields to update');
        return;
      }

      await _firestore
          .collection(_historyCollection)
          .doc(historyId)
          .update(updateData);

      print('✅ [FIRESTORE] History updated successfully');
    } catch (e) {
      print('❌ [FIRESTORE] Error updating history: $e');
      throw 'Failed to update history: $e';
    }
  }

  /// Delete history record
  Future<void> deleteHistory(String historyId) async {
    print('🗑️ [FIRESTORE] Deleting history: $historyId');
    
    try {
      await _firestore
          .collection(_historyCollection)
          .doc(historyId)
          .delete();

      print('✅ [FIRESTORE] History deleted successfully');
    } catch (e) {
      print('❌ [FIRESTORE] Error deleting history: $e');
      throw 'Failed to delete history: $e';
    }
  }

  /// Delete all history for current user
  Future<void> clearUserHistory() async {
    print('🗑️ [FIRESTORE] Clearing all user history...');
    
    try {
      if (_currentUserId == null) {
        throw 'User not authenticated';
      }

      final querySnapshot = await _firestore
          .collection(_historyCollection)
          .where('userId', isEqualTo: _currentUserId)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('✅ [FIRESTORE] All history cleared (${querySnapshot.docs.length} records)');
    } catch (e) {
      print('❌ [FIRESTORE] Error clearing history: $e');
      throw 'Failed to clear history: $e';
    }
  }

  /// Get history count for current user
  Future<int> getHistoryCount({String? modelType}) async {
    print('📊 [FIRESTORE] Getting history count...');
    
    try {
      if (_currentUserId == null) {
        return 0;
      }

      Query query = _firestore
          .collection(_historyCollection)
          .where('userId', isEqualTo: _currentUserId);

      if (modelType != null && modelType.isNotEmpty) {
        query = query.where('modelType', isEqualTo: modelType);
      }

      final snapshot = await query.count().get();
      final count = snapshot.count ?? 0;

      print('✅ [FIRESTORE] History count: $count');
      return count;
    } catch (e) {
      print('❌ [FIRESTORE] Error getting count: $e');
      return 0;
    }
  }

  // ==================== USER PROFILE OPERATIONS ====================

  /// Save/Update user profile
  Future<void> saveUserProfile({
    required String fullName,
    String? phoneNumber,
    String? location,
    Map<String, dynamic>? additionalData,
  }) async {
    print('💾 [FIRESTORE] Saving user profile...');
    
    try {
      if (_currentUserId == null) {
        throw 'User not authenticated';
      }

      final userData = {
        'fullName': fullName,
        'email': _currentUserEmail,
        'phoneNumber': phoneNumber,
        'location': location,
        'updatedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      };

      await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .set(userData, SetOptions(merge: true));

      print('✅ [FIRESTORE] User profile saved');
    } catch (e) {
      print('❌ [FIRESTORE] Error saving profile: $e');
      throw 'Failed to save profile: $e';
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    print('📖 [FIRESTORE] Fetching user profile...');
    
    try {
      if (_currentUserId == null) {
        return null;
      }

      final doc = await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .get();

      if (!doc.exists) {
        print('⚠️ [FIRESTORE] Profile not found');
        return null;
      }

      return doc.data();
    } catch (e) {
      print('❌ [FIRESTORE] Error fetching profile: $e');
      return null;
    }
  }

  // ==================== STATISTICS ====================

  /// Get usage statistics
  Future<Map<String, dynamic>> getUsageStats() async {
    print('📊 [FIRESTORE] Calculating usage statistics...');
    
    try {
      if (_currentUserId == null) {
        return {};
      }

      final snapshot = await _firestore
          .collection(_historyCollection)
          .where('userId', isEqualTo: _currentUserId)
          .get();

      final totalRecords = snapshot.docs.length;
      
      // Count by model type
      final modelTypeCounts = <String, int>{};
      for (var doc in snapshot.docs) {
        final modelType = doc.data()['modelType'] as String? ?? 'unknown';
        modelTypeCounts[modelType] = (modelTypeCounts[modelType] ?? 0) + 1;
      }

      print('✅ [FIRESTORE] Stats calculated: $totalRecords records');
      
      return {
        'totalRecords': totalRecords,
        'modelTypeCounts': modelTypeCounts,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ [FIRESTORE] Error calculating stats: $e');
      return {};
    }
  }
}
