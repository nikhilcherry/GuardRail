import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/logger_service.dart';

enum VisitorStatus { pending, approved, rejected, exited }

class SharedVisitor {
  final String id;
  final String name;
  final String flatNumber;
  final String purpose;
  VisitorStatus status;
  final DateTime time;
  final String? vehicleNumber;
  final String? vehicleType;
  final String? photoPath;
  DateTime? exitTime;

  SharedVisitor({
    required this.id,
    required this.name,
    required this.flatNumber,
    required this.purpose,
    this.status = VisitorStatus.pending,
    required this.time,
    this.vehicleNumber,
    this.vehicleType,
    this.photoPath,
    this.exitTime,
  });

  /// Create SharedVisitor from Firestore document
  factory SharedVisitor.fromFirestore(Map<String, dynamic> data, String docId) {
    return SharedVisitor(
      id: docId,
      name: data['name'] ?? '',
      flatNumber: data['flatId'] ?? '',
      purpose: data['purpose'] ?? '',
      status: _parseStatus(data['status']),
      time: (data['arrivalTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      vehicleNumber: data['vehicleNumber'],
      vehicleType: data['vehicleType'],
      photoPath: data['photoUrl'],
      exitTime: (data['exitTime'] as Timestamp?)?.toDate(),
    );
  }

  static VisitorStatus _parseStatus(String? status) {
    switch (status) {
      case 'approved':
        return VisitorStatus.approved;
      case 'rejected':
        return VisitorStatus.rejected;
      case 'exited':
        return VisitorStatus.exited;
      default:
        return VisitorStatus.pending;
    }
  }

  String get statusString {
    switch (status) {
      case VisitorStatus.approved:
        return 'approved';
      case VisitorStatus.rejected:
        return 'rejected';
      case VisitorStatus.exited:
        return 'exited';
      case VisitorStatus.pending:
        return 'pending';
    }
  }
}

class VisitorRepository {
  static final VisitorRepository _instance = VisitorRepository._internal();
  factory VisitorRepository() => _instance;
  VisitorRepository._internal();

  final FirestoreService _firestoreService = FirestoreService();
  final List<SharedVisitor> _visitors = [];
  final _controller = StreamController<List<SharedVisitor>>.broadcast();
  StreamSubscription? _firestoreSubscription;
  bool _isInitialized = false;

  Stream<List<SharedVisitor>> get visitorStream => _controller.stream;
  List<SharedVisitor> get visitors => List.unmodifiable(_visitors);

  /// Initialize Firestore listener
  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    _firestoreSubscription = _firestoreService.getVisitorsStream().listen(
      (snapshot) {
        _visitors.clear();
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          _visitors.add(SharedVisitor.fromFirestore(data, doc.id));
        }
        _controller.add(List.from(_visitors));
      },
      onError: (error) {
        LoggerService().error('Firestore visitor stream error', error, StackTrace.current);
      },
    );
  }

  /// Dispose Firestore listener
  void dispose() {
    _firestoreSubscription?.cancel();
    _controller.close();
    _isInitialized = false;
  }

  /// Add visitor (creates in Firestore)
  Future<String> addVisitor(SharedVisitor visitor) async {
    final docId = await _firestoreService.addVisitor(
      name: visitor.name,
      flatId: visitor.flatNumber,
      purpose: visitor.purpose,
      photoUrl: visitor.photoPath,
      vehicleNumber: visitor.vehicleNumber,
      vehicleType: visitor.vehicleType,
      status: visitor.statusString,
    );

    // Also add to local cache for immediate UI update
    final newVisitor = SharedVisitor(
      id: docId,
      name: visitor.name,
      flatNumber: visitor.flatNumber,
      purpose: visitor.purpose,
      status: visitor.status,
      time: DateTime.now(),
      vehicleNumber: visitor.vehicleNumber,
      vehicleType: visitor.vehicleType,
      photoPath: visitor.photoPath,
    );
    _visitors.insert(0, newVisitor);
    _controller.add(List.from(_visitors));

    return docId;
  }

  /// Update visitor status (updates in Firestore)
  Future<void> updateStatus(String id, VisitorStatus status) async {
    await _firestoreService.updateVisitorStatus(id, status.name);

    // Update local cache
    final index = _visitors.indexWhere((v) => v.id == id);
    if (index != -1) {
      _visitors[index].status = status;
      _controller.add(List.from(_visitors));
    }
  }

  /// Update visitor details
  void updateVisitor(
    String id, {
    String? name,
    String? flatNumber,
    String? purpose,
    String? photoPath,
    String? vehicleNumber,
    String? vehicleType,
  }) {
    final index = _visitors.indexWhere((v) => v.id == id);
    if (index != -1) {
      final old = _visitors[index];
      _visitors[index] = SharedVisitor(
        id: old.id,
        name: name ?? old.name,
        flatNumber: flatNumber ?? old.flatNumber,
        purpose: purpose ?? old.purpose,
        status: old.status,
        time: old.time,
        photoPath: photoPath ?? old.photoPath,
        exitTime: old.exitTime,
        vehicleNumber: vehicleNumber ?? old.vehicleNumber,
        vehicleType: vehicleType ?? old.vehicleType,
      );
      _controller.add(List.from(_visitors));
    }
  }

  /// Mark visitor exit (updates in Firestore)
  Future<void> markExit(String id) async {
    await _firestoreService.updateVisitorStatus(id, 'exited');

    final index = _visitors.indexWhere((v) => v.id == id);
    if (index != -1) {
      _visitors[index].exitTime = DateTime.now();
      _visitors[index].status = VisitorStatus.exited;
      _controller.add(List.from(_visitors));
    }
  }

  SharedVisitor? getById(String id) {
    try {
      return _visitors.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Load visitors from Firestore (one-time fetch)
  Future<void> loadVisitors() async {
    final data = await _firestoreService.getVisitors();
    _visitors.clear();
    for (var item in data) {
      _visitors.add(SharedVisitor.fromFirestore(item, item['id']));
    }
    _controller.add(List.from(_visitors));
  }
}