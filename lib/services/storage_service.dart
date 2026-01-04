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

    await _send(
      chatId,
      Message(
        senderId: uid,
        type: 'text',
        text: text,
        createdAt: Timestamp.now(),
      ),
    );
  }

  // ======================
  // INTERNAL SEND
  // ======================
  Future<void> _send(String chatId, Message message) async {
    await _firestore.collection('chats').doc(chatId).set(
      {'updatedAt': Timestamp.now()},
      SetOptions(merge: true),
    );

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());
  }
}
