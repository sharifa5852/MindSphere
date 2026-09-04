
import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AiCompanionPage extends StatefulWidget {
  const AiCompanionPage({super.key});

  @override
  State<AiCompanionPage> createState() => _AiCompanionPageState();
}

class _AiCompanionPageState extends State<AiCompanionPage> {
  // ==========================================================
  // MINDSPHERE — SOFT MINT DESIGN SYSTEM
  // ==========================================================

  static const Color primary = Color(0xFFBFE3C0);
  static const Color paleMint = Color(0xFFD9F0DC);
  static const Color freshMint = Color(0xFFC9EACB);
  static const Color calmMint = Color(0xFFB5DFC0);
  static const Color sageMint = Color(0xFFAED8B8);
  static const Color eucalyptus = Color(0xFFA8D5B5);
  static const Color dustyMint = Color(0xFFA5D0B2);
  static const Color celadon = Color(0xFFB7DCC1);
  static const Color morningMint = Color(0xFFC8E7D0);

  static const Color background = Color(0xFFF3FAF5);
  static const Color darkGreen = Color(0xFF2D6A4F);
  static const Color forestText = Color(0xFF1B4332);
  static const Color ink = Color(0xFF13291D);
  static const Color mutedText = Color(0xFF5B7568);

  // ==========================================================
  // STATE
  // ==========================================================

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

  // ==========================================================
  // SEND MESSAGE
  // ==========================================================

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty || _isSending) return;

    setState(() {
      _messages.add({
        'sender': 'user',
        'message': message,
      });

      _messageController.clear();
      _isSending = true;
    });

    _scrollToBottom();

    try {
      final response =
          await ApiService.chatWithAi(message);

      if (!mounted) return;

      setState(() {
        _messages.add({
          'sender': 'ai',
          'message': response['response'] as String? ??
              'I could not prepare a response right now.',
          'isSafetyResponse':
              response['isSafetyResponse'] == true,
        });
      });
    } catch (error) {
      if (mounted) {
        _showError(
          ApiService.readableError(error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }

      _scrollToBottom();
    }
  }

  // ==========================================================
  // QUICK MESSAGE
  // ==========================================================

  void _sendQuickMessage(String message) {
    if (_isSending) return;

    _messageController.text = message;
    _sendMessage();
  }

  // ==========================================================
  // SCROLL
  // ==========================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(
            milliseconds: 280,
          ),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkGreen,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ==========================================================
  // PAGE
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // ========================================================
            // TOP BAR
            // ========================================================

            _topBar(),

            // ========================================================
            // AI HERO
            // ========================================================

            _aiHeader(),

            // ========================================================
            // QUICK PROMPTS
            // ========================================================

            _quickHelp(),

            // ========================================================
            // CONVERSATION
            // ========================================================

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  18,
                ),
                itemCount:
                    _messages.length +
                        (_isSending ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return const _TypingBubble();
                  }

                  return _ChatBubble(
                    message: _messages[index],
                  );
                },
              ),
            ),

            // ========================================================
            // INPUT
            // ========================================================

            _inputArea(),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // TOP BAR
  // ==========================================================

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        3,
      ),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: forestText,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          const Text(
            'MindSphere AI',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: paleMint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 7,
                  color: darkGreen,
                ),
                SizedBox(width: 5),
                Text(
                  'Here for you',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: darkGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // AI HEADER
  // ==========================================================

  Widget _aiHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primary,
              paleMint,
              morningMint,
            ],
          ),
          borderRadius: BorderRadius.circular(27),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -14,
              top: -28,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color:
                      Colors.white.withOpacity(0.16),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color:
                        Colors.white.withOpacity(0.58),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: darkGreen,
                    size: 27,
                  ),
                ),

                const SizedBox(width: 13),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A space to talk',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: forestText,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Share what is on your mind. I’m listening.',
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.35,
                          color: mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // QUICK HELP
  // ==========================================================

  Widget _quickHelp() {
    return SizedBox(
      height: 61,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          3,
          20,
          7,
        ),
        children: [
          _quickButton(
            'I’m stressed',
            Icons.psychology_alt_rounded,
          ),
          _quickButton(
            'Help me relax',
            Icons.spa_rounded,
          ),
          _quickButton(
            'Better sleep',
            Icons.nightlight_round,
          ),
          _quickButton(
            'Breathing exercise',
            Icons.air_rounded,
          ),
        ],
      ),
    );
  }

  Widget _quickButton(
    String text,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        onPressed: _isSending
            ? null
            : () => _sendQuickMessage(text),
        backgroundColor: Colors.white,
        disabledColor: Colors.white.withOpacity(0.5),
        side: const BorderSide(
          color: Color(0xFFE3F0E5),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 8,
        ),
        avatar: Icon(
          icon,
          size: 15,
          color: darkGreen,
        ),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: forestText,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  // ==========================================================
  // INPUT AREA
  // ==========================================================

  Widget _inputArea() {
    final bottomInset =
        MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(
        bottom: bottomInset > 0 ? 6 : 0,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          16,
          9,
          16,
          14,
        ),
        decoration: BoxDecoration(
          color: background,
          boxShadow: [
            BoxShadow(
              color:
                  darkGreen.withOpacity(0.045),
              blurRadius: 18,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(22),
                  border: Border.all(
                    color: paleMint,
                  ),
                ),
                child: TextField(
                  controller:
                      _messageController,
                  enabled: !_isSending,
                  maxLength: 2000,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction:
                      TextInputAction.send,
                  textCapitalization:
                      TextCapitalization.sentences,
                  onSubmitted: (_) =>
                      _sendMessage(),
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: forestText,
                  ),
                  decoration:
                      const InputDecoration(
                    counterText: '',
                    hintText:
                        'Tell me what’s on your mind...',
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: mutedText,
                    ),
                    prefixIcon: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 19,
                      color: mutedText,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 13,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            AnimatedContainer(
              duration:
                  const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _isSending
                    ? sageMint
                    : darkGreen,
                borderRadius:
                    BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: darkGreen
                        .withOpacity(0.12),
                    blurRadius: 13,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _isSending
                    ? null
                    : _sendMessage,
                color: Colors.white,
                disabledColor:
                    Colors.white.withOpacity(0.7),
                tooltip: 'Send',
                icon: const Icon(
                  Icons.arrow_upward_rounded,
                  size: 21,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CHAT BUBBLE
// ============================================================

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
  });

  final Map<String, dynamic> message;

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF2D6A4F);
    const forestText = Color(0xFF1B4332);
    const mutedText = Color(0xFF5B7568);
    const primary = Color(0xFFBFE3C0);
    const paleMint = Color(0xFFD9F0DC);
    const background = Color(0xFFF3FAF5);

    final isUser =
        message['sender'] == 'user';

    final isSafetyResponse =
        message['isSafetyResponse'] == true;

    final messageText =
        message['message'] as String? ?? '';

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(
            top: 5,
            bottom: 5,
            left: 48,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primary,
                paleMint,
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(6),
            ),
          ),
          child: Text(
            messageText,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: forestText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 7,
          bottom: 7,
          right: 35,
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 33,
              height: 33,
              decoration: BoxDecoration(
                color: paleMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: darkGreen,
              ),
            ),

            const SizedBox(width: 9),

            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: isSafetyResponse
                      ? const Color(0xFFEAF4DE)
                      : Colors.white,
                  borderRadius:
                      const BorderRadius.only(
                    topLeft:
                        Radius.circular(6),
                    topRight:
                        Radius.circular(20),
                    bottomLeft:
                        Radius.circular(20),
                    bottomRight:
                        Radius.circular(20),
                  ),
                  border: Border.all(
                    color: isSafetyResponse
                        ? primary
                        : const Color(0xFFE3F0E5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    if (isSafetyResponse) ...[
                      Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 14,
                            color: darkGreen,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Supportive response',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight:
                                  FontWeight.w800,
                              letterSpacing:
                                  0.2,
                              color: darkGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                    ],

                    Text(
                      messageText,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: forestText,
                        fontWeight:
                            isSafetyResponse
                                ? FontWeight.w600
                                : FontWeight.w500,
                      ),
                    ),

                    if (!isSafetyResponse)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 7,
                        ),
                        child: Text(
                          'MindSphere AI',
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight:
                                FontWeight.w600,
                            color: mutedText,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TYPING BUBBLE
// ============================================================

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF2D6A4F);
    const mutedText = Color(0xFF5B7568);
    const paleMint = Color(0xFFD9F0DC);

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 10,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 33,
              height: 33,
              decoration: const BoxDecoration(
                color: paleMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 15,
                color: darkGreen,
              ),
            ),

            const SizedBox(width: 9),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: paleMint,
                ),
              ),
              child: const Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 15,
                    height: 15,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color: darkGreen,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Thinking gently...',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          FontWeight.w600,
                      color: mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

