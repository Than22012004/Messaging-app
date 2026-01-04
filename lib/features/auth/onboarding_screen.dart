import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          _page('Chat nhóm', 'Nhắn tin nhanh chóng'),
          _page('Gửi file', 'Ảnh, PDF, tài liệu'),
          _page('Offline-first', 'Xem tin ngay cả khi mất mạng'),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: const Text('Bắt đầu'),
        ),
      ),
    );
  }

  Widget _page(String title, String subtitle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.chat, size: 80),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 10),
        Text(subtitle),
      ],
    );
  }
}
