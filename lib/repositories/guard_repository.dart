import 'dart:math';

class GuardRepository {
  // Singleton pattern
  static final GuardRepository _instance = GuardRepository._internal();
  factory GuardRepository() => _instance;
  GuardRepository._internal();

  // In-memory storage for guards
  // Structure: {
  //   'id': 'G-1234',
  //   'name': 'John Doe', (Name given by Admin)
  //   'status': 'created', // created, pending, active, rejected
  //   'linkedUserEmail': null,
  //   'linkedUserName': null, // Name from User Signup
  //   'createdAt': DateTime...
  // }
  final List<Map<String, dynamic>> _guards = [];

  List<Map<String, dynamic>> getAllGuards() {
    return List.from(_guards);
  }

  // Create a new guard profile (Admin action)
  String createGuard(String name, {String? manualId}) {
    String id;
    if (manualId != null && manualId.trim().isNotEmpty) {
      id = manualId.trim();
      if (_guards.any((g) => g['id'] == id)) {
        throw Exception('Guard ID already exists');
      }
    } else {
      id = _generateGuardId();
    }

    _guards.add({
      'id': id,
      'name': name,
      'status': 'created',
      'createdAt': DateTime.now(),
    });
    return id;
  }

  // Update existing guard
  void updateGuard(String originalId, {String? name, String? newId}) {
    final index = _guards.indexWhere((g) => g['id'] == originalId);
    if (index == -1) throw Exception('Guard not found');

    var guard = _guards[index];

    if (newId != null && newId != originalId) {
      if (_guards.any((g) => g['id'] == newId)) {
        throw Exception('Guard ID already exists');
      }
      guard = {...guard, 'id': newId};
    }

    if (name != null) {
      guard = {...guard, 'name': name};
    }

    _guards[index] = guard;
  }

  // Generate a unique ID (Mixed case + numbers)
  String _generateGuardId() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    String id;
    do {
      final code = String.fromCharCodes(Iterable.generate(
          6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
      id = code;
    } while (_guards.any((g) => g['id'] == id));
    return id;
  }

  // Find guard by ID
  Map<String, dynamic>? getGuardById(String id) {
    try {
      return _guards.firstWhere((g) => g['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Find guard by Email (to check login status)
  Map<String, dynamic>? getGuardByEmail(String email) {
    try {
      return _guards.firstWhere((g) => g['linkedUserEmail'] == email);
    } catch (e) {
      return null;
    }
  }

  // Link a user to a guard profile (Enrollment)
  // Returns true if successful, false if ID not found or already taken
  bool linkUserToGuard(String guardId, String email, String userName) {
    final index = _guards.indexWhere((g) => g['id'] == guardId);
    if (index == -1) return false;

    final guard = _guards[index];

    // If already active or pending with a different email, fail
    if (guard['status'] != 'created' && guard['linkedUserEmail'] != email) {
      return false;
    }

    _guards[index] = {
      ...guard,
      'status': 'pending',
      'linkedUserEmail': email,
      'linkedUserName': userName,
    };
    return true;
  }

  // Update status (Admin action)
  void updateGuardStatus(String id, String status) {
    final index = _guards.indexWhere((g) => g['id'] == id);
    if (index != -1) {
      _guards[index] = {
        ..._guards[index],
        'status': status,
      };
    }
  }

  // Delete guard
  void deleteGuard(String id) {
    _guards.removeWhere((g) => g['id'] == id);
  }
}
