import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/logger_service.dart';

class GuardRepository {
  // Singleton pattern
  static final GuardRepository _instance = GuardRepository._internal();
  factory GuardRepository() => _instance;
  GuardRepository._internal();

  final FirestoreService _firestoreService = FirestoreService();

  // Local cache for guards
  List<Map<String, dynamic>> _guards = [];
  bool _isLoaded = false;

  /// Get all guards (from cache or Firestore)
  Future<List<Map<String, dynamic>>> getAllGuards() async {
    if (!_isLoaded) {
      await _loadGuards();
    }
    return List.from(_guards);
  }

  /// Load guards from Firestore
  Future<void> _loadGuards() async {
    try {
      _guards = await _firestoreService.getAllGuards();
      _isLoaded = true;
    } catch (e) {
      LoggerService().error('Failed to load guards', e, StackTrace.current);
      // Initialize with empty list on error
      _guards = [];
      _isLoaded = true;
    }
  }

  /// Refresh guards from Firestore
  Future<void> refresh() async {
    _isLoaded = false;
    await _loadGuards();
  }

  /// Create a new guard profile (Admin action)
  Future<String> createGuard(String name, {String? manualId, String? societyId}) async {
    String id;
    if (manualId != null && manualId.trim().isNotEmpty) {
      id = manualId.trim();
      // Check if ID exists
      final existing = await _firestoreService.getGuard(id);
      if (existing != null) {
        throw Exception('Guard ID already exists');
      }
    } else {
      id = _generateGuardId();
    }

    await _firestoreService.registerGuard(
      guardId: id,
      name: name,
      status: 'created',
      societyId: societyId,
    );

    // Update local cache
    _guards.add({
      'id': id,
      'guardId': id,
      'name': name,
      'status': 'created',
      'createdAt': DateTime.now(),
    });

    LoggerService().info('Guard created: $id');
    return id;
  }

  /// Update existing guard
  Future<void> updateGuard(String originalId, {String? name, String? newId}) async {
    final index = _guards.indexWhere((g) => g['id'] == originalId || g['guardId'] == originalId);
    if (index == -1) throw Exception('Guard not found');

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (newId != null && newId != originalId) {
      // Note: Changing document ID in Firestore requires delete + create
      // For simplicity, we'll just update the guardId field
      updates['guardId'] = newId;
    }

    if (updates.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('guards')
          .doc(originalId)
          .update(updates);

      // Update local cache
      _guards[index] = {..._guards[index], ...updates};
    }
  }

  /// Generate a unique ID (Mixed case + numbers)
  String _generateGuardId() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    String id;
    do {
      final code = String.fromCharCodes(Iterable.generate(
          6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
      id = code;
    } while (_guards.any((g) => g['id'] == id || g['guardId'] == id));
    return id;
  }

  /// Find guard by ID
  Future<Map<String, dynamic>?> getGuardById(String id) async {
    // Check local cache first
    final cached = _guards.where((g) => g['id'] == id || g['guardId'] == id).firstOrNull;
    if (cached != null) return cached;

    // Fetch from Firestore
    return await _firestoreService.getGuard(id);
  }

  /// Find guard by Email (to check login status)
  Map<String, dynamic>? getGuardByEmail(String email) {
    try {
      return _guards.firstWhere((g) => g['linkedUserEmail'] == email);
    } catch (e) {
      return null;
    }
  }

  /// Link a user to a guard profile (Enrollment)
  Future<bool> linkUserToGuard(String guardId, String email, String userName) async {
    final guard = await getGuardById(guardId);
    if (guard == null) return false;

    // If already active or pending with a different email, fail
    if (guard['status'] != 'created' && guard['linkedUserEmail'] != email) {
      return false;
    }

    await FirebaseFirestore.instance.collection('guards').doc(guardId).update({
      'status': 'pending',
      'linkedUserEmail': email,
      'linkedUserName': userName,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update local cache
    final index = _guards.indexWhere((g) => g['id'] == guardId || g['guardId'] == guardId);
    if (index != -1) {
      _guards[index] = {
        ..._guards[index],
        'status': 'pending',
        'linkedUserEmail': email,
        'linkedUserName': userName,
      };
    }

    return true;
  }

  /// Update status (Admin action)
  Future<void> updateGuardStatus(String id, String status) async {
    await _firestoreService.updateGuardStatus(id, status);

    // Update local cache
    final index = _guards.indexWhere((g) => g['id'] == id || g['guardId'] == id);
    if (index != -1) {
      _guards[index] = {
        ..._guards[index],
        'status': status,
      };
    }
  }

  /// Delete guard
  Future<void> deleteGuard(String id) async {
    await FirebaseFirestore.instance.collection('guards').doc(id).delete();
    _guards.removeWhere((g) => g['id'] == id || g['guardId'] == id);
  }
}
