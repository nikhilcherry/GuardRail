import 'package:flutter/material.dart';
import '../repositories/flat_repository.dart';

// Re-export for compatibility
export '../repositories/flat_repository.dart' show Flat, FlatMember, MemberStatus, MemberRole, FlatStatus;

class FlatProvider extends ChangeNotifier {
  final FlatRepository _repository = FlatRepository();
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

  // Create a new flat
  Future<void> createFlat(String name, String ownerId, String ownerName) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network

      final newFlat = await _repository.createFlatRequest(name, ownerId, ownerName);

      _currentFlat = newFlat;
      _members = _repository.getMembers(newFlat.id);
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

      await _repository.joinFlat(flatId, userId, userName);

      // On success, we need to refresh the current user's flat status
      // But typically we do this by reloading the screen or calling checkUserFlatStatus
      checkUserFlatStatus(userId);

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
      _repository.updateMemberStatus(_currentFlat!.id, userId, MemberStatus.accepted);
      _refreshMembers();
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
      _repository.removeMember(_currentFlat!.id, userId);
      _refreshMembers();
    } finally {
      _setLoading(false);
    }
  }

  void _refreshMembers() {
    if (_currentFlat != null) {
      _members = _repository.getMembers(_currentFlat!.id);
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Refresh status
  void refreshFlatData() {
    if (_currentFlat != null) {
       _members = _repository.getMembers(_currentFlat!.id);
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

  // Method to check if user is already in a flat
  void checkUserFlatStatus(String userId) {
     final flat = _repository.getFlatForUser(userId);
     if (flat != null) {
       _currentFlat = flat;
       _members = _repository.getMembers(flat.id);
     } else {
       _currentFlat = null;
       _members = [];
     }
     notifyListeners();
  }
}
