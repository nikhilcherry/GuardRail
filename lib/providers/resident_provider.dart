import 'package:flutter/material.dart';
import '../repositories/visitor_repository.dart';

class Visitor {
  final String id;
  final String name;
  final String type; // guest, delivery, service
  final String status; // approved, pending, rejected
  final DateTime date;
  final String? profileImage;

  Visitor({
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
  final List<Visitor> _todaysVisitors = [
    Visitor(
      id: '1',
      name: 'Amazon Delivery',
      type: 'delivery',
      status: 'approved',
      date: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
    ),
    Visitor(
      id: '2',
      name: 'John Doe',
      type: 'guest',
      status: 'pending',
      date: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  // Cache for pending approvals to avoid O(N) filtering on every build
  List<Visitor>? _cachedPendingApprovals;
  // Cache for all visitors to avoid O(N log N) sorting on every build
  List<Visitor>? _cachedAllVisitors;

  final List<Visitor> _pastVisitors = [
    Visitor(
      id: '3',
      name: 'Plumber Service',
      type: 'service',
      status: 'rejected',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Visitor(
      id: '4',
      name: 'Sarah Smith',
      type: 'guest',
      status: 'approved',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  final List<PreApprovedVisitor> _preApprovedVisitors = [];

  String _residentName = 'Robert';
  String _flatNumber = '402';
  String _phoneNumber = '+91 98765 43210';
  String _email = 'robert@example.com';
  String? _profileImage;
  DateTime? _lastLogin;
  int _pendingRequests = 1;
  bool _isLoading = false;

  List<Visitor> get todaysVisitors => _todaysVisitors;
  List<Visitor> get pastVisitors => _pastVisitors;
  List<PreApprovedVisitor> get preApprovedVisitors => _preApprovedVisitors;
  List<Visitor> get allVisitors {
    if (_cachedAllVisitors != null) {
      return _cachedAllVisitors!;
    }
    _cachedAllVisitors = [..._todaysVisitors, ..._pastVisitors]
      ..sort((a, b) => b.date.compareTo(a.date));
    return _cachedAllVisitors!;
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
        _todaysVisitors.add(Visitor(
          id: v.id,
          name: v.name,
          type: v.purpose,
          status: v.status.name,
          date: v.time,
        ));
      }
      _pendingRequests = _todaysVisitors.where((v) => v.status == 'pending').length;
      _cachedPendingApprovals = null;
      _cachedAllVisitors = null;
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
  List<Visitor> getVisitorsByType(String type) {
    return [
      ..._todaysVisitors,
      ..._pastVisitors,
    ].where((v) => v.type == type).toList();
  }

  // Get all notifications
  List<Visitor> getPendingApprovals() {
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
}
