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

  // Cached lists to prevent O(N) filtering and new list allocation on every getter access
  // PERF: This turns list access in build() from O(N) to O(1) and reduces GC pressure.
  List<Flat> _cachedPendingFlats = [];
  List<Flat> _cachedActiveFlats = [];
  List<Map<String, dynamic>> _cachedGuards = [];

  AdminProvider(this._flatProvider) {
    _refreshStats();
  }

  int get pendingGuardCount => _pendingGuardCount;
  int get activeGuardCount => _activeGuardCount;
  int get pendingFlatCount => _pendingFlatCount;

  void _refreshStats() {
    // Cache the full guards list
    _cachedGuards = _guardRepository.getAllGuards();

    // Calculate stats from the cached list
    _pendingGuardCount = _cachedGuards.where((g) => g['status'] == 'pending').length;
    _activeGuardCount = _cachedGuards.where((g) => g['status'] == 'active').length;

    // Cache flat lists
    _cachedPendingFlats = _flatRepository.getPendingFlats();
    _cachedActiveFlats = _flatRepository.getActiveFlats();

    // Update flat stats
    _pendingFlatCount = _cachedPendingFlats.length;
  }

  // ============ GUARDS MANAGEMENT ============
  
  // Get all guards (Cached)
  List<Map<String, dynamic>> get guards => _cachedGuards;

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

  // Get pending flats (Cached)
  List<Flat> get pendingFlats => _cachedPendingFlats;

  // Get active flats (Cached)
  List<Flat> get activeFlats => _cachedActiveFlats;


  // Get flats from FlatProvider with mapping
  // Note: This still maps on every call. Could be optimized if it becomes a bottleneck.
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
