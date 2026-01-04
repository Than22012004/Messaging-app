import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // 🔐 ĐĂNG KÝ
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = cred.user!.uid;

    // 🔥 LƯU USER VÀO FIRESTORE
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 🔐 ĐĂNG NHẬP
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
