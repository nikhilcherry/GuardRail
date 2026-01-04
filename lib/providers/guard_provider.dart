import 'package:flutter/material.dart';
import '../repositories/visitor_repository.dart';

class VisitorEntry {
  final String id;
  final String name;
  final String flatNumber;
  final String purpose;
  final String status; // approved, pending, rejected
  final DateTime time;
  final String? guardName;
  final String? vehicleNumber;

  VisitorEntry({
    required this.id,
    required this.name,
    required this.flatNumber,
    required this.purpose,
    required this.status,
    required this.time,
    this.guardName,
    this.vehicleNumber,
  });
}

class GuardCheck {
  final String id;
  final String locationId;
  final String guardId;
  final DateTime timestamp;
  final String photoPath;

  GuardCheck({
    required this.id,
    required this.locationId,
    required this.guardId,
    required this.timestamp,
    required this.photoPath,
  });
}

class GuardProvider extends ChangeNotifier {
  final List<GuardCheck> _checks = [];
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
  List<GuardCheck> get checks => _checks;
  DateTime get lastPatrolCheck => _lastPatrolCheck;
  List<DateTime> get patrolLogs => _patrolLogs;
  bool get isLoading => _isLoading;
  bool _isLoading = false;

  GuardProvider() {
    _loadData();
    // Listen to shared repository updates
    VisitorRepository().visitorStream.listen((updatedVisitors) {
      _entries.clear();
      for (var v in updatedVisitors) {
        _entries.add(VisitorEntry(
          id: v.id,
          name: v.name,
          flatNumber: v.flatNumber,
          purpose: v.purpose,
          status: v.status.name,
          time: v.time,
        ));
      }
      notifyListeners();
    });
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
    String? vehicleNumber,
  }) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final time = DateTime.now();
      
      final newShared = SharedVisitor(
        id: id,
        name: name,
        flatNumber: flatNumber,
        purpose: purpose,
        status: VisitorStatus.pending,
        time: time,
      );
      
      VisitorRepository().addVisitor(newShared);

      final newEntry = VisitorEntry(
        id: id,
        name: name,
        flatNumber: flatNumber,
        purpose: purpose,
        status: 'pending',
        time: time,
        guardName: 'Guard',
        vehicleNumber: vehicleNumber,
      );
      
      return newEntry;
    } catch (e) {
      rethrow;
    }
  }

  // Approve visitor
  Future<void> approveVisitor(String id) async {
    try {
      VisitorRepository().updateStatus(id, VisitorStatus.approved);
    } catch (e) {
      rethrow;
    }
  }

  // Reject visitor
  Future<void> rejectVisitor(String id) async {
    try {
      VisitorRepository().updateStatus(id, VisitorStatus.rejected);
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
    String? vehicleNumber,
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
          vehicleNumber: vehicleNumber ?? oldEntry.vehicleNumber,
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

  // Process a new guard check scan
  Future<void> processScan({
    required String qrCode,
    required String photoPath,
    required String guardId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate network validation delay
      await Future.delayed(const Duration(seconds: 1));

      // Simple parsing: assuming qrCode is the location ID for this MVP
      // In a real app, this would be a signed token that we verify with the backend
      final locationId = qrCode;

      // Duplicate Scan Protection
      // Block same guard from scanning same QR twice per day
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      final isDuplicate = _checks.any((check) =>
          check.guardId == guardId &&
          check.locationId == locationId &&
          check.timestamp.isAfter(todayStart));

      if (isDuplicate) {
        throw Exception('Duplicate scan: You have already checked this location today.');
      }

      // Add check
      _checks.insert(
          0,
          GuardCheck(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            locationId: locationId,
            guardId: guardId,
            timestamp: now,
            photoPath: photoPath,
          ));
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logEmergency() {
    final timestamp = DateTime.now();
    // In a real application, this would send an API request to the backend.
    print('EMERGENCY: Guard triggered SOS at $timestamp');
  }
}
