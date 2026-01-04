import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/group_service.dart';
import 'group_chat_screen.dart';

class GroupListScreen extends StatelessWidget {
  GroupListScreen({super.key});

  final GroupService _groupService = GroupService();
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  static const primaryColor = Colors.lightBlue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Nhóm chat',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // ================= GROUP LIST =================
      body: StreamBuilder(
        stream: _groupService.getUserGroups(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có nhóm',
                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final group = docs[i];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),

                  // ===== ICON =====
                  leading: const CircleAvatar(
                    backgroundColor: primaryColor,
                    child: Icon(
                      Icons.groups,
                      color: Colors.white,
                    ),
                  ),

                  // ===== GROUP INFO =====
                  title: Text(
                    group['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Thành viên: ${group['members'].length}',
                    style: const TextStyle(color: Colors.black54),
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: primaryColor,
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupChatScreen(
                          groupId: group.id,
                          groupName: group['name'],
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
