import 'package:flutter/material.dart';

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
  int _pendingRequests = 1;

  List<Visitor> get todaysVisitors => _todaysVisitors;
  List<Visitor> get pastVisitors => _pastVisitors;
  List<PreApprovedVisitor> get preApprovedVisitors => _preApprovedVisitors;
  List<Visitor> get allVisitors =>
      [..._todaysVisitors, ..._pastVisitors]..sort((a, b) => b.date.compareTo(a.date));
  
  String get residentName => _residentName;
  String get flatNumber => _flatNumber;
  int get pendingRequests => _pendingRequests;

  // Approve visitor request
  Future<void> approveVisitor(String visitorId) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _todaysVisitors.indexWhere((v) => v.id == visitorId);
      if (index != -1) {
        final visitor = _todaysVisitors[index];
        _todaysVisitors[index] = Visitor(
          id: visitor.id,
          name: visitor.name,
          type: visitor.type,
          status: 'approved',
          date: visitor.date,
          profileImage: visitor.profileImage,
        );
        _pendingRequests = _todaysVisitors.where((v) => v.status == 'pending').length;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Reject visitor request
  Future<void> rejectVisitor(String visitorId) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _todaysVisitors.indexWhere((v) => v.id == visitorId);
      if (index != -1) {
        final visitor = _todaysVisitors[index];
        _todaysVisitors[index] = Visitor(
          id: visitor.id,
          name: visitor.name,
          type: visitor.type,
          status: 'rejected',
          date: visitor.date,
          profileImage: visitor.profileImage,
        );
        _pendingRequests = _todaysVisitors.where((v) => v.status == 'pending').length;
        notifyListeners();
      }
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
    return _todaysVisitors.where((v) => v.status == 'pending').toList();
  }

  void updateResidentInfo({String? name, String? flatNumber}) {
    if (name != null) _residentName = name;
    if (flatNumber != null) _flatNumber = flatNumber;
    notifyListeners();
  }
}
