import 'package:cloud_firestore/cloud_firestore.dart';

class ChatActionService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> pinMessage({
    required String collection, // 'chats' | 'groups'
    required String chatId,
    required String messageId,
  }) async {
    await _firestore
        .collection(collection)
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'isPinned': true});
  }

  Future<void> deleteMessage({
    required String collection,
    required String chatId,
    required String messageId,
  }) async {
    await _firestore
        .collection(collection)
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'isDeleted': true,
      'text': 'Tin nhắn đã bị xoá',
    });
  }
}
