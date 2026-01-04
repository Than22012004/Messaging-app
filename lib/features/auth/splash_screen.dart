import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ===== LOGO =====
            const FlutterLogo(size: 140),

            const SizedBox(height: 32),

            const Text(
              'Flutter Chat App',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            // ===== LOGIN BUTTON =====
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('Đăng nhập'),
              ),
            ),

            const SizedBox(height: 12),

            // ===== REGISTER BUTTON =====
            SizedBox(
              width: 220,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Tạo tài khoản'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
