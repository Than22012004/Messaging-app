import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =====================
  // ĐĂNG KÝ
  // =====================
  Future<User?> register({
    required String email,
    required String password,
  }) async {
    final UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  // =====================
  // ĐĂNG NHẬP
  // =====================
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  // =====================
  // ĐĂNG XUẤT
  // =====================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // =====================
  // KIỂM TRA LOGIN
  // =====================
  User? get currentUser => _auth.currentUser;

  bool isLoggedIn() {
    return _auth.currentUser != null;
  }
}
