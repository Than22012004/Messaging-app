import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message_model.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ======================
  // CREATE GROUP
  // ======================
  Future<void> createGroup({
    required String name,
    required List<String> members,
  }) async {
    final uid = _auth.currentUser!.uid;

    await _firestore.collection('groups').add({
      'name': name,
      'adminId': uid,
      'members': members,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  // ======================
  // GET USER GROUPS
  // ======================
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserGroups(String uid) {
    return _firestore
        .collection('groups')
        .where('members', arrayContains: uid)
        .snapshots();
  }

  // ======================
  // CHECK ADMIN
  // ======================
  Future<bool> isAdmin({
    required String groupId,
    required String uid,
  }) async {
    final doc = await _firestore.collection('groups').doc(groupId).get();
    if (!doc.exists) return false;
    return doc.data()!['adminId'] == uid;
  }

  // ======================
  // REMOVE MEMBER
  // ======================
  Future<void> removeMember({
    required String groupId,
    required String memberId,
  }) async {
    await _firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([memberId]),
    });
  }

  // ======================
  // LEAVE GROUP
  // ======================
  Future<void> leaveGroup({
    required String groupId,
    required String uid,
  }) async {
    final doc = await _firestore.collection('groups').doc(groupId).get();
    if (!doc.exists) throw Exception('Nhóm không tồn tại');

    if (doc.data()!['adminId'] == uid) {
      throw Exception('Admin không thể rời nhóm');
    }

    await _firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([uid]),
    });
  }

  // ======================
  // STREAM GROUP MESSAGES
  // ======================
  Stream<List<Message>> getMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
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
    required String groupId,
    required String text,
  }) async {
    final uid = _auth.currentUser!.uid;

    await _firestore.collection('groups').doc(groupId).update({
      'updatedAt': Timestamp.now(),
    });

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add(
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
  // SEND FILE (IMAGE / PDF / DOC ...)
  // ======================
  Future<void> sendFile({
    required String groupId,
    required String fileUrl,
    required String fileName,
  }) async {
    final uid = _auth.currentUser!.uid;

    await _firestore.collection('groups').doc(groupId).update({
      'updatedAt': Timestamp.now(),
    });

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add(
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
    required String groupId,
    required String messageId,
  }) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .update({'isPinned': true});
  }

  // ======================
  // DELETE MESSAGE
  // ======================
  Future<void> deleteMessage({
    required String groupId,
    required String messageId,
  }) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .update({
      'isDeleted': true,
      'text': 'Tin nhắn đã bị xoá',
    });
  }

  // ======================
  // MUTE / UNMUTE GROUP
  // ======================
  Future<void> muteGroup({
    required String groupId,
    required String uid,
  }) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('userSettings')
        .doc(uid)
        .set({'muted': true}, SetOptions(merge: true));
  }

  Future<void> unmuteGroup({
    required String groupId,
    required String uid,
  }) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('userSettings')
        .doc(uid)
        .set({'muted': false}, SetOptions(merge: true));
  }
}
