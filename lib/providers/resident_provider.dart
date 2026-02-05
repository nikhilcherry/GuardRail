import 'package:flutter/material.dart';
import '../models/visitor.dart';
import '../repositories/visitor_repository.dart';
import '../services/logger_service.dart';

// Renamed from Visitor to ResidentVisitor to avoid conflict with model
class ResidentVisitor {
  final String id;
  final String name;
  final String type; // guest, delivery, service
  final String status; // approved, pending, rejected
  final DateTime date;
  final String? profileImage;

  ResidentVisitor({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.date,
    this.profileImage,
  });
}

class PreApprovedVisitor {
  final String id;
  final String name;
  final String type;
  final DateTime validUntil;
  final String? code;

  PreApprovedVisitor({
    required this.id,
    required this.name,
    required this.type,
    required this.validUntil,
    this.code,
  });
}

class ResidentProvider extends ChangeNotifier {
  final List<ResidentVisitor> _todaysVisitors = [];

  // Cache for pending approvals to avoid O(N) filtering on every build
  List<ResidentVisitor>? _cachedPendingApprovals;
  // Cache for all visitors to avoid O(N log N) sorting on every build
  List<ResidentVisitor>? _cachedAllVisitors;
  // Cache for grouped visitors to avoid O(N) grouping on every build
  Map<DateTime, List<ResidentVisitor>>? _cachedGroupedVisitors;

  final List<ResidentVisitor> _pastVisitors = [];

  final List<PreApprovedVisitor> _preApprovedVisitors = [];

  String _residentName = '';
  String _flatNumber = '';
  String _phoneNumber = '';
  String _email = '';
  String? _profileImage;
  DateTime? _lastLogin;
  int _pendingRequests = 0;
  bool _isLoading = false;

  List<ResidentVisitor> get todaysVisitors => _todaysVisitors;
  List<ResidentVisitor> get pastVisitors => _pastVisitors;
  List<PreApprovedVisitor> get preApprovedVisitors => _preApprovedVisitors;
  List<ResidentVisitor> get pendingVisitors => getPendingApprovals();
  List<ResidentVisitor> get allVisitors {
    if (_cachedAllVisitors != null) {
      return _cachedAllVisitors!;
    }
    _cachedAllVisitors = [..._todaysVisitors, ..._pastVisitors]
      ..sort((a, b) => b.date.compareTo(a.date));
    return _cachedAllVisitors!;
  }

  Map<DateTime, List<ResidentVisitor>> get groupedVisitors {
    if (_cachedGroupedVisitors != null) {
      return _cachedGroupedVisitors!;
    }

    _cachedGroupedVisitors = {};
    for (final v in allVisitors) {
      // Normalize date to UTC midnight to match TableCalendar requirements
      final date = DateTime.utc(v.date.year, v.date.month, v.date.day);
      if (_cachedGroupedVisitors![date] == null) {
        _cachedGroupedVisitors![date] = [];
      }
      _cachedGroupedVisitors![date]!.add(v);
    }
    return _cachedGroupedVisitors!;
  }
  
  String get residentName => _residentName;
  String get flatNumber => _flatNumber;
  String get phoneNumber => _phoneNumber;
  String get email => _email;
  String? get profileImage => _profileImage;
  DateTime? get lastLogin => _lastLogin;
  int get pendingRequests => _pendingRequests;
  bool get isLoading => _isLoading;

  ResidentProvider() {
    _loadData();
    // Listen to shared repository updates
    VisitorRepository().visitorStream.listen((updatedVisitors) {
      _todaysVisitors.clear();
      for (var v in updatedVisitors) {
        _todaysVisitors.add(ResidentVisitor(
          id: v.id,
          name: v.name,
          type: v.purpose,
          status: v.status.name, // Enum to String
          date: v.time,
        ));
      }
      _pendingRequests = _todaysVisitors.where((v) => v.status == 'pending').length;
      _cachedPendingApprovals = null;
      _cachedAllVisitors = null;
      _cachedGroupedVisitors = null;
       notifyListeners();
    });
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate getting last login
    _lastLogin = DateTime.now().subtract(const Duration(hours: 4));

    _isLoading = false;
    notifyListeners();
  }

  // Approve visitor request
  Future<void> approveVisitor(String visitorId) async {
    try {
      VisitorRepository().updateStatus(visitorId, VisitorStatus.approved);
    } catch (e) {
      rethrow;
    }
  }

  // Reject visitor request
  Future<void> rejectVisitor(String visitorId) async {
    try {
      VisitorRepository().updateStatus(visitorId, VisitorStatus.rejected);
    } catch (e) {
      rethrow;
    }
  }

  // Pre-approve a visitor with access code
  Future<String> preApproveVisitor({
    required String name,
    required String type,
    required DateTime validUntil,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      const accessCode = 'ABCD1234';
      
      final preApprovedVisitor = PreApprovedVisitor(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        type: type,
        validUntil: validUntil,
        code: accessCode,
      );
      
      _preApprovedVisitors.add(preApprovedVisitor);
      notifyListeners();
      
      return accessCode;
    } catch (e) {
      rethrow;
    }
  }

  // Get visitor history by type
  List<ResidentVisitor> getVisitorsByType(String type) {
    return [
      ..._todaysVisitors,
      ..._pastVisitors,
    ].where((v) => v.type == type).toList();
  }

  // Get all notifications
  List<ResidentVisitor> getPendingApprovals() {
    // OPTIMIZE: Return cached list if available
    if (_cachedPendingApprovals != null) {
      return _cachedPendingApprovals!;
    }
    _cachedPendingApprovals = _todaysVisitors.where((v) => v.status == 'pending').toList();
    return _cachedPendingApprovals!;
  }

  void updateResidentInfo({
    String? name,
    String? flatNumber,
    String? phoneNumber,
    String? email,
    String? profileImage,
  }) {
    if (name != null) _residentName = name;
    if (flatNumber != null) _flatNumber = flatNumber;
    if (phoneNumber != null) _phoneNumber = phoneNumber;
    if (email != null) _email = email;
    if (profileImage != null) _profileImage = profileImage;
    notifyListeners();
  }

  void logEmergency() {
    final timestamp = DateTime.now();
    // In a real application, this would send an API request to the backend.
    // SECURITY: Use LoggerService instead of print to prevent sensitive data leakage in release builds.
    LoggerService().info('EMERGENCY: Resident triggered SOS at $timestamp');
  }
}
