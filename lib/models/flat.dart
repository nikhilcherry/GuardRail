import 'package:cloud_firestore/cloud_firestore.dart';

enum MemberStatus { pending, accepted }
enum MemberRole { owner, member }
enum FlatStatus { pending, active, rejected }

class FlatMember {
  final String userId;
  final String name;
  MemberStatus status;
  final MemberRole role;

  FlatMember({
    required this.userId,
    required this.name,
    this.status = MemberStatus.pending,
    this.role = MemberRole.member,
  });

  factory FlatMember.fromMap(Map<String, dynamic> data) {
    return FlatMember(
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      status: data['status'] == 'accepted' ? MemberStatus.accepted : MemberStatus.pending,
      role: data['role'] == 'owner' ? MemberRole.owner : MemberRole.member,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'status': status == MemberStatus.accepted ? 'accepted' : 'pending',
      'role': role == MemberRole.owner ? 'owner' : 'member',
    };
  }
}

class Flat {
  final String id;
  String name;
  final String ownerId;
  FlatStatus status;
  final List<FlatMember> members;

  Flat({
    required this.id,
    required this.name,
    required this.ownerId,
    this.status = FlatStatus.pending,
    this.members = const [],
  });

  factory Flat.fromFirestore(Map<String, dynamic> data, String docId) {
    final membersData = data['members'] as List<dynamic>? ?? [];
    return Flat(
      id: docId,
      name: data['name'] ?? '',
      ownerId: data['ownerId'] ?? '',
      status: _parseStatus(data['status']),
      members: membersData
          .map((m) => FlatMember.fromMap(m as Map<String, dynamic>))
          .toList(),
    );
  }

  static FlatStatus _parseStatus(String? status) {
    switch (status) {
      case 'active':
        return FlatStatus.active;
      case 'rejected':
        return FlatStatus.rejected;
      default:
        return FlatStatus.pending;
    }
  }

  String get statusString {
    switch (status) {
      case FlatStatus.active:
        return 'active';
      case FlatStatus.rejected:
        return 'rejected';
      case FlatStatus.pending:
        return 'pending';
    }
  }
}
