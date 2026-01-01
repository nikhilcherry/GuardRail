import 'package:flutter/material.dart';

class VisitorEntry {
  final String id;
  final String name;
  final String flatNumber;
  final String purpose;
  final String status; // approved, pending, rejected
  final DateTime time;
  final String? guardName;

  VisitorEntry({
    required this.id,
    required this.name,
    required this.flatNumber,
    required this.purpose,
    required this.status,
    required this.time,
    this.guardName,
  });
}

class GuardProvider extends ChangeNotifier {
  final List<VisitorEntry> _entries = [
    VisitorEntry(
      id: '1',
      name: 'John Doe',
      flatNumber: '4B',
      purpose: 'Guest',
      status: 'approved',
      time: DateTime.now().subtract(const Duration(minutes: 15)),
      guardName: 'Michael S.',
    ),
    VisitorEntry(
      id: '2',
      name: 'Delivery Driver',
      flatNumber: '12A',
      purpose: 'Delivery',
      status: 'pending',
      time: DateTime.now().subtract(const Duration(minutes: 30)),
      guardName: 'David K.',
    ),
    VisitorEntry(
      id: '3',
      name: 'Unknown Male',
      flatNumber: '2C',
      purpose: 'Other',
      status: 'rejected',
      time: DateTime.now().subtract(const Duration(minutes: 45)),
      guardName: 'Sarah J.',
    ),
  ];

  DateTime _lastPatrolCheck = DateTime.now().subtract(const Duration(minutes: 45));
  final List<DateTime> _patrolLogs = [];
  
  List<VisitorEntry> get entries => _entries;
  DateTime get lastPatrolCheck => _lastPatrolCheck;
  List<DateTime> get patrolLogs => _patrolLogs;
  bool _isLoading = false;
  
  bool get isLoading => _isLoading;

  GuardProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();
  }

  // Register new visitor
  Future<VisitorEntry> registerNewVisitor({
    required String name,
    required String flatNumber,
    required String purpose,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final newEntry = VisitorEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        flatNumber: flatNumber,
        purpose: purpose,
        status: 'pending',
        time: DateTime.now(),
        guardName: 'Guard',
      );
      
      _entries.insert(0, newEntry);
      notifyListeners();
      return newEntry;
    } catch (e) {
      rethrow;
    }
  }

  // Approve visitor
  Future<void> approveVisitor(String id) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _entries.indexWhere((entry) => entry.id == id);
      if (index != -1) {
        _entries[index] = VisitorEntry(
          id: _entries[index].id,
          name: _entries[index].name,
          flatNumber: _entries[index].flatNumber,
          purpose: _entries[index].purpose,
          status: 'approved',
          time: _entries[index].time,
          guardName: _entries[index].guardName,
        );
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Reject visitor
  Future<void> rejectVisitor(String id) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _entries.indexWhere((entry) => entry.id == id);
      if (index != -1) {
        _entries[index] = VisitorEntry(
          id: _entries[index].id,
          name: _entries[index].name,
          flatNumber: _entries[index].flatNumber,
          purpose: _entries[index].purpose,
          status: 'rejected',
          time: _entries[index].time,
          guardName: _entries[index].guardName,
        );
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update visitor entry
  Future<void> updateVisitorEntry({
    required String id,
    required String name,
    required String flatNumber,
    required String purpose,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final index = _entries.indexWhere((entry) => entry.id == id);
      if (index != -1) {
        final oldEntry = _entries[index];
        _entries[index] = VisitorEntry(
          id: oldEntry.id,
          name: name,
          flatNumber: flatNumber,
          purpose: purpose,
          status: oldEntry.status,
          time: oldEntry.time,
          guardName: oldEntry.guardName,
        );
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Patrol check-in
  Future<void> patrolCheckIn() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      _lastPatrolCheck = DateTime.now();
      _patrolLogs.insert(0, _lastPatrolCheck);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Get entries by status
  List<VisitorEntry> getEntriesByStatus(String status) {
    return _entries.where((entry) => entry.status == status).toList();
  }
}
