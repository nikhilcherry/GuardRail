import 'dart:async';

enum VisitorStatus { pending, approved, rejected }

class SharedVisitor {
  final String id;
  final String name;
  final String flatNumber;
  final String purpose;
  VisitorStatus status;
  final DateTime time;

  SharedVisitor({
    required this.id,
    required this.name,
    required this.flatNumber,
    required this.purpose,
    this.status = VisitorStatus.pending,
    required this.time,
  });
}

class VisitorRepository {
  static final VisitorRepository _instance = VisitorRepository._internal();
  factory VisitorRepository() => _instance;
  VisitorRepository._internal();

  final List<SharedVisitor> _visitors = [];
  final _controller = StreamController<List<SharedVisitor>>.broadcast();

  Stream<List<SharedVisitor>> get visitorStream => _controller.stream;

  List<SharedVisitor> get visitors => List.unmodifiable(_visitors);

  void addVisitor(SharedVisitor visitor) {
    _visitors.insert(0, visitor);
    _controller.add(List.from(_visitors));
  }

  void updateStatus(String id, VisitorStatus status) {
    final index = _visitors.indexWhere((v) => v.id == id);
    if (index != -1) {
      _visitors[index].status = status;
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
}
