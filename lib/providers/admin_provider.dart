import 'package:flutter/material.dart';
import '../repositories/guard_repository.dart';
import '../repositories/flat_repository.dart';
import '../providers/flat_provider.dart';

class AdminProvider extends ChangeNotifier {
  final GuardRepository _guardRepository = GuardRepository();
  final FlatRepository _flatRepository = FlatRepository();
  final FlatProvider _flatProvider;

  // Cached stats to avoid expensive recalculations in build()
  int _pendingGuardCount = 0;
  int _activeGuardCount = 0;
  int _pendingFlatCount = 0;

  AdminProvider(this._flatProvider) {
    _refreshStats();
  }

  int get pendingGuardCount => _pendingGuardCount;
  int get activeGuardCount => _activeGuardCount;
  int get pendingFlatCount => _pendingFlatCount;

  void _refreshStats() {
    final allGuards = _guardRepository.getAllGuards();
    _pendingGuardCount = allGuards.where((g) => g['status'] == 'pending').length;
    _activeGuardCount = allGuards.where((g) => g['status'] == 'active').length;
    _pendingFlatCount = _flatRepository.getPendingFlats().length;
  }

  // ============ GUARDS MANAGEMENT ============
  
  // Get all guards
  List<Map<String, dynamic>> get guards => _guardRepository.getAllGuards();

  // Create Guard (Admin) - Generates ID
  String createGuardInvite(String name, {String? manualId}) {
    final id = _guardRepository.createGuard(name, manualId: manualId);
    _refreshStats();
    notifyListeners();
    return id;
  }

  // Update Guard
  void updateGuard(String originalId, {String? name, String? newId}) {
    _guardRepository.updateGuard(originalId, name: name, newId: newId);
    _refreshStats();
    notifyListeners();
  }

  // Approve Guard
  void approveGuard(String id) {
    _guardRepository.updateGuardStatus(id, 'active');
    _refreshStats();
    notifyListeners();
  }

  // Reject Guard
  void rejectGuard(String id) {
    _guardRepository.updateGuardStatus(id, 'rejected');
    _refreshStats();
    notifyListeners();
  }

  // Delete Guard
  void deleteGuard(String id) {
    _guardRepository.deleteGuard(id);
    _refreshStats();
    notifyListeners();
  }

  // ============ FLATS MANAGEMENT ============

  // Get all flats
  List<Flat> get allFlats => _flatRepository.allFlats;

  // Get pending flats
  List<Flat> get pendingFlats => _flatRepository.getPendingFlats();

  // Get active flats
  List<Flat> get activeFlats => _flatRepository.getActiveFlats();


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
    _refreshStats();
    notifyListeners();
  }

  // Update flat using FlatProvider
  Future<void> updateFlat(String id, String flatName, String ownerName) async {
    await _flatProvider.updateFlat(id, flatName, ownerName);
    _refreshStats();
    notifyListeners();
  }

  // Delete flat using FlatProvider
  Future<void> deleteFlat(String id) async {
    await _flatProvider.deleteFlat(id);
    _refreshStats();
    notifyListeners();
  }

  // Approve flat using FlatRepository
  void approveFlat(String flatId) {
    _flatRepository.approveFlat(flatId);
    _refreshStats();
    notifyListeners();
  }

  // Reject flat using FlatRepository
  void rejectFlat(String flatId) {
    _flatRepository.rejectFlat(flatId);
    _refreshStats();
    notifyListeners();
  }

  // Update flat name using FlatRepository
  void updateFlatName(String flatId, String newName) {
    _flatRepository.updateFlatName(flatId, newName);
    _refreshStats();
    notifyListeners();
  }
}
