import 'package:cloud_firestore/cloud_firestore.dart';
import 'logger_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoggerService _logger = LoggerService();

  // --- User Profiles ---

  /// Get user profile by UID (or current user if uid is null)
  Future<Map<String, dynamic>?> getUserProfile([String? uid]) async {
    try {
      if (uid == null) {
         // If no UID provided, we can't look it up without Auth context here.
         // Assuming usage is always with UID from AuthService.
         // If not, we could default to empty or throw, but null is safer.
         return null;
      }

      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      _logger.error('Error fetching user profile', e, StackTrace.current);
      return null;
    }
  }

  /// Save or update user profile (Legacy wrapper, use withId variant)
  /// Deprecated: use saveUserProfileWithId
  Future<void> saveUserProfile({
    required String name,
    required String email,
    required String role,
    String? phone,
    String? societyId,
    String? flatId,
    bool isVerified = false,
  }) async {
      // This method signature is flawed as it lacks UID.
      // It exists only to satisfy potential legacy callers that haven't been updated.
      // Since we updated AuthService/AuthRepository, this should not be called.
      // Removing logic to prevent confusion, callers must use saveUserProfileWithId.
      throw UnimplementedError("Use saveUserProfileWithId");
  }

  Future<void> saveUserProfileWithId({
    required String uid,
    required String name,
    required String email,
    required String role,
    String? phone,
    String? societyId,
    String? flatId,
    bool isVerified = false,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'role': role,
        'phone': phone,
        'societyId': societyId,
        'flatId': flatId,
        'isVerified': isVerified,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.error('Error saving user profile', e, StackTrace.current);
      rethrow;
    }
  }

  /// Update user profile (Legacy wrapper)
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    throw UnimplementedError("Use updateUserProfileWithId");
  }

  Future<void> updateUserProfileWithId(String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      _logger.error('Error updating user profile', e, StackTrace.current);
      rethrow;
    }
  }

  // --- Admin / Society ---

  Future<Map<String, dynamic>?> getSocietyByAdmin(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('societies')
          .where('adminId', isEqualTo: uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      _logger.error('Error getting society', e, StackTrace.current);
      return null;
    }
  }

  // --- Guards ---

  Future<List<Map<String, dynamic>>> getAllGuards() async {
    try {
      final snapshot = await _firestore.collection('guards').get();
      return snapshot.docs.map((d) {
        final data = d.data();
        data['id'] = d.id; // Ensure ID is included
        return data;
      }).toList();
    } catch (e) {
      _logger.error('Error getting guards', e, StackTrace.current);
      return [];
    }
  }

  Future<Map<String, dynamic>?> getGuard(String id) async {
    try {
      final doc = await _firestore.collection('guards').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      _logger.error('Error getting guard $id', e, StackTrace.current);
      return null;
    }
  }

  Future<void> registerGuard({
    required String guardId,
    required String name,
    required String status,
    String? societyId,
  }) async {
    try {
      await _firestore.collection('guards').doc(guardId).set({
        'guardId': guardId,
        'name': name,
        'status': status,
        'societyId': societyId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.error('Error registering guard', e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> updateGuardStatus(String id, String status) async {
    try {
      await _firestore.collection('guards').doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.error('Error updating guard status', e, StackTrace.current);
      rethrow;
    }
  }

  // --- Visitors ---

  Stream<QuerySnapshot> getVisitorsStream() {
    // In real app, filter by society/flat/guard context
    return _firestore
        .collection('visitors')
        .orderBy('arrivalTime', descending: true)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getVisitors() async {
     try {
      final snapshot = await _firestore
        .collection('visitors')
        .orderBy('arrivalTime', descending: true)
        .get();

      return snapshot.docs.map((d) {
         final data = d.data();
         data['id'] = d.id;
         return data;
      }).toList();
     } catch (e) {
       _logger.error('Error getting visitors', e, StackTrace.current);
       return [];
     }
  }

  Future<String> addVisitor({
    required String name,
    required String flatId,
    required String purpose,
    String? photoUrl,
    String? vehicleNumber,
    String? vehicleType,
    required String status,
  }) async {
    try {
      final docRef = await _firestore.collection('visitors').add({
        'name': name,
        'flatId': flatId,
        'purpose': purpose,
        'photoUrl': photoUrl,
        'vehicleNumber': vehicleNumber,
        'vehicleType': vehicleType,
        'status': status,
        'arrivalTime': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      _logger.error('Error adding visitor', e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> updateVisitorStatus(String id, String status) async {
    try {
      await _firestore.collection('visitors').doc(id).update({
        'status': status,
        if (status == 'exited') 'exitTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.error('Error updating visitor status', e, StackTrace.current);
      rethrow;
    }
  }
}
