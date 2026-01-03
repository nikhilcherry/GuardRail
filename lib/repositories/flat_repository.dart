import 'dart:math';

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
}

class FlatRepository {
  // Singleton pattern
  static final FlatRepository _instance = FlatRepository._internal();
  factory FlatRepository() => _instance;
  FlatRepository._internal();

  // Mock database
  final List<Flat> _allFlats = [];
  final Map<String, List<FlatMember>> _flatMembers = {};

  // Getters
  List<Flat> get allFlats => List.unmodifiable(_allFlats);

  List<Flat> getPendingFlats() {
    return _allFlats.where((f) => f.status == FlatStatus.pending).toList();
  }

  List<Flat> getActiveFlats() {
    return _allFlats.where((f) => f.status == FlatStatus.active).toList();
  }

  // Flat Operations
  Future<Flat> createFlatRequest(String name, String ownerId, String ownerName) async {
    final flatId = _generateFlatId();
    final newFlat = Flat(
      id: flatId,
      name: name,
      ownerId: ownerId,
      status: FlatStatus.pending, // Default to pending
    );

    final owner = FlatMember(
      userId: ownerId,
      name: ownerName,
      status: MemberStatus.accepted,
      role: MemberRole.owner,
    );

    _allFlats.add(newFlat);
    _flatMembers[flatId] = [owner];

    return newFlat;
  }

  // Admin: Approve Flat
  void approveFlat(String flatId) {
    final flatIndex = _allFlats.indexWhere((f) => f.id == flatId);
    if (flatIndex != -1) {
      _allFlats[flatIndex].status = FlatStatus.active;
    }
  }

  // Admin: Reject Flat
  void rejectFlat(String flatId) {
    final flatIndex = _allFlats.indexWhere((f) => f.id == flatId);
    if (flatIndex != -1) {
      _allFlats[flatIndex].status = FlatStatus.rejected;
    }
  }

  // Admin: Update Flat Name
  void updateFlatName(String flatId, String newName) {
    final flatIndex = _allFlats.indexWhere((f) => f.id == flatId);
    if (flatIndex != -1) {
      _allFlats[flatIndex].name = newName;
    }
  }

  // Join Flat
  Future<void> joinFlat(String flatId, String userId, String userName) async {
    final flatIndex = _allFlats.indexWhere((f) => f.id == flatId);
    if (flatIndex == -1) {
      throw Exception('Flat not found');
    }

    // Check if flat is active? Or can we join pending flats?
    // Usually only active flats can be joined.
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

    members.add(newMember);
    _flatMembers[flatId] = members;
  }

  // Member Management
  List<FlatMember> getMembers(String flatId) {
    return _flatMembers[flatId] ?? [];
  }

  void updateMemberStatus(String flatId, String userId, MemberStatus status) {
    final members = _flatMembers[flatId];
    if (members != null) {
      final index = members.indexWhere((m) => m.userId == userId);
      if (index != -1) {
        members[index].status = status;
      }
    }
  }

  void removeMember(String flatId, String userId) {
    final members = _flatMembers[flatId];
    if (members != null) {
      members.removeWhere((m) => m.userId == userId);
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
