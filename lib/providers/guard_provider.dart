import 'package:flutter/material.dart';
import '../models/guard_check.dart';
import '../models/visitor.dart';
import '../repositories/visitor_repository.dart';
import '../services/logger_service.dart';

class GuardProvider extends ChangeNotifier {
  final List<GuardCheck> _checks = [];
  // PERF: Cache scan signatures for O(1) duplicate lookup
  final Set<String> _scanSignatures = {};

  final List<Visitor> _entries = [
    // Mock initial data if needed, or empty
    Visitor(
      id: '1',
      name: 'John Doe',
      flatNumber: '4B',
      purpose: 'Guest',
      status: VisitorStatus.approved,
      time: DateTime.now().subtract(const Duration(minutes: 15)),
      guardName: 'Michael S.',
    ),
    Visitor(
      id: '2',
      name: 'Delivery Driver',
      flatNumber: '12A',
      purpose: 'Delivery',
      status: VisitorStatus.pending,
      time: DateTime.now().subtract(const Duration(minutes: 30)),
      guardName: 'David K.',
    ),
    Visitor(
      id: '3',
      name: 'Unknown Male',
      flatNumber: '2C',
      purpose: 'Other',
      status: VisitorStatus.rejected,
      time: DateTime.now().subtract(const Duration(minutes: 45)),
      guardName: 'Sarah J.',
    ),
  ];

  DateTime _lastPatrolCheck = DateTime.now().subtract(const Duration(minutes: 45));
  final List<DateTime> _patrolLogs = [];
  
  List<Visitor> _insideEntries = [];

  List<Visitor> get entries => _entries;
  // PERF: Expose cached filtered list for O(1) access
  List<Visitor> get insideEntries => _insideEntries;
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
      _entries.addAll(updatedVisitors);
      _updateInsideCache();
      notifyListeners();
    });
    // Initial cache update
    _updateInsideCache();
  }

  void _updateInsideCache() {
    // PERF: Cache filtered list to avoid O(N) calculation on every build
    _insideEntries = _entries
        .where((e) => e.status == VisitorStatus.approved && e.exitTime == null)
        .toList();
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
  Future<Visitor> registerNewVisitor({
    required String name,
    required String flatNumber,
    required String purpose,
    String? photoPath,
    String? vehicleNumber,
    String? vehicleType,
  }) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final time = DateTime.now();
      
      final newVisitor = Visitor(
        id: id,
        name: name,
        flatNumber: flatNumber,
        purpose: purpose,
        status: VisitorStatus.pending,
        time: time,
        photoPath: photoPath,
        vehicleNumber: vehicleNumber,
        vehicleType: vehicleType,
      );
      
      // Add to repository
      await VisitorRepository().addVisitor(newVisitor);

      // The repository stream will update _entries
      return newVisitor;
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

  // Mark visitor exit
  Future<void> markExit(String id) async {
    try {
      VisitorRepository().markExit(id);
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
    String? photoPath,
    String? vehicleNumber,
    String? vehicleType,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Update repository
      VisitorRepository().updateVisitor(
        id,
        name: name,
        flatNumber: flatNumber,
        purpose: purpose,
        photoPath: photoPath,
        vehicleNumber: vehicleNumber,
        vehicleType: vehicleType,
      );
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
  List<Visitor> getEntriesByStatus(String status) {
    // Helper to map string to enum if needed, or strict comparison
    // Status is now enum in Visitor model.
    // Assuming status passed is string name of enum?
    return _entries.where((entry) => entry.status.name == status).toList();
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
      final locationId = qrCode;

      // Duplicate Scan Protection
      final now = DateTime.now();

      // PERF: O(1) lookup using cached signature instead of O(N) list traversal
      // usage of '|' delimiter avoids collision with potential underscores in IDs
      final signature = '${guardId}|${locationId}|${now.year}-${now.month}-${now.day}';

      if (_scanSignatures.contains(signature)) {
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
      _scanSignatures.add(signature);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logEmergency() {
    final timestamp = DateTime.now();
    LoggerService().info('EMERGENCY: Guard triggered SOS at $timestamp');
  }
}
