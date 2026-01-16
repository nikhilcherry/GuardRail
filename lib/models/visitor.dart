import 'package:cloud_firestore/cloud_firestore.dart';

enum VisitorStatus { pending, approved, rejected, exited }

class Visitor {
  final String id;
  final String name;
  final String flatNumber;
  final String purpose;
  VisitorStatus status;
  final DateTime time;
  DateTime? exitTime;
  final String? guardName;
  final String? photoPath;
  final String? vehicleNumber;
  final String? vehicleType;

  Visitor({
    required this.id,
    required this.name,
    required this.flatNumber,
    required this.purpose,
    required this.status,
    required this.time,
    this.exitTime,
    this.guardName,
    this.photoPath,
    this.vehicleNumber,
    this.vehicleType,
  });

  factory Visitor.fromFirestore(Map<String, dynamic> data, String docId) {
    return Visitor(
      id: docId,
      name: data['name'] ?? '',
      flatNumber: data['flatId'] ?? '',
      purpose: data['purpose'] ?? '',
      status: _parseStatus(data['status']),
      time: (data['arrivalTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      photoPath: data['photoUrl'],
      exitTime: (data['exitTime'] as Timestamp?)?.toDate(),
      vehicleNumber: data['vehicleNumber'],
      vehicleType: data['vehicleType'],
      guardName: data['guardName'],
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
