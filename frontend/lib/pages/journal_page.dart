
import 'package:flutter/material.dart';

import '../services/api_service.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
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

  final _controller = TextEditingController();

  List<Map<String, dynamic>> _entries = [];
  Map<String, dynamic>? _analysis;

  String? _analysisMode;
  bool _isLoading = true;
  bool _isSaving = false;

  String analysisMode = 'gemini';

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ==========================================================
  // LOAD JOURNAL
  // ==========================================================

  Future<void> _loadEntries() async {
    try {
      final entries = await ApiService.getJournalEntries();

      if (mounted) {
        setState(() => _entries = entries);
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Could not load journal entries.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ==========================================================
  // SAVE + REFLECT
  // ==========================================================

  Future<void> _saveAndReflect() async {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      _showMessage('Please write something first.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final saved = await ApiService.createJournalEntry(text);

      final entry = Map<String, dynamic>.from(
        saved['journalEntry'] as Map,
      );

      // Show saved entry immediately.
      if (mounted) {
        setState(() {
          _entries = [entry, ..._entries];
          _controller.clear();
        });
      }

      try {
        final analysisResponse =
            await ApiService.analyzeJournalEntry(
          entry['_id'] as String,
          mode: analysisMode,
        );

        final analysis = Map<String, dynamic>.from(
          analysisResponse['analysis'] as Map,
        );

        final modeUsed =
            analysisResponse['mode'] as String?;

        if (!mounted) return;

        setState(() {
          _analysis = analysis;
          _analysisMode = modeUsed;

          _entries = [
            {...entry, ...analysis},
            ..._entries.skip(1),
          ];
        });
      } catch (_) {
        if (mounted) {
          _showMessage(
            'Saved, but the reflection could not be generated right now.',
          );
        }
      }
    } catch (error) {
      if (mounted) {
        _showMessage(_errorText(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
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
        child: RefreshIndicator(
          color: darkGreen,
          backgroundColor: Colors.white,
          onRefresh: _loadEntries,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: _topBar(),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    38,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // HERO
                      // ==================================================

                      _hero(),

                      const SizedBox(height: 26),

                      // ==================================================
                      // WRITE
                      // ==================================================

                      _sectionHeader(
                        title: 'Write freely',
                        subtitle:
                            'No pressure. No perfect words.',
                      ),

                      const SizedBox(height: 14),

                      _journalEditor(),

                      const SizedBox(height: 24),

                      // ==================================================
                      // AI ANALYSIS
                      // ==================================================

                      _sectionHeader(
                        title: 'Choose your reflection',
                        subtitle:
                            'Pick how you want MindSphere to understand your entry.',
                      ),

                      const SizedBox(height: 14),

                      _analysisSelector(),

                      const SizedBox(height: 22),

                      _saveButton(),

                      const SizedBox(height: 12),

                      const Text(
                        'Your journal stays personal. AI reflection is designed for general wellness support.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          height: 1.45,
                          color: mutedText,
                        ),
                      ),

                      // ==================================================
                      // GENERATED ANALYSIS
                      // ==================================================

                      if (_analysis != null) ...[
                        const SizedBox(height: 28),
                        _AnalysisCard(
                          analysis: _analysis!,
                          modeUsed: _analysisMode,
                        ),
                      ],

                      const SizedBox(height: 32),

                      // ==================================================
                      // RECENT ENTRIES
                      // ==================================================

                      _sectionHeader(
                        title: 'Your journal',
                        subtitle:
                            'A collection of moments you chose to keep.',
                      ),

                      const SizedBox(height: 14),

                      if (_isLoading)
                        _loadingEntries()
                      else if (_entries.isEmpty)
                        const _EmptyJournalState()
                      else
                        ..._entries.map(
                          (entry) => _JournalEntryCard(
                            entry: entry,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
        20,
        4,
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
            'Journal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: paleMint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 12,
                  color: darkGreen,
                ),
                SizedBox(width: 5),
                Text(
                  'Private',
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
  // HERO
  // ==========================================================

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
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
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.17),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -42,
            right: 45,
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.58),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'YOUR QUIET SPACE',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w800,
                    color: darkGreen,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Put it into\nwords.',
                style: TextStyle(
                  fontSize: 31,
                  height: 1.03,
                  letterSpacing: -0.9,
                  fontWeight: FontWeight.w800,
                  color: forestText,
                ),
              ),

              const SizedBox(height: 11),

              const Text(
                'Some thoughts just need a place to land. Write without editing yourself.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: mutedText,
                ),
              ),

              const SizedBox(height: 17),

              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 15,
                    color: darkGreen,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Reflect • release • notice',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: darkGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SECTION HEADER
  // ==========================================================

  Widget _sectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            height: 1.4,
            color: mutedText,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // JOURNAL EDITOR
  // ==========================================================

Widget _journalEditor() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(27),
      border: Border.all(
        color: paleMint,
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: darkGreen.withOpacity(0.045),
          blurRadius: 20,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(
            18,
            15,
            18,
            10,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: paleMint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: darkGreen,
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'Today’s thoughts',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: forestText,
                  ),
                ),
              ),

              const Icon(
                Icons.more_horiz_rounded,
                color: mutedText,
              ),
            ],
          ),
        ),

        const Divider(
          height: 1,
          color: Color(0xFFEAF3EC),
        ),

        // Character counter above the text box
        Padding(
          padding: const EdgeInsets.fromLTRB(
            18,
            10,
            18,
            0,
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_controller.text.length}/5000',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: mutedText,
              ),
            ),
          ),
        ),

        // Text field
        TextField(
          controller: _controller,
          maxLines: 9,
          maxLength: 5000,
          textCapitalization: TextCapitalization.sentences,

          onChanged: (_) {
            setState(() {});
          },

          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: forestText,
          ),

          decoration: const InputDecoration(
            hintText:
                'Take a breath... write what’s on your mind.',
            hintStyle: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: mutedText,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.fromLTRB(
              18,
              12,
              18,
              0,
            ),
            counterText: '',
          ),
        ),

        // Small helper message
        Container(
          margin: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            15,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                size: 14,
                color: darkGreen,
              ),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'No pressure. Just be honest with yourself.',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.3,
                    color: mutedText,
                  ),
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
  // ANALYSIS SELECTOR
  // ==========================================================

  Widget _analysisSelector() {
    return Column(
      children: [
        _analysisOption(
          value: 'gemini',
          icon: Icons.auto_awesome_rounded,
          title: 'Gemini AI',
          subtitle:
              'AI detects the emotion and creates a thoughtful reflection.',
        ),

        const SizedBox(height: 10),

        _analysisOption(
          value: 'trained_model',
          icon: Icons.hub_rounded,
          title: 'Trained Model + Gemini',
          subtitle:
              'A trained model identifies emotion while Gemini creates the reflection.',
        ),
      ],
    );
  }

  Widget _analysisOption({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = analysisMode == value;

    return GestureDetector(
      onTap: () {
        setState(() => analysisMode = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? freshMint
              : Colors.white,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(
            color: selected
                ? darkGreen
                : paleMint,
            width: selected ? 1.4 : 1,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color:
                    darkGreen.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.60)
                    : paleMint,
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 21,
                color: darkGreen,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: forestText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      color: mutedText,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? darkGreen
                  : mutedText.withOpacity(0.25),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // SAVE BUTTON
  // ==========================================================

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed:
            _isSaving ? null : _saveAndReflect,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkGreen,
          disabledBackgroundColor:
              darkGreen.withOpacity(0.55),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(
            milliseconds: 200,
          ),
          child: _isSaving
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 23,
                  height: 23,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  key: ValueKey('button'),
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      'Save & reflect',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 9),
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 17,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ==========================================================
  // LOADING ENTRIES
  // ==========================================================

  Widget _loadingEntries() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 35,
      ),
      child: const Center(
        child: Column(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: darkGreen,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Gathering your entries...',
              style: TextStyle(
                fontSize: 11,
                color: mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ANALYSIS CARD
// ============================================================

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({
    required this.analysis,
    this.modeUsed,
  });

  final Map<String, dynamic> analysis;
  final String? modeUsed;

  static const Color darkGreen = Color(0xFF2D6A4F);
  static const Color forestText = Color(0xFF1B4332);
  static const Color mutedText = Color(0xFF5B7568);
  static const Color paleMint = Color(0xFFD9F0DC);
  static const Color primary = Color(0xFFBFE3C0);
  static const Color freshMint = Color(0xFFC9EACB);

  String get _modeLabel {
    switch (modeUsed) {
      case 'trained_model':
        return 'Trained Model + Gemini';
      case 'gemini':
        return 'Gemini AI';
      case 'safety':
        return '';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final emotion =
        (analysis['emotion'] as String?)?.trim();

    final reflection =
        analysis['reflection'] as String? ??
            analysis['summary'] as String? ??
            'Your reflection is ready.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            freshMint,
            paleMint,
          ],
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(
                    0.58,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: darkGreen,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR REFLECTION',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w800,
                        color: darkGreen,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Something to notice',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: forestText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (emotion != null &&
              emotion.isNotEmpty) ...[
            const SizedBox(height: 17),
            _Tag(text: emotion),
          ],

          if (_modeLabel.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.psychology_alt_outlined,
                  size: 13,
                  color: mutedText,
                ),
                const SizedBox(width: 5),
                Text(
                  _modeLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: mutedText,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          Text(
            reflection,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w600,
              color: forestText,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(
                0.48,
              ),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: mutedText,
                ),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'A general wellness reflection, not a medical diagnosis.',
                    style: TextStyle(
                      fontSize: 9,
                      height: 1.35,
                      color: mutedText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// JOURNAL ENTRY CARD
// ============================================================

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({
    required this.entry,
  });

  final Map<String, dynamic> entry;

  static const Color darkGreen = Color(0xFF2D6A4F);
  static const Color forestText = Color(0xFF1B4332);
  static const Color mutedText = Color(0xFF5B7568);
  static const Color paleMint = Color(0xFFD9F0DC);
  static const Color background = Color(0xFFF3FAF5);

  @override
  Widget build(BuildContext context) {
    final text = entry['text'] as String? ?? '';

    final date = DateTime.tryParse(
      entry['date'] as String? ?? '',
    );

    final emotion =
        entry['emotion'] as String?;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(
            color: paleMint,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  darkGreen.withOpacity(0.035),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius:
                        BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.bookmark_outline_rounded,
                    color: darkGreen,
                    size: 18,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    date == null
                        ? 'Journal entry'
                        : _formatDate(date),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: forestText,
                    ),
                  ),
                ),

                const Icon(
                  Icons.chevron_right_rounded,
                  color: mutedText,
                  size: 20,
                ),
              ],
            ),

            const SizedBox(height: 13),

            Text(
              text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.55,
                color: mutedText,
              ),
            ),

            if (emotion != null &&
                emotion.isNotEmpty) ...[
              const SizedBox(height: 12),
              _Tag(text: emotion),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} '
        '${date.day}, ${date.year}';
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyJournalState extends StatelessWidget {
  const _EmptyJournalState();

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF2D6A4F);
    const forestText = Color(0xFF1B4332);
    const mutedText = Color(0xFF5B7568);
    const paleMint = Color(0xFFD9F0DC);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: paleMint,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: paleMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: darkGreen,
              size: 28,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Your journal is waiting',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: forestText,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Write your first entry above and your saved moments will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TAG
// ============================================================

class _Tag extends StatelessWidget {
  const _Tag({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF2D6A4F);
    const paleMint = Color(0xFFD9F0DC);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: paleMint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite_rounded,
            size: 11,
            color: darkGreen,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ERROR HELPER
// ============================================================

String _errorText(Object error) {
  return ApiService.readableError(error);
}

