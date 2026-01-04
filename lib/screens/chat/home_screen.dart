import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/chat_service.dart';
import '../chat/private_chat_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const primaryColor = Colors.lightBlue;

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    final chatService = ChatService();
    final currentUser = FirebaseAuth.instance.currentUser!;
    final currentUid = currentUser.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Friends',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            tooltip: 'Nhóm chat',
            onPressed: () {
              Navigator.pushNamed(context, '/groups');
            },
          ),
          IconButton(
            icon: const Icon(Icons.group_add),
            tooltip: 'Tạo nhóm',
            onPressed: () {
              Navigator.pushNamed(context, '/create-group');
            },
          ),

          // ===== PROFILE / LOGOUT =====
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              }

              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (_) => false,
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Trang cá nhân'),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Đăng xuất',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      // ================= FRIEND LIST =================
      body: StreamBuilder<List<AppUser>>(
        stream: userService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có bạn bè'));
          }

          final users =
              snapshot.data!.where((u) => u.uid != currentUid).toList();

          if (users.isEmpty) {
            return const Center(child: Text('Chỉ có mình bạn'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final chatId = chatService.getChatId(currentUid, user.uid);

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: primaryColor,
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Text(
                            user.email.isNotEmpty
                                ? user.email[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
                  ),
                  title: Text(
                    user.email,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Nhấn để chat'),
                  trailing: const Icon(
                    Icons.chat_bubble_outline,
                    color: primaryColor,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PrivateChatScreen(
                          chatId: chatId,
                          receiverName: user.email,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
