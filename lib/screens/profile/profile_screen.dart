import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const primaryColor = Colors.lightBlue;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userService = UserService();
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cá nhân'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<AppUser?>(
        stream: userService.getUser(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data!;
          final firstChar =
              user.email.isNotEmpty ? user.email[0].toUpperCase() : '?';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ================= AVATAR =================
              Center(
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: primaryColor,
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          firstChar,
                          style: const TextStyle(
                            fontSize: 42,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ================= USER INFO =================
              _sectionTitle('Thông tin'),
              _infoTile(Icons.email, 'Email', user.email),
              _infoTile(Icons.badge, 'UID', user.uid),

              const SizedBox(height: 24),

              // ================= SETTINGS =================
              _sectionTitle('Cài đặt'),

              // DARK MODE
              SwitchListTile(
                value: theme.isDark,
                onChanged: (_) => theme.toggleTheme(!theme.isDark),
                secondary: const Icon(Icons.dark_mode),
                title: const Text('Chế độ tối'),
              ),

              // APP INFO
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Thông tin ứng dụng'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showAppInfo(context),
              ),

              const Divider(),

              // LOGOUT
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (_) => false,
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= UI HELPERS =================
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  // ================= APP INFO =================
  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thông tin ứng dụng'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tên app: Flutter Chat App'),
            SizedBox(height: 6),
            Text('Phiên bản: 1.0.0'),
            SizedBox(height: 6),
            Text('Môn học: Lập trình thiết bị di động'),
            SizedBox(height: 6),
            Text('Sinh viên thực hiện'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
