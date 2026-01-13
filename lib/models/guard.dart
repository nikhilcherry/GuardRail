import 'package:cloud_firestore/cloud_firestore.dart';

class Guard {
  final String id;
  final String guardId; // Display ID (e.g., generated 6-char code)
  final String name;
  final String status; // created, pending, active, rejected
  final String? societyId;
  final String? linkedUserEmail;
  final String? linkedUserName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Guard({
    required this.id,
    required this.guardId,
    required this.name,
    required this.status,
    this.societyId,
    this.linkedUserEmail,
    this.linkedUserName,
    this.createdAt,
    this.updatedAt,
  });

  factory Guard.fromFirestore(Map<String, dynamic> data, String docId) {
    return Guard(
      id: docId,
      guardId: data['guardId'] ?? docId,
      name: data['name'] ?? '',
      status: data['status'] ?? 'created',
      societyId: data['societyId'],
      linkedUserEmail: data['linkedUserEmail'],
      linkedUserName: data['linkedUserName'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory Guard.fromMap(Map<String, dynamic> data) {
    return Guard(
      id: data['id'] ?? '',
      guardId: data['guardId'] ?? '',
      name: data['name'] ?? '',
      status: data['status'] ?? 'created',
      societyId: data['societyId'],
      linkedUserEmail: data['linkedUserEmail'],
      linkedUserName: data['linkedUserName'],
      createdAt: data['createdAt'] is DateTime
          ? data['createdAt']
          : (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: data['updatedAt'] is DateTime
          ? data['updatedAt']
          : (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'guardId': guardId,
      'name': name,
      'status': status,
      'societyId': societyId,
      'linkedUserEmail': linkedUserEmail,
      'linkedUserName': linkedUserName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
