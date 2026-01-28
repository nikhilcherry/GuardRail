import 'dart:async';
import '../models/visitor.dart';
import '../services/firestore_service.dart';
import '../services/logger_service.dart';

class VisitorRepository {
  static final VisitorRepository _instance = VisitorRepository._internal();
  factory VisitorRepository() => _instance;
  VisitorRepository._internal();

  final FirestoreService _firestoreService = FirestoreService();
  final List<Visitor> _visitors = [];
  final _controller = StreamController<List<Visitor>>.broadcast();
  StreamSubscription? _firestoreSubscription;
  bool _isInitialized = false;

  Stream<List<Visitor>> get visitorStream => _controller.stream;
  List<Visitor> get visitors => List.unmodifiable(_visitors);

  /// Initialize Firestore listener
  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    _firestoreSubscription = _firestoreService.getVisitorsStream().listen(
      (snapshot) {
        _visitors.clear();
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          _visitors.add(Visitor.fromFirestore(data, doc.id));
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
  Future<String> addVisitor(Visitor visitor) async {
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
    // Note: We use the returned docId
    final newVisitor = Visitor(
      id: docId,
      name: visitor.name,
      flatNumber: visitor.flatNumber,
      purpose: visitor.purpose,
      status: visitor.status,
      time: DateTime.now(),
      vehicleNumber: visitor.vehicleNumber,
      vehicleType: visitor.vehicleType,
      photoPath: visitor.photoPath,
      guardName: visitor.guardName,
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
      _visitors[index] = Visitor(
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
        guardName: old.guardName,
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

  Visitor? getById(String id) {
    try {
      return _visitors.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

}
