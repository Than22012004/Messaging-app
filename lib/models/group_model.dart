import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final List<String> members;
  final String adminId;
  final Timestamp createdAt;

  Group({
    required this.id,
    required this.name,
    required this.members,
    required this.adminId,
    required this.createdAt,
  });

  factory Group.fromMap(String id, Map<String, dynamic> data) {
    return Group(
      id: id,
      name: data['name'],
      members: List<String>.from(data['members']),
      adminId: data['adminId'],
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'members': members,
      'adminId': adminId,
      'createdAt': createdAt,
    };
  }
}
