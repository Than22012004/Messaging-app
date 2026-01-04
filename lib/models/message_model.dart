import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String? id;
  final String senderId;
  final String? text;
  final String type;
  final String? fileUrl;
  final String? fileName;
  final bool isPinned;
  final bool isDeleted;
  final Timestamp createdAt;

  Message({
    this.id,
    required this.senderId,
    this.text,
    required this.type,
    this.fileUrl,
    this.fileName,
    this.isPinned = false,
    this.isDeleted = false,
    required this.createdAt,
  });

  factory Message.fromMap(Map<String, dynamic> map, {String? id}) {
    return Message(
      id: id,
      senderId: map['senderId'],
      text: map['text'],
      type: map['type'],
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      isPinned: map['isPinned'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'type': type,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'isPinned': isPinned,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
    };
  }
}
