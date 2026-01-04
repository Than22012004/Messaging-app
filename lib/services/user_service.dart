import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ======================
  // GET ALL USERS
  // ======================
  Stream<List<AppUser>> getAllUsers() {
    return _firestore.collection('users').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => AppUser.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // ======================
  // GET SINGLE USER
  // ======================
  Stream<AppUser?> getUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromMap(doc.id, doc.data()!);
    });
  }

  // ======================
  // CREATE USER (SAFE)
  // ======================
  Future<void> createUser({
    required String uid,
    required String email,
  }) async {
    await _firestore.collection('users').doc(uid).set(
      {
        'email': email,
        'avatarUrl': null,
        'createdAt': Timestamp.now(),
      },
      SetOptions(merge: true), // ⭐ QUAN TRỌNG
    );
  }

  // ======================
  // UPDATE AVATAR
  // ======================
  Future<void> updateAvatar({
    required String uid,
    required String avatarUrl,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'avatarUrl': avatarUrl,
    });
  }
}
