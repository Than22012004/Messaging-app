import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký tài khoản')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Họ tên'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nhập lại mật khẩu'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (passCtrl.text != confirmCtrl.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mật khẩu không khớp')),
                  );
                  return;
                }

                try {
                  // 1️⃣ CREATE AUTH
                  final cred = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: emailCtrl.text.trim(),
                    password: passCtrl.text.trim(),
                  );

                  final uid = cred.user!.uid;

                  // 2️⃣ SAVE TO FIRESTORE (QUAN TRỌNG)
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .set({
                    'uid': uid,
                    'email': emailCtrl.text.trim(),
                    'name': nameCtrl.text.trim(),
                    'createdAt': Timestamp.now(),
                  });

                  // 3️⃣ UPDATE DISPLAY NAME
                  await cred.user!.updateDisplayName(nameCtrl.text.trim());

                  Navigator.pushReplacementNamed(context, '/home');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text('Tạo tài khoản'),
            ),
          ],
        ),
      ),
    );
  }
}
