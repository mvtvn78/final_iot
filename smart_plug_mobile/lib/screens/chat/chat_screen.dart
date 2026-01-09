import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// 1) MODEL CHO TIN NHẮN
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // ✅ ĐỔI THÀNH SERVER CỦA BẠN (Node/Express hoặc Vercel function)
  // Ví dụ: https://your-api.vercel.app/chat
  // hoặc: http://localhost:3003/chat (khi test local)
  static const String _chatEndpoint =
      "https://e-commerce-app-lovat-one.vercel.app/chat";

  // --- UI STATE ---
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Màu sắc theo design
  final Color primaryBlue = const Color(0xFF3F63F3);
  final Color bgGray = const Color(0xFFF9FAFB);
  final Color textDark = const Color(0xFF1F2937);

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: "Hello there! 👋 How can I assist you today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _textController.clear();
    _scrollToBottom();

    try {
      final reply = await _callChatApi(text);

      setState(() {
        _isLoading = false;
        _messages.add(ChatMessage(
          text: reply.isNotEmpty ? reply : "Sorry, I didn't get that.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add(ChatMessage(
          text: "Error: $e",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    }
  }

  Future<String> _callChatApi(String message) async {
    final uri = Uri.parse(_chatEndpoint);

    final res = await http
        .post(
          uri,
          headers: const {"Content-Type": "application/json"},
          body: jsonEncode({"message": message}),
        )
        .timeout(const Duration(seconds: 25));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      // Hỗ trợ nhiều dạng response:
      // { "text": "..." } hoặc { "data": { "text": "..." } }
      final text = (data is Map && data["text"] is String)
          ? data["text"] as String
          : (data is Map &&
                  data["data"] is Map &&
                  data["data"]["text"] is String)
              ? data["data"]["text"] as String
              : "";

      return text.trim();
    }

    // Lỗi thường gặp: 429 / 401 / 500
    String serverMsg = "HTTP ${res.statusCode}";
    try {
      final data = jsonDecode(res.body);
      if (data is Map && data["message"] is String) {
        serverMsg = data["message"];
      } else if (data is Map && data["error"] is String) {
        serverMsg = data["error"];
      }
    } catch (_) {}

    throw serverMsg;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: textDark,
        centerTitle: true,
        title: const Text(
          "Chat with Bobo",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return _buildLoadingBubble();
                }
                return _buildMessageItem(_messages[index]);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    final isUser = message.isUser;
    final timeString = DateFormat('HH:mm').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: const Icon(Icons.smart_toy,
                  color: Color(0xFF3F63F3), size: 20),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? primaryBlue : bgGray,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : textDark,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeString,
                    style: TextStyle(
                      color: isUser ? Colors.white70 : Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue.shade100),
            ),
            child:
                const Icon(Icons.smart_toy, color: Color(0xFF3F63F3), size: 20),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgGray,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF3F63F3),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "Bobo is typing...",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: bgGray,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: "Type something...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _isLoading ? null : _sendMessage,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _isLoading ? Colors.grey : primaryBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
