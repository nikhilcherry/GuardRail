import 'package:flutter/material.dart';
import 'dart:math';

enum MemberStatus { pending, accepted }
enum MemberRole { owner, member }

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
  final String name;
  final String ownerId;

  Flat({
    required this.id,
    required this.name,
    required this.ownerId,
  });
}

class FlatProvider extends ChangeNotifier {
  Flat? _currentFlat;
  List<FlatMember> _members = [];
  bool _isLoading = false;
  String? _error;

  Flat? get currentFlat => _currentFlat;
  List<FlatMember> get members => _members;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<FlatMember> get pendingMembers =>
      _members.where((m) => m.status == MemberStatus.pending).toList();

  List<FlatMember> get activeMembers =>
      _members.where((m) => m.status == MemberStatus.accepted).toList();

  // Mock database
  static final List<Flat> _allFlats = [];
  static final Map<String, List<FlatMember>> _flatMembers = {};

  // Admin access to all flats
  List<Flat> getAllFlats() => List.from(_allFlats);

  // Admin: Update flat details
  Future<void> updateFlat(String id, String name, String ownerName) async {
    final index = _allFlats.indexWhere((f) => f.id == id);
    if (index != -1) {
      final oldFlat = _allFlats[index];
      // Update flat name (Owner ID remains same for now)
      _allFlats[index] = Flat(id: oldFlat.id, name: name, ownerId: oldFlat.ownerId);

      // Update owner name in members list
      final members = _flatMembers[id] ?? [];
      final ownerIndex = members.indexWhere((m) => m.userId == oldFlat.ownerId);
      if (ownerIndex != -1) {
        members[ownerIndex] = FlatMember(
          userId: members[ownerIndex].userId,
          name: ownerName,
          status: members[ownerIndex].status,
          role: members[ownerIndex].role,
        );
        _flatMembers[id] = members;
      }
      notifyListeners();
    }
  }

  // Admin: Delete flat
  Future<void> deleteFlat(String id) async {
    _allFlats.removeWhere((f) => f.id == id);
    _flatMembers.remove(id);
    if (_currentFlat?.id == id) {
      clearState();
    }
    notifyListeners();
  }

  // Create a new flat
  Future<void> createFlat(String name, String ownerId, String ownerName) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network

      final flatId = _generateFlatId();
      final newFlat = Flat(id: flatId, name: name, ownerId: ownerId);

      final owner = FlatMember(
        userId: ownerId,
        name: ownerName,
        status: MemberStatus.accepted,
        role: MemberRole.owner,
      );

      _allFlats.add(newFlat);
      _flatMembers[flatId] = [owner];

      _currentFlat = newFlat;
      _members = [owner];
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Join an existing flat
  Future<void> joinFlat(String flatId, String userId, String userName) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));

      final flatIndex = _allFlats.indexWhere((f) => f.id == flatId);
      if (flatIndex == -1) {
        throw Exception('Flat not found');
      }

      final flat = _allFlats[flatIndex];
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

      // We don't set _currentFlat yet because they are pending
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Approve a member
  Future<void> approveMember(String userId) async {
    if (_currentFlat == null) return;

    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final memberIndex = _members.indexWhere((m) => m.userId == userId);
      if (memberIndex != -1) {
        _members[memberIndex].status = MemberStatus.accepted;
        _flatMembers[_currentFlat!.id] = _members;
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  // Reject a member
  Future<void> rejectMember(String userId) async {
     if (_currentFlat == null) return;

    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _members.removeWhere((m) => m.userId == userId);
      _flatMembers[_currentFlat!.id] = _members;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Helper to generate unique ID
  String _generateFlatId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Refresh status
  void refreshFlatData() {
    if (_currentFlat != null) {
       // Just trigger a rebuild to refresh getters
       notifyListeners();
    }
  }

  // Clear state on logout
  void clearState() {
    _currentFlat = null;
    _members = [];
    _error = null;
    notifyListeners();
  }

  // Method to check if user is already in a flat (mock implementation)
  // In real app, this would fetch from backend based on auth token
  void checkUserFlatStatus(String userId) {
     for (var flat in _allFlats) {
       final members = _flatMembers[flat.id];
       if (members != null) {
         final member = members.firstWhere(
           (m) => m.userId == userId,
           orElse: () => FlatMember(userId: '', name: '', status: MemberStatus.pending), // Dummy
         );

         if (member.userId.isNotEmpty) {
           _currentFlat = flat;
           _members = members;
           notifyListeners();
           return;
         }
       }
     }
  }
}
