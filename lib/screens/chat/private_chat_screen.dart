import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/message_model.dart';
import '../../services/chat_service.dart';
import '../../services/cloudinary_service.dart';
import 'image_viewer_screen.dart';

class PrivateChatScreen extends StatefulWidget {
  final String chatId;
  final String receiverName;

  const PrivateChatScreen({
    super.key,
    required this.chatId,
    required this.receiverName,
  });

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  static const primaryColor = Colors.lightBlue;
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),

      // ===== APP BAR =====
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          widget.receiverName,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // ===== BODY =====
      body: Column(
        children: [
          // ===== MESSAGE LIST =====
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatService.getMessages(widget.chatId),
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
                    // ===== PINNED =====
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

                    // ===== LIST =====
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

          // ===== INPUT =====
          _buildInput(),
        ],
      ),
    );
  }

  // ================= INPUT BAR =================
  Widget _buildInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.white,
        child: Row(
          children: [
            // ===== SEND IMAGE =====
            IconButton(
              icon: const Icon(Icons.image, color: primaryColor),
              onPressed: _pickAndSendImage,
            ),

            // ===== SEND FILE =====
            IconButton(
              icon: const Icon(Icons.attach_file, color: primaryColor),
              onPressed: _pickAndSendFile,
            ),

            // ===== TEXT =====
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

    await _chatService.sendText(
      chatId: widget.chatId,
      text: text,
    );
    _ctrl.clear();
  }

  // ================= SEND IMAGE =================
  Future<void> _pickAndSendImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final url = await CloudinaryService.uploadImage(file);

    if (url != null) {
      await _chatService.sendText(
        chatId: widget.chatId,
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
      await _chatService.sendFile(
        chatId: widget.chatId,
        fileUrl: url,
        fileName: fileName,
      );
    }
  }

  // ================= MESSAGE BUBBLE =================
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

  // ================= ACTION SHEET =================
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
              await _chatService.pinMessage(
                chatId: widget.chatId,
                messageId: m.id!,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Xoá tin nhắn'),
            onTap: () async {
              Navigator.pop(context);
              await _chatService.deleteMessage(
                chatId: widget.chatId,
                messageId: m.id!,
              );
            },
          ),
        ],
      ),
    );
  }
}
