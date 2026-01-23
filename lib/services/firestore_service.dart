import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/logger_service.dart';

/// Central Firestore service for all database operations.
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

  String? get currentUserId => _auth.currentUser?.uid;

  // ==================== USER OPERATIONS ====================

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

  Future<Map<String, dynamic>?> getUserProfile([String? userId]) async {
    final uid = userId ?? currentUserId;
    if (uid == null) return null;

    final doc = await usersCollection.doc(uid).get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    updates['updatedAt'] = FieldValue.serverTimestamp();
    await usersCollection.doc(userId).update(updates);
  }

  // ==================== VISITOR OPERATIONS ====================

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

  Stream<QuerySnapshot> getVisitorsStream({String? flatId, String? societyId, String? status}) {
    Query query = visitorsCollection.orderBy('arrivalTime', descending: true);

    if (flatId != null) query = query.where('flatId', isEqualTo: flatId);
    if (societyId != null) query = query.where('societyId', isEqualTo: societyId);
    if (status != null) query = query.where('status', isEqualTo: status);

    return query.snapshots();
  }

  // Placeholder to fix build error
  Future<List<Map<String, dynamic>>> getVisitors() async {
    // Return mock data or empty list for now to allow compilation
    return [];
  }

  Future<void> updateVisitorStatus(String visitorId, String status) async {
    final updates = {
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (status == 'exited') {
      updates['exitTime'] = FieldValue.serverTimestamp();
    }

    await visitorsCollection.doc(visitorId).update(updates);
  }

  // ==================== SOCIETY OPERATIONS ====================

  Future<String> createSociety({
    required String name,
    required String adminId,
  }) async {
    final societyId = _generateShortId(6);

    await societiesCollection.doc(societyId).set({
      'id': societyId,
      'name': name,
      'adminId': adminId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return societyId;
  }

  Future<Map<String, dynamic>?> getSocietyByAdmin(String adminId) async {
    final snapshot = await societiesCollection
        .where('adminId', isEqualTo: adminId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.data() as Map<String, dynamic>;
  }

  String _generateShortId(int length) {
    final r = DateTime.now().millisecondsSinceEpoch % 1000000;
    return 'SR${r.toString().padLeft(6, '0')}';
  }
}
