import 'package:flutter/material.dart';

class AiCompanionPage extends StatefulWidget {
  const AiCompanionPage({super.key});

  @override
  State<AiCompanionPage> createState() => _AiCompanionPageState();
}

class _AiCompanionPageState extends State<AiCompanionPage> {
  final TextEditingController messageController = TextEditingController();

  final List<Map<String, String>> messages = [
    {'sender': 'ai', 'message': 'Hi! 🌿 How are you feeling today?'}
  ];

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void sendMessage() {
    String message = messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    setState(() {
      // Add user's message
      messages.add({
        'sender': 'user',
        'message': message,
      });

      // Temporary AI response
      messages.add({
        'sender': 'ai',
        'message':
            'Thank you for sharing that. Would you like to try a short breathing exercise or talk about what feels overwhelming?'
      });

      messageController.clear();
    });
  }

  // Quick suggestion button
  void sendQuickMessage(String message) {
    messageController.text = message;
    sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        elevation: 0,
        title: const Text(
          'MindSphere AI',
          style: TextStyle(
            color: Color(0xFF403E38),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // ----------------------------------------
          // QUICK HELP
          // ----------------------------------------

          Container(
            margin: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              10,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE7E0EF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Help',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _quickButton(
                      'I\'m stressed',
                    ),
                    _quickButton(
                      'Help me relax',
                    ),
                    _quickButton(
                      'Better sleep',
                    ),
                    _quickButton(
                      'Breathing exercise',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ----------------------------------------
          // CHAT AREA
          // ----------------------------------------

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                final bool isUser = message['sender'] == 'user';

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.all(14),
                    constraints: const BoxConstraints(
                      maxWidth: 300,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(
                              0xFFDDEBD9,
                            )
                          : Colors.white,
                      borderRadius: BorderRadius.circular(
                        18,
                      ),
                    ),
                    child: Text(
                      message['message'] ?? '',
                      style: const TextStyle(
                        color: Color(0xFF403E38),
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ----------------------------------------
          // MESSAGE INPUT
          // ----------------------------------------

          Container(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16,
            ),
            color: const Color(0xFFFAF8F3),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    onSubmitted: (_) {
                      sendMessage();
                    },
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          18,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Send button
                IconButton(
                  onPressed: sendMessage,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF56745B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                  ),
                  icon: const Icon(
                    Icons.send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------
  // QUICK BUTTON
  // ----------------------------------------

  Widget _quickButton(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        sendQuickMessage(text);
      },
      backgroundColor: Colors.white,
      side: BorderSide.none,
    );
  }
}
