import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_model.dart';
import '../../services/group_service.dart';
import '../../services/user_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final GroupService _groupService = GroupService();
  final UserService _userService = UserService();

  final List<String> _selectedUids = [];
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  static const primaryColor = Colors.lightBlue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Tạo nhóm chat',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          // ================= GROUP NAME =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Tên nhóm',
                prefixIcon: const Icon(Icons.group, color: primaryColor),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
          ),

          // ================= USER LIST =================
          Expanded(
            child: StreamBuilder<List<AppUser>>(
              stream: _userService.getAllUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!;

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: users.map((user) {
                    if (user.uid == currentUid) {
                      return const SizedBox();
                    }

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: CheckboxListTile(
                        value: _selectedUids.contains(user.uid),
                        activeColor: primaryColor,
                        title: Text(
                          user.email,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        secondary: const Icon(
                          Icons.person,
                          color: primaryColor,
                        ),
                        onChanged: (v) {
                          setState(() {
                            v!
                                ? _selectedUids.add(user.uid)
                                : _selectedUids.remove(user.uid);
                          });
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          // ================= CREATE BUTTON =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Tạo nhóm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                onPressed: () async {
                  if (_nameCtrl.text.trim().isEmpty || _selectedUids.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nhập tên nhóm và chọn thành viên'),
                      ),
                    );
                    return;
                  }

                  await _groupService.createGroup(
                    name: _nameCtrl.text.trim(),
                    members: [currentUid, ..._selectedUids],
                  );

                  if (!mounted) return;
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
