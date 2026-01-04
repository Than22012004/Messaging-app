import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/group_service.dart';

class GroupSettingsScreen extends StatelessWidget {
  final String groupId;
  final List<String> members;

  GroupSettingsScreen({
    super.key,
    required this.groupId,
    required this.members,
  });

  final GroupService _groupService = GroupService();
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thành viên nhóm'),
        actions: [
          // ===== LEAVE GROUP BUTTON =====
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              try {
                await _groupService.leaveGroup(
                  groupId: groupId,
                  uid: currentUid,
                );

                if (!context.mounted) return;
                Navigator.pop(context); // back
                Navigator.pop(context); // back group chat
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceAll('Exception: ', '')),
                  ),
                );
              }
            },
            tooltip: 'Rời nhóm',
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: members.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, index) {
          final uid = members[index];

          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(uid),
            subtitle: uid == currentUid ? const Text('Bạn') : null,
            trailing: _buildTrailing(context, uid),
          );
        },
      ),
    );
  }

  // ================= TRAILING ACTION =================
  Widget? _buildTrailing(BuildContext context, String uid) {
    if (uid == currentUid) return null;

    return IconButton(
      icon: const Icon(Icons.remove_circle, color: Colors.red),
      onPressed: () async {
        final isAdmin = await _groupService.isAdmin(
          groupId: groupId,
          uid: currentUid,
        );

        if (!context.mounted) return;

        if (!isAdmin) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chỉ admin mới được xoá thành viên'),
            ),
          );
          return;
        }

        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Xoá thành viên'),
            content: const Text('Bạn có chắc muốn xoá người này khỏi nhóm?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Huỷ'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xoá'),
              ),
            ],
          ),
        );

        if (confirm != true) return;

        await _groupService.removeMember(
          groupId: groupId,
          memberId: uid,
        );

        if (!context.mounted) return;
        Navigator.pop(context);
      },
    );
  }
}
