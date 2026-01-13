import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/logger_service.dart';

enum MemberStatus { pending, accepted }
enum MemberRole { owner, member }
enum FlatStatus { pending, active, rejected }

class FlatMember {
  final String userId;
  final String name;
  MemberStatus status;
  final MemberRole role;

  FlatMember({
    required this.userId,
    required this.name,
    this.status = MemberStatus.pending,
    this.role = MemberRole.member,
  });

  factory FlatMember.fromMap(Map<String, dynamic> data) {
    return FlatMember(
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      status: data['status'] == 'accepted' ? MemberStatus.accepted : MemberStatus.pending,
      role: data['role'] == 'owner' ? MemberRole.owner : MemberRole.member,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'status': status == MemberStatus.accepted ? 'accepted' : 'pending',
      'role': role == MemberRole.owner ? 'owner' : 'member',
    };
  }
}

class Flat {
  final String id;
  String name;
  final String ownerId;
  FlatStatus status;

  Flat({
    required this.id,
    required this.name,
    required this.ownerId,
    this.status = FlatStatus.pending,
  });

  factory Flat.fromFirestore(Map<String, dynamic> data, String docId) {
    return Flat(
      id: docId,
      name: data['name'] ?? '',
      ownerId: data['ownerId'] ?? '',
      status: _parseStatus(data['status']),
    );
  }

  static FlatStatus _parseStatus(String? status) {
    switch (status) {
      case 'active':
        return FlatStatus.active;
      case 'rejected':
        return FlatStatus.rejected;
      default:
        return FlatStatus.pending;
    }
  }

  String get statusString {
    switch (status) {
      case FlatStatus.active:
        return 'active';
      case FlatStatus.rejected:
        return 'rejected';
      case FlatStatus.pending:
        return 'pending';
    }
  }
}

class FlatRepository {
  // Singleton pattern
  static final FlatRepository _instance = FlatRepository._internal();
  factory FlatRepository() => _instance;
  FlatRepository._internal();

  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Local cache
  List<Flat> _allFlats = [];
  final Map<String, List<FlatMember>> _flatMembers = {};
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
        
        // Load members for each flat
        final membersData = data['members'] as List<dynamic>?;
        if (membersData != null) {
          _flatMembers[doc.id] = membersData
              .map((m) => FlatMember.fromMap(m as Map<String, dynamic>))
              .toList();
        }
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
    );

    _allFlats.add(newFlat);
    _flatMembers[flatId] = [owner];

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
      _allFlats[flatIndex].status = FlatStatus.active;
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
      _allFlats[flatIndex].status = FlatStatus.rejected;
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

    final members = _flatMembers[flatId] ?? [];
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

    members.add(newMember);
    _flatMembers[flatId] = members;
  }

  // Member Management
  List<FlatMember> getMembers(String flatId) {
    return _flatMembers[flatId] ?? [];
  }

  Future<void> updateMemberStatus(String flatId, String userId, MemberStatus status) async {
    final members = _flatMembers[flatId];
    if (members != null) {
      final index = members.indexWhere((m) => m.userId == userId);
      if (index != -1) {
        members[index].status = status;

        // Update in Firestore
        await _firestore.collection('flats').doc(flatId).update({
          'members': members.map((m) => m.toMap()).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> removeMember(String flatId, String userId) async {
    final members = _flatMembers[flatId];
    if (members != null) {
      final member = members.where((m) => m.userId == userId).firstOrNull;
      if (member != null) {
        await _firestore.collection('flats').doc(flatId).update({
          'members': FieldValue.arrayRemove([member.toMap()]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        members.removeWhere((m) => m.userId == userId);
      }
    }
  }

  // User Queries
  Flat? getFlatForUser(String userId) {
    for (var flat in _allFlats) {
      final members = _flatMembers[flat.id];
      if (members != null && members.any((m) => m.userId == userId)) {
        return flat;
      }
    }
    return null;
  }

  FlatMember? getMemberForUser(String userId) {
    for (var flat in _allFlats) {
      final members = _flatMembers[flat.id];
      if (members != null) {
        try {
          return members.firstWhere((m) => m.userId == userId);
        } catch (_) {}
      }
    }
    return null;
  }

  String _generateFlatId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}
