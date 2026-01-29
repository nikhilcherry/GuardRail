import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/security_utils.dart';
import '../models/flat.dart';
import '../services/firestore_service.dart';
import '../services/logger_service.dart';

class FlatRepository {
  // Singleton pattern
  static final FlatRepository _instance = FlatRepository._internal();
  factory FlatRepository() => _instance;
  FlatRepository._internal();

  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Local cache
  List<Flat> _allFlats = [];
  bool _isLoaded = false;

  // Getters
  List<Flat> get allFlats => List.unmodifiable(_allFlats);

  /// Initialize and load flats from Firestore
  Future<void> loadFlats() async {
    if (_isLoaded) return;
    
    try {
      final snapshot = await _firestore.collection('flats').get();
      _allFlats.clear();
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        _allFlats.add(Flat.fromFirestore(data, doc.id));
      }
      
      _isLoaded = true;
    } catch (e) {
      LoggerService().error('Failed to load flats', e, StackTrace.current);
    }
  }

  /// Refresh flats from Firestore
  Future<void> refresh() async {
    _isLoaded = false;
    await loadFlats();
  }

  List<Flat> getPendingFlats() {
    return _allFlats.where((f) => f.status == FlatStatus.pending).toList();
  }

  List<Flat> getActiveFlats() {
    return _allFlats.where((f) => f.status == FlatStatus.active).toList();
  }

  /// Create a new flat (stored in Firestore)
  Future<Flat> createFlatRequest(String name, String ownerId, String ownerName) async {
    final flatId = _generateFlatId();

    final owner = FlatMember(
      userId: ownerId,
      name: ownerName,
      status: MemberStatus.accepted,
      role: MemberRole.owner,
    );

    // Create in Firestore
    await _firestore.collection('flats').doc(flatId).set({
      'name': name,
      'ownerId': ownerId,
      'members': [owner.toMap()],
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    final newFlat = Flat(
      id: flatId,
      name: name,
      ownerId: ownerId,
      status: FlatStatus.pending,
      members: [owner],
    );

    _allFlats.add(newFlat);

    LoggerService().info('Flat created: $flatId');
    return newFlat;
  }

  /// Admin: Approve Flat
  Future<void> approveFlat(String flatId) async {
    await _firestore.collection('flats').doc(flatId).update({
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final flatIndex = _allFlats.indexWhere((f) => f.id == flatId);
    if (flatIndex != -1) {
      _allFlats[flatIndex] = Flat(
        id: _allFlats[flatIndex].id,
        name: _allFlats[flatIndex].name,
        ownerId: _allFlats[flatIndex].ownerId,
        status: FlatStatus.active,
        members: _allFlats[flatIndex].members,
      );
    }
  }

  /// Admin: Reject Flat
  Future<void> rejectFlat(String flatId) async {
    await _firestore.collection('flats').doc(flatId).update({
      'status': 'rejected',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final flatIndex = _allFlats.indexWhere((f) => f.id == flatId);
    if (flatIndex != -1) {
      _allFlats[flatIndex] = Flat(
        id: _allFlats[flatIndex].id,
        name: _allFlats[flatIndex].name,
        ownerId: _allFlats[flatIndex].ownerId,
        status: FlatStatus.rejected,
        members: _allFlats[flatIndex].members,
      );
    }
  }

  /// Admin: Update Flat Name
  Future<void> updateFlatName(String flatId, String newName) async {
    await _firestore.collection('flats').doc(flatId).update({
      'name': newName,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final flatIndex = _allFlats.indexWhere((f) => f.id == flatId);
    if (flatIndex != -1) {
       _allFlats[flatIndex].name = newName;
       // Note: Since name is mutable in my class I could just set it, but to be clean:
       // _allFlats[flatIndex] = ... (but I defined name as var in Flat, so I can set it)
    }
  }

  /// Join Flat
  Future<void> joinFlat(String flatId, String userId, String userName) async {
    final flatIndex = _allFlats.indexWhere((f) => f.id == flatId);
    if (flatIndex == -1) {
      throw Exception('Flat not found');
    }

    if (_allFlats[flatIndex].status != FlatStatus.active) {
      throw Exception('Flat is not active yet');
    }

    final members = _allFlats[flatIndex].members;
    if (members.any((m) => m.userId == userId)) {
      throw Exception('You are already a member or have a pending request for this flat');
    }

    final newMember = FlatMember(
      userId: userId,
      name: userName,
      status: MemberStatus.pending,
      role: MemberRole.member,
    );

    // Update in Firestore
    await _firestore.collection('flats').doc(flatId).update({
      'members': FieldValue.arrayUnion([newMember.toMap()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update local cache
    // Since List<FlatMember> is unmodifiable? No, it's just a List.
    // But Flat.members should be mutable or I should replace Flat.
    // Flat.members is final in my model? Let's check.
    // "final List<FlatMember> members;" in Flat model.
    // So I need to replace the Flat object.

    final updatedMembers = List<FlatMember>.from(members)..add(newMember);
    _allFlats[flatIndex] = Flat(
        id: _allFlats[flatIndex].id,
        name: _allFlats[flatIndex].name,
        ownerId: _allFlats[flatIndex].ownerId,
        status: _allFlats[flatIndex].status,
        members: updatedMembers,
      );
  }

  // Member Management
  List<FlatMember> getMembers(String flatId) {
    final flat = _allFlats.where((f) => f.id == flatId).firstOrNull;
    return flat?.members ?? [];
  }

  Future<void> updateMemberStatus(String flatId, String userId, MemberStatus status) async {
    final flatIndex = _allFlats.indexWhere((f) => f.id == flatId);
    if (flatIndex != -1) {
      final members = _allFlats[flatIndex].members;
      final memberIndex = members.indexWhere((m) => m.userId == userId);

      if (memberIndex != -1) {
        members[memberIndex].status = status;

        // Update in Firestore
        await _firestore.collection('flats').doc(flatId).update({
          'members': members.map((m) => m.toMap()).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // No need to replace Flat object if I mutated member in place?
        // MemberStatus is mutable in FlatMember.
      }
    }
  }

  Future<void> removeMember(String flatId, String userId) async {
    final flatIndex = _allFlats.indexWhere((f) => f.id == flatId);
    if (flatIndex != -1) {
      final members = _allFlats[flatIndex].members;
      final member = members.where((m) => m.userId == userId).firstOrNull;

      if (member != null) {
        await _firestore.collection('flats').doc(flatId).update({
          'members': FieldValue.arrayRemove([member.toMap()]),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update local
        final updatedMembers = List<FlatMember>.from(members)..removeWhere((m) => m.userId == userId);
        _allFlats[flatIndex] = Flat(
          id: _allFlats[flatIndex].id,
          name: _allFlats[flatIndex].name,
          ownerId: _allFlats[flatIndex].ownerId,
          status: _allFlats[flatIndex].status,
          members: updatedMembers,
        );
      }
    }
  }

  // User Queries
  Flat? getFlatForUser(String userId) {
    for (var flat in _allFlats) {
      if (flat.members.any((m) => m.userId == userId)) {
        return flat;
      }
    }
    return null;
  }

  FlatMember? getMemberForUser(String userId) {
    for (var flat in _allFlats) {
      try {
        return flat.members.firstWhere((m) => m.userId == userId);
      } catch (_) {}
    }
    return null;
  }

  String _generateFlatId() {
    return SecurityUtils.generateId(
      length: 6,
      chars: SecurityUtils.uppercaseAlphanumeric,
    );
  }
}
