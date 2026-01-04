import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

import '../../services/cloudinary_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  File? _avatarFile;

  static const primaryColor = Colors.lightBlue;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  // ================= PICK AVATAR =================
  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _avatarFile = File(result.files.single.path!);
      });
    }
  }

  // ================= REGISTER =================
  Future<void> _register() async {
    if (nameCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        passCtrl.text.isEmpty ||
        confirmCtrl.text.isEmpty) {
      _showSnackBar('Vui lòng nhập đầy đủ thông tin', Colors.orange);
      return;
    }

    if (passCtrl.text.length < 6) {
      _showSnackBar('Mật khẩu tối thiểu 6 ký tự', Colors.orange);
      return;
    }

    if (passCtrl.text != confirmCtrl.text) {
      _showSnackBar('Mật khẩu không khớp', Colors.redAccent);
      return;
    }

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      final uid = cred.user!.uid;

      // ===== UPLOAD AVATAR (NẾU CÓ) =====
      String? avatarUrl;
      if (_avatarFile != null) {
        avatarUrl = await CloudinaryService.uploadImage(_avatarFile!);
      }

      // ===== SAVE FIRESTORE =====
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': nameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'avatarUrl': avatarUrl,
        'createdAt': Timestamp.now(),
      });

      await cred.user!.updateDisplayName(nameCtrl.text.trim());

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      _showSnackBar(_firebaseError(e.code), Colors.redAccent);
    } catch (e) {
      _showSnackBar('Đăng ký thất bại', Colors.redAccent);
    }
  }

  String _firebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email đã được sử dụng';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'weak-password':
        return 'Mật khẩu quá yếu';
      default:
        return 'Lỗi đăng ký';
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Đăng ký tài khoản',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ===== AVATAR =====
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: primaryColor,
                  backgroundImage:
                      _avatarFile != null ? FileImage(_avatarFile!) : null,
                  child: _avatarFile == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: primaryColor,
                  onPressed: _pickAvatar,
                  child: const Icon(Icons.camera_alt, size: 18),
                ),
              ],
            ),

            const SizedBox(height: 32),

            _buildCard(),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'TẠO TÀI KHOẢN',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _field(nameCtrl, 'Họ tên', Icons.person),
          const SizedBox(height: 16),
          _field(emailCtrl, 'Email', Icons.email,
              type: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _field(passCtrl, 'Mật khẩu', Icons.lock, pass: true),
          const SizedBox(height: 16),
          _field(confirmCtrl, 'Nhập lại mật khẩu', Icons.lock_reset,
              pass: true),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool pass = false,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: pass,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
