import 'package:flutter/material.dart';
import '../repositories/guard_repository.dart';
import '../repositories/flat_repository.dart';
import '../providers/flat_provider.dart';

class AdminProvider extends ChangeNotifier {
  final GuardRepository _guardRepository = GuardRepository();
  final FlatRepository _flatRepository = FlatRepository();
  final FlatProvider _flatProvider;

  AdminProvider(this._flatProvider);

  // ============ GUARDS MANAGEMENT ============
  
  // Get all guards
  List<Map<String, dynamic>> get guards => _guardRepository.getAllGuards();

  // Create Guard (Admin) - Generates ID
  String createGuardInvite(String name, {String? manualId}) {
    final id = _guardRepository.createGuard(name, manualId: manualId);
    notifyListeners();
    return id;
  }

  // Update Guard
  void updateGuard(String originalId, {String? name, String? newId}) {
    _guardRepository.updateGuard(originalId, name: name, newId: newId);
    notifyListeners();
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

  // ============ FLATS MANAGEMENT ============

  // Get all flats
  List<Map<String, dynamic>> get allFlats => _flatRepository.allFlats;

  // Get pending flats
  List<String> get pendingFlats => _flatRepository.getPendingFlats();

  // Get active flats
  List<String> get activeFlats => _flatRepository.getActiveFlats();

  // Get flats from FlatProvider with mapping
  List<Map<String, dynamic>> get flats {
    final allFlats = _flatProvider.getAllFlats();
    return allFlats.map((flat) {
      return {
        'id': flat.id,
        'flat': flat.name,
        'resident': 'Owner ID: ${flat.ownerId}',
        'residentId': flat.id,
      };
    }).toList();
  }

  // Add flat using FlatProvider
  Future<void> addFlat(String flatName, String ownerName) async {
    final dummyOwnerId =
        'admin_created_${DateTime.now().millisecondsSinceEpoch}';
    await _flatProvider.createFlat(flatName, dummyOwnerId, ownerName);
    notifyListeners();
  }

  // Update flat using FlatProvider
  Future<void> updateFlat(String id, String flatName, String ownerName) async {
    await _flatProvider.updateFlat(id, flatName, ownerName);
    notifyListeners();
  }

  // Delete flat using FlatProvider
  Future<void> deleteFlat(String id) async {
    await _flatProvider.deleteFlat(id);
    notifyListeners();
  }

  // Approve flat using FlatRepository
  void approveFlat(String flatId) {
    _flatRepository.approveFlat(flatId);
    notifyListeners();
  }

  // Reject flat using FlatRepository
  void rejectFlat(String flatId) {
    _flatRepository.rejectFlat(flatId);
    notifyListeners();
  }

  // Update flat name using FlatRepository
  void updateFlatName(String flatId, String newName) {
    _flatRepository.updateFlatName(flatId, newName);
    notifyListeners();
  }
}