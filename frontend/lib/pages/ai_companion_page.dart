import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AiCompanionPage extends StatefulWidget {
  const AiCompanionPage({super.key});

  @override
  State<AiCompanionPage> createState() => _AiCompanionPageState();
}

class _AiCompanionPageState extends State<AiCompanionPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'ai',
      'message': 'Hi! How are you feeling today?',
      'isSafetyResponse': false,
    },
  ];
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;

    setState(() {
      _messages.add({'sender': 'user', 'message': message});
      _messageController.clear();
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final response = await ApiService.chatWithAi(message);
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'ai',
          'message': response['response'] as String? ??
              'I could not prepare a response right now.',
          'isSafetyResponse': response['isSafetyResponse'] == true,
        });
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiService.readableError(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _sendQuickMessage(String message) {
    _messageController.text = message;
    _sendMessage();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        elevation: 0,
        title: const Text('MindSphere AI',
            style: TextStyle(
                color: Color(0xFF403E38), fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFFE7E0EF),
                borderRadius: BorderRadius.circular(20)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Quick Help',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _quickButton('I\'m stressed'),
                _quickButton('Help me relax'),
                _quickButton('Better sleep'),
                _quickButton('Breathing exercise'),
              ]),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
                'MindSphere AI offers general wellness support and is not a substitute for professional or emergency care.',
                style: TextStyle(
                    fontSize: 11, color: Color(0xFF827C73), height: 1.35)),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _messages.length + (_isSending ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) return const _TypingBubble();
                return _ChatBubble(message: _messages[index]);
              },
            ),
          ),
          _inputArea(),
        ],
      ),
    );
  }

  Widget _inputArea() => Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        color: const Color(0xFFFAF8F3),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !_isSending,
              maxLength: 2000,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Type a message...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none)),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isSending ? null : _sendMessage,
            style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF56745B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(14)),
            icon: const Icon(Icons.send),
          ),
        ]),
      );

  Widget _quickButton(String text) => ActionChip(
        label: Text(text),
        onPressed: _isSending ? null : () => _sendQuickMessage(text),
        backgroundColor: Colors.white,
        side: BorderSide.none,
      );
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final Map<String, dynamic> message;

  @override
  Widget build(BuildContext context) {
    final isUser = message['sender'] == 'user';
    final isSafetyResponse = message['isSafetyResponse'] == true;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFFDDEBD9)
              : (isSafetyResponse ? const Color(0xFFF6EDCC) : Colors.white),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(message['message'] as String? ?? '',
            style: const TextStyle(color: Color(0xFF403E38), height: 1.4)),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();
  @override
  Widget build(BuildContext context) => const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 10),
              Text('MindSphere AI is thinking...',
                  style: TextStyle(color: Color(0xFF827C73))),
            ])),
      );
}
