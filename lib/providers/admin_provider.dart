import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/guard_repository.dart';
import '../repositories/flat_repository.dart';
import '../providers/flat_provider.dart';
import '../services/firestore_service.dart';

class AdminProvider extends ChangeNotifier {
  final GuardRepository _guardRepository = GuardRepository();
  final FlatRepository _flatRepository = FlatRepository();
  final FirestoreService _firestoreService = FirestoreService();
  final FlatProvider _flatProvider;

  // Stats
  int _pendingGuardCount = 0;
  int _activeGuardCount = 0;
  int _pendingFlatCount = 0;
  bool _isLoading = false;

  // Cached data (PERF)
  List<Map<String, dynamic>> _cachedGuards = [];
  List<Flat> _cachedPendingFlats = [];
  List<Flat> _cachedActiveFlats = [];

  Map<String, dynamic>? _society;

  AdminProvider(this._flatProvider) {
    _initializeData();
  }

  // ================= GETTERS =================

  int get pendingGuardCount => _pendingGuardCount;
  int get activeGuardCount => _activeGuardCount;
  int get pendingFlatCount => _pendingFlatCount;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? get society => _society;
  List<Map<String, dynamic>> get guards => _cachedGuards;
  List<Flat> get pendingFlats => _cachedPendingFlats;
  List<Flat> get activeFlats => _cachedActiveFlats;
  List<Flat> get allFlats => _flatRepository.allFlats;

  // ================= INIT =================

  Future<void> _initializeData() async {
    _setLoading(true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _society = await _firestoreService.getSocietyByAdmin(user.uid);
    }

    await _flatRepository.loadFlats();
    await _refreshStats();

    _setLoading(false);
  }

  // ================= CORE REFRESH =================

  Future<void> _refreshStats() async {
    final societyId = _society?['id'];

    // Guards
    _cachedGuards =
        await _firestoreService.getAllGuards(societyId: societyId);

    _pendingGuardCount =
        _cachedGuards.where((g) => g['status'] == 'pending').length;

    _activeGuardCount =
        _cachedGuards.where((g) => g['status'] == 'active').length;

    // Flats (cached)
    _cachedPendingFlats = _flatRepository.getPendingFlats();
    _cachedActiveFlats = _flatRepository.getActiveFlats();
    _pendingFlatCount = _cachedPendingFlats.length;
  }

  Future<void> refresh() async {
    _setLoading(true);

    await _guardRepository.refresh();
    await _flatRepository.refresh();
    await _refreshStats();

    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ================= SOCIETY =================

  Future<void> createSociety(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _setLoading(true);

    final societyId = await _firestoreService.createSociety(
      name: name,
      adminId: user.uid,
    );

    _society = {
      'id': societyId,
      'name': name,
      'adminId': user.uid,
    };

    _setLoading(false);
  }

  // ================= GUARDS =================

  Future<String> createGuardInvite(String name, {String? manualId}) async {
    final id = await _guardRepository.createGuard(
      name,
      manualId: manualId,
      societyId: _society?['id'],
    );
    await _refreshStats();
    notifyListeners();
    return id;
  }

  Future<void> updateGuard(String originalId,
      {String? name, String? newId}) async {
    await _guardRepository.updateGuard(
      originalId,
      name: name,
      newId: newId,
    );
    await _refreshStats();
    notifyListeners();
  }

  Future<void> approveGuard(String id) async {
    await _guardRepository.updateGuardStatus(id, 'active');
    await _refreshStats();
    notifyListeners();
  }

  Future<void> rejectGuard(String id) async {
    await _guardRepository.updateGuardStatus(id, 'rejected');
    await _refreshStats();
    notifyListeners();
  }

  Future<void> deleteGuard(String id) async {
    await _guardRepository.deleteGuard(id);
    await _refreshStats();
    notifyListeners();
  }

  // ================= FLATS =================

  List<Map<String, dynamic>> get flats {
    return _flatProvider.getAllFlats().map((flat) {
      return {
        'id': flat.id,
        'flat': flat.name,
        'resident': 'Owner ID: ${flat.ownerId}',
        'residentId': flat.id,
      };
    }).toList();
  }

  Future<void> addFlat(String flatName, String ownerName) async {
    final dummyOwnerId =
        'admin_created_${DateTime.now().millisecondsSinceEpoch}';
    await _flatProvider.createFlat(flatName, dummyOwnerId, ownerName);
    await _refreshStats();
    notifyListeners();
  }

  Future<void> updateFlat(
      String id, String flatName, String ownerName) async {
    await _flatProvider.updateFlat(id, flatName, ownerName);
    await _refreshStats();
    notifyListeners();
  }

  Future<void> deleteFlat(String id) async {
    await _flatProvider.deleteFlat(id);
    await _refreshStats();
    notifyListeners();
  }

  Future<void> approveFlat(String flatId) async {
    await _flatRepository.approveFlat(flatId);
    await _refreshStats();
    notifyListeners();
  }

  Future<void> rejectFlat(String flatId) async {
    await _flatRepository.rejectFlat(flatId);
    await _refreshStats();
