import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/logger_service.dart';

/// Central Firestore service for all database operations.
/// 
/// Provides CRUD operations for users, visitors, flats, guards, and guard checks.
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get visitorsCollection => _firestore.collection('visitors');
  CollectionReference get flatsCollection => _firestore.collection('flats');
  CollectionReference get guardsCollection => _firestore.collection('guards');
  CollectionReference get guardChecksCollection => _firestore.collection('guardChecks');
  CollectionReference get societiesCollection => _firestore.collection('societies');

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // ==================== USER OPERATIONS ====================

  /// Create or update user profile
  Future<void> saveUserProfile({
    required String name,
    required String email,
    required String role,
    String? phone,
    String? flatId,
    String? societyId,
    bool isVerified = false,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    await usersCollection.doc(userId).set({
      'userId': userId,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'flatId': flatId,
      'societyId': societyId,
      'isVerified': isVerified,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    LoggerService().info('User profile saved: $userId');
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile([String? userId]) async {
    final uid = userId ?? currentUserId;
    if (uid == null) return null;

    final doc = await usersCollection.doc(uid).get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }

  /// Update user profile fields
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    updates['updatedAt'] = FieldValue.serverTimestamp();
    await usersCollection.doc(userId).update(updates);
  }

  // ==================== VISITOR OPERATIONS ====================

  /// Add a new visitor
  Future<String> addVisitor({
    required String name,
    required String flatId,
    required String purpose,
    String? photoUrl,
    String? vehicleNumber,
    String? vehicleType,
    String? societyId,
    String status = 'pending',
  }) async {
    final doc = await visitorsCollection.add({
      'name': name,
      'flatId': flatId,
      'societyId': societyId,
      'purpose': purpose,
      'photoUrl': photoUrl,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'status': status,
      'arrivalTime': FieldValue.serverTimestamp(),
      'exitTime': null,
      'createdBy': currentUserId,
    });

    LoggerService().info('Visitor added: ${doc.id}');
    return doc.id;
  }

  /// Get visitors stream (real-time updates)
  Stream<QuerySnapshot> getVisitorsStream({String? flatId, String? societyId, String? status}) {
    Query query = visitorsCollection.orderBy('arrivalTime', descending: true);
    
    if (flatId != null) {
      query = query.where('flatId', isEqualTo: flatId);
    }
    if (societyId != null) {
      query = query.where('societyId', isEqualTo: societyId);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    
    return query.snapshots();
  }

  /// Get all visitors (one-time fetch)
  Future<List<Map<String, dynamic>>> getVisitors({String? status, int limit = 50}) async {
    Query query = visitorsCollection
        .orderBy('arrivalTime', descending: true)
        .limit(limit);
    
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Update visitor status
  Future<void> updateVisitorStatus(String visitorId, String status) async {
    final updates = <String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    if (status == 'exited') {
      updates['exitTime'] = FieldValue.serverTimestamp();
    }
    
    await visitorsCollection.doc(visitorId).update(updates);
    LoggerService().info('Visitor $visitorId status updated to $status');
  }

  // ==================== FLAT OPERATIONS ====================

  /// Create a new flat
  Future<String> createFlat({
    required String name,
    required String ownerId,
    String? societyId,
  }) async {
    final doc = await flatsCollection.add({
      'name': name,
      'ownerId': ownerId,
      'societyId': societyId,
      'members': [ownerId],
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });

    LoggerService().info('Flat created: ${doc.id}');
    return doc.id;
  }

  /// Get flat by ID
  Future<Map<String, dynamic>?> getFlat(String flatId) async {
    final doc = await flatsCollection.doc(flatId).get();
    if (!doc.exists) return null;
    
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return data;
  }

  /// Get flats for a user
  Future<List<Map<String, dynamic>>> getUserFlats(String userId) async {
    final snapshot = await flatsCollection
        .where('members', arrayContains: userId)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Add member to flat
  Future<void> addFlatMember(String flatId, String userId) async {
    await flatsCollection.doc(flatId).update({
      'members': FieldValue.arrayUnion([userId]),
    });
  }

  /// Remove member from flat
  Future<void> removeFlatMember(String flatId, String userId) async {
    await flatsCollection.doc(flatId).update({
      'members': FieldValue.arrayRemove([userId]),
    });
  }

  // ==================== GUARD OPERATIONS ====================

  /// Register guard
  Future<void> registerGuard({
    required String guardId,
    required String name,
    String? idProofUrl,
    String status = 'pending',
    String? societyId,
  }) async {
    await guardsCollection.doc(guardId).set({
      'guardId': guardId,
      'name': name,
      'idProofUrl': idProofUrl,
      'status': status,
      'societyId': societyId,
      'assignedFlats': [],
      'visitorsApproved': 0,
      'visitorsRejected': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    LoggerService().info('Guard registered: $guardId');
  }

  /// Get guard profile
  Future<Map<String, dynamic>?> getGuard(String guardId) async {
    final doc = await guardsCollection.doc(guardId).get();
    if (!doc.exists) return null;
    
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return data;
  }

  /// Get all guards
  Future<List<Map<String, dynamic>>> getAllGuards({String? societyId}) async {
    Query query = guardsCollection;
    if (societyId != null) {
      query = query.where('societyId', isEqualTo: societyId);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Update guard status
  Future<void> updateGuardStatus(String guardId, String status) async {
    await guardsCollection.doc(guardId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== GUARD CHECKS (PATROL) OPERATIONS ====================

  /// Log guard check/patrol
  Future<String> logGuardCheck({
    required String checkType,
    required String location,
    String? notes,
    String? photoUrl,
  }) async {
    final guardId = currentUserId;
    if (guardId == null) throw Exception('Guard not authenticated');

    final doc = await guardChecksCollection.add({
      'guardId': guardId,
      'checkType': checkType,
      'location': location,
      'notes': notes,
      'photoUrl': photoUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

    LoggerService().info('Guard check logged: ${doc.id}');
    return doc.id;
  }

  /// Get recent guard checks
  Future<List<Map<String, dynamic>>> getRecentGuardChecks({int limit = 20}) async {
    final snapshot = await guardChecksCollection
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Get guard checks stream
  Stream<QuerySnapshot> getGuardChecksStream({String? guardId}) {
    Query query = guardChecksCollection.orderBy('timestamp', descending: true);
    
    if (guardId != null) {
      query = query.where('guardId', isEqualTo: guardId);
    }
    
    return query.limit(50).snapshots();
  }

  // ==================== SOCIETY OPERATIONS ====================

  /// Create a new society
  Future<String> createSociety({
    required String name,
    required String adminId,
  }) async {
    // Generate a unique short ID for residents to join (Resident ID)
    final societyId = _generateShortId(6);
    
    await societiesCollection.doc(societyId).set({
      'id': societyId,
      'name': name,
      'adminId': adminId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    LoggerService().info('Society created: $societyId');
    return societyId;
  }

  /// Get society by admin ID
  Future<Map<String, dynamic>?> getSocietyByAdmin(String adminId) async {
    final snapshot = await societiesCollection
        .where('adminId', isEqualTo: adminId)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    
    final data = snapshot.docs.first.data() as Map<String, dynamic>;
    data['id'] = snapshot.docs.first.id;
    return data;
  }

  /// Get society by ID (Resident ID)
  Future<Map<String, dynamic>?> getSocietyById(String societyId) async {
    final doc = await societiesCollection.doc(societyId).get();
    if (!doc.exists) return null;
    
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return data;
  }

  String _generateShortId(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = DateTime.now().millisecondsSinceEpoch;
    final r = (rnd % 1000000).toString().padLeft(6, '0');
    // Using a simpler approach for the short ID as requested by user
    return 'SR$r'; 
  }
}
