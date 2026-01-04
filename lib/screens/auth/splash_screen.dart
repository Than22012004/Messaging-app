import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // ❌ CHƯA LOGIN → LOGIN
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // ✅ ĐÃ LOGIN → HOME
        Navigator.pushReplacementNamed(context, '/home');
      }
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
