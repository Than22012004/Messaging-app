import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/message_model.dart';
import '../../services/group_service.dart';
import '../../services/cloudinary_service.dart';
import '../chat/image_viewer_screen.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final GroupService _groupService = GroupService();
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  static const primaryColor = Colors.lightBlue;
  late final String currentUid;

  @override
  void initState() {
    super.initState();
    currentUid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),

      // ===== APP BAR =====
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          widget.groupName,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenu,
            iconColor: Colors.white,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'mute',
                child: Row(
                  children: [
                    Icon(Icons.notifications_off),
                    SizedBox(width: 8),
                    Text('Tắt thông báo'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'unmute',
                child: Row(
                  children: [
                    Icon(Icons.notifications_active),
                    SizedBox(width: 8),
                    Text('Bật thông báo'),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'leave',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Rời nhóm',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      // ===== BODY =====
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _groupService.getMessages(widget.groupId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                final pinned =
                    messages.where((m) => m.isPinned && !m.isDeleted).toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollCtrl.hasClients) {
                    _scrollCtrl.animateTo(
                      0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return Column(
                  children: [
                    if (pinned.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        color: Colors.amber[100],
                        child: Row(
                          children: [
                            const Icon(Icons.push_pin, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                pinned.first.text ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollCtrl,
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final m = messages[i];
                          return GestureDetector(
                            onLongPress: () => _showActionSheet(m),
                            child: _buildMessage(m),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  // ================= INPUT =================
  Widget _buildInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.white,
        child: Row(
          children: [
            // ===== IMAGE =====
            IconButton(
              icon: const Icon(Icons.image, color: primaryColor),
              onPressed: _pickAndSendImage,
            ),

            // ===== FILE =====
            IconButton(
              icon: const Icon(Icons.attach_file, color: primaryColor),
              onPressed: _pickAndSendFile,
            ),

            Expanded(
              child: TextField(
                controller: _ctrl,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendText(),
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn',
                  filled: true,
                  fillColor: const Color(0xFFF1F8FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            IconButton(
              icon: const Icon(Icons.send, color: primaryColor),
              onPressed: _sendText,
            ),
          ],
        ),
      ),
    );
  }

  // ================= SEND TEXT =================
  void _sendText() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    await _groupService.sendText(
      groupId: widget.groupId,
      text: text,
    );
    _ctrl.clear();
  }

  // ================= SEND IMAGE =================
  Future<void> _pickAndSendImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final url = await CloudinaryService.uploadImage(file);

    if (url != null) {
      await _groupService.sendText(
        groupId: widget.groupId,
        text: url,
      );
    }
  }

  // ================= SEND FILE =================
  Future<void> _pickAndSendFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;

    final url = await CloudinaryService.uploadFile(file);

    if (url != null) {
      await _groupService.sendFile(
        groupId: widget.groupId,
        fileUrl: url,
        fileName: fileName,
      );
    }
  }

  // ================= MESSAGE =================
  Widget _buildMessage(Message m) {
    final isMe = m.senderId == currentUid;

    if (m.isDeleted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            'Tin nhắn đã bị xoá',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 260),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _buildMessageContent(m, isMe),
          ),
        ],
      ),
    );
  }

  // ================= MESSAGE CONTENT =================
  Widget _buildMessageContent(Message m, bool isMe) {
    final textColor = isMe ? Colors.white : Colors.black87;

    // ===== IMAGE =====
    if (m.type == 'text' &&
        m.text != null &&
        m.text!.startsWith('http') &&
        (m.text!.endsWith('.jpg') ||
            m.text!.endsWith('.png') ||
            m.text!.endsWith('.jpeg') ||
            m.text!.endsWith('.webp'))) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageViewerScreen(imageUrl: m.text!),
            ),
          );
        },
        child: Hero(
          tag: m.text!,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              m.text!,
              width: 220,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    // ===== FILE =====
    if (m.type == 'file' && m.fileUrl != null) {
      return GestureDetector(
        onTap: () => launchUrl(Uri.parse(m.fileUrl!)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                m.fileName ?? 'File',
                style: TextStyle(color: textColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    // ===== TEXT =====
    return Text(
      m.text ?? '',
      style: TextStyle(color: textColor),
    );
  }

  // ================= ACTION =================
  void _showActionSheet(Message m) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.push_pin),
            title: const Text('Ghim tin nhắn'),
            onTap: () async {
              Navigator.pop(context);
              await _groupService.pinMessage(
                groupId: widget.groupId,
                messageId: m.id!,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Xoá tin nhắn'),
            onTap: () async {
              Navigator.pop(context);
              await _groupService.deleteMessage(
                groupId: widget.groupId,
                messageId: m.id!,
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= MENU =================
  Future<void> _handleMenu(String value) async {
    if (value == 'mute') {
      await _groupService.muteGroup(
        groupId: widget.groupId,
        uid: currentUid,
      );
    }

    if (value == 'unmute') {
      await _groupService.unmuteGroup(
        groupId: widget.groupId,
        uid: currentUid,
      );
    }

    if (value == 'leave') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Rời nhóm'),
          content: const Text('Bạn chắc chắn muốn rời nhóm này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Huỷ'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Rời nhóm',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (ok == true) {
        await _groupService.leaveGroup(
          groupId: widget.groupId,
          uid: currentUid,
        );

        if (context.mounted) Navigator.pop(context);
      }
    }
  }
}
