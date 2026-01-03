import 'package:flutter/material.dart';
import '../repositories/guard_repository.dart';
import '../repositories/flat_repository.dart';

class AdminProvider extends ChangeNotifier {
  final GuardRepository _guardRepository = GuardRepository();
  final FlatRepository _flatRepository = FlatRepository();

  // Guards
  List<Map<String, dynamic>> get guards => _guardRepository.getAllGuards();

  // Flats
  List<Flat> get allFlats => _flatRepository.allFlats;
  List<Flat> get pendingFlats => _flatRepository.getPendingFlats();
  List<Flat> get activeFlats => _flatRepository.getActiveFlats();

  // Flat Operations
  void approveFlat(String flatId) {
    _flatRepository.approveFlat(flatId);
    notifyListeners();
  }

  void rejectFlat(String flatId) {
    _flatRepository.rejectFlat(flatId);
    notifyListeners();
  }

  void updateFlatName(String flatId, String newName) {
    _flatRepository.updateFlatName(flatId, newName);
    notifyListeners();
  }

  // --- Guard Management using Repository ---

  // Create Guard (Admin) - Generates ID
  String createGuardInvite(String name) {
    final id = _guardRepository.createGuard(name);
    notifyListeners();
    return id;
  }

  // Approve Guard
  void approveGuard(String id) {
    _guardRepository.updateGuardStatus(id, 'active');
    notifyListeners();
  }

  // Reject Guard
  void rejectGuard(String id) {
    _guardRepository.updateGuardStatus(id, 'rejected');
    notifyListeners();
  }

  // Delete Guard
  void deleteGuard(String id) {
    _guardRepository.deleteGuard(id);
    notifyListeners();
  }
}
