import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ======================
  // CHAT ID
  // ======================
  String getChatId(String a, String b) {
    return a.compareTo(b) < 0 ? '${a}_$b' : '${b}_$a';
  }

  // ======================
  // STREAM MESSAGES
  // ======================
  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((e) => Message.fromMap(e.data(), id: e.id)).toList(),
        );
  }

  // ======================
  // SEND TEXT / LINK
  // ======================
  Future<void> sendText({
    required String chatId,
    required String text,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // update chat metadata
    await _firestore.collection('chats').doc(chatId).set(
      {'updatedAt': Timestamp.now()},
      SetOptions(merge: true),
    );

    // add message
    await _firestore.collection('chats').doc(chatId).collection('messages').add(
          Message(
            senderId: uid,
            type: 'text',
            text: text,
            createdAt: Timestamp.now(),
            isDeleted: false,
            isPinned: false,
          ).toMap(),
        );
  }

  // ======================
  // SEND FILE
  // ======================
  Future<void> sendFile({
    required String chatId,
    required String fileUrl,
    required String fileName,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // update chat metadata
    await _firestore.collection('chats').doc(chatId).set(
      {'updatedAt': Timestamp.now()},
      SetOptions(merge: true),
    );

    // add file message
    await _firestore.collection('chats').doc(chatId).collection('messages').add(
          Message(
            senderId: uid,
            type: 'file',
            fileUrl: fileUrl,
            fileName: fileName,
            createdAt: Timestamp.now(),
            isDeleted: false,
            isPinned: false,
          ).toMap(),
        );
  }

  // ======================
  // PIN MESSAGE
  // ======================
  Future<void> pinMessage({
    required String chatId,
    required String messageId,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'isPinned': true});
  }

  // ======================
  // DELETE MESSAGE
  // ======================
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'isDeleted': true,
      'text': 'Tin nhắn đã bị xoá',
    });
  }

  // ======================
  // MUTE / UNMUTE
  // ======================
  Future<void> muteChat({
    required String chatId,
    required String uid,
  }) async {
    await _firestore.collection('chats').doc(chatId).set(
      {
        'muted': {uid: true}
      },
      SetOptions(merge: true),
    );
  }

  Future<void> unmuteChat({
    required String chatId,
    required String uid,
  }) async {
    await _firestore.collection('chats').doc(chatId).set(
      {
        'muted': {uid: false}
      },
      SetOptions(merge: true),
    );
  }
}
