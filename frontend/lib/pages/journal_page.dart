import 'package:flutter/material.dart';

import '../services/api_service.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
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

  Future<void> _loadEntries() async {
    try {
      final entries = await ApiService.getJournalEntries();
      if (mounted) setState(() => _entries = entries);
    } catch (_) {
      if (mounted) _showMessage('Could not load journal entries.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAndReflect() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _showMessage('Please write something first.');
      return;
    }
    setState(() => _isSaving = true);
    try {
      final saved = await ApiService.createJournalEntry(text);
      final entry = Map<String, dynamic>.from(saved['journalEntry'] as Map);

      // Show the saved entry right away, even before analysis comes back.
      if (mounted) {
        setState(() {
          _entries = [entry, ..._entries];
          _controller.clear();
        });
      }

      try {
        final analysisResponse = await ApiService.analyzeJournalEntry(
          entry['_id'] as String,
          mode: analysisMode,
        );
        final analysis = Map<String, dynamic>.from(analysisResponse['analysis'] as Map);
        final modeUsed = analysisResponse['mode'] as String?;
        if (!mounted) return;
        setState(() {
          _analysis = analysis;
          _analysisMode = modeUsed;
          _entries = [
            {...entry, ...analysis},
            ..._entries.skip(1),
          ];
        });
      } catch (analysisError) {
        // Entry is safely saved; only the reflection failed.
        if (mounted) _showMessage('Saved, but the reflection could not be generated right now.');
      }
    } catch (error) {
      if (mounted) _showMessage(_errorText(error));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      appBar: AppBar(backgroundColor: const Color(0xFFFAF8F3), elevation: 0, title: const Text('Journal', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF403E38)))),
      body: RefreshIndicator(
        onRefresh: _loadEntries,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('How was your day?', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Color(0xFF403E38))),
            const SizedBox(height: 8),
            const Text('Write freely about your thoughts, feelings, or anything that happened today.', style: TextStyle(color: Color(0xFF827C73), fontSize: 15)),
            const SizedBox(height: 18),
            TextField(
              controller: _controller,
              maxLines: 8,
              maxLength: 5000,
              decoration: InputDecoration(hintText: 'Write whatever is on your mind...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFE9E3D9)))),
            ),
            const SizedBox(height: 18),

            // ------------------------------------------------
            // ANALYSIS METHOD SELECTOR
            // ------------------------------------------------
            const Text('Choose analysis method', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF403E38))),
            const SizedBox(height: 8),
            _card(
              child: Column(
                children: [
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: 'gemini',
                    groupValue: analysisMode,
                    activeColor: const Color(0xFF56745B),
                    title: const Text('Gemini AI', style: TextStyle(color: Color(0xFF403E38), fontWeight: FontWeight.w700)),
                    subtitle: const Text(
                      'Gemini detects the emotion and writes the reflection.',
                      style: TextStyle(color: Color(0xFF827C73), fontSize: 12),
                    ),
                    onChanged: (value) => setState(() => analysisMode = value!),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: 'trained_model',
                    groupValue: analysisMode,
                    activeColor: const Color(0xFF56745B),
                    title: const Text('Trained Model + Gemini', style: TextStyle(color: Color(0xFF403E38), fontWeight: FontWeight.w700)),
                    subtitle: const Text(
                      'A trained emotion-detection model finds the emotion; Gemini writes the reflection.',
                      style: TextStyle(color: Color(0xFF827C73), fontSize: 12),
                    ),
                    onChanged: (value) => setState(() => analysisMode = value!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _isSaving ? null : _saveAndReflect,
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF56745B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: _isSaving ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : const Text('Save & Reflect', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            if (_analysis != null) ...[
              const SizedBox(height: 20),
              _AnalysisCard(analysis: _analysis!, modeUsed: _analysisMode),
            ],
            const SizedBox(height: 25),
            const Text('Recent Entries', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (_entries.isEmpty)
              const _EmptyJournalState()
            else
              ..._entries.map((entry) => _JournalEntryCard(entry: entry)),
          ],
        ),
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({required this.analysis, this.modeUsed});
  final Map<String, dynamic> analysis;
  final String? modeUsed;

  String get _modeLabel {
    switch (modeUsed) {
      case 'trained_model':
        return 'Analyzed with Trained Model + Gemini';
      case 'gemini':
        return 'Analyzed with Gemini AI';
      case 'safety':
        return '';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final emotion = (analysis['emotion'] as String?)?.trim();
    final reflection = analysis['reflection'] as String? ?? analysis['summary'] as String? ?? 'Your reflection is ready.';
    return _card(color: const Color(0xFFEEF5EB), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Journal reflection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      if (emotion != null && emotion.isNotEmpty) ...[const SizedBox(height: 8), _Tag(text: emotion)],
      if (_modeLabel.isNotEmpty) ...[
        const SizedBox(height: 6),
        Text(_modeLabel, style: const TextStyle(fontSize: 11, color: Color(0xFF827C73), fontStyle: FontStyle.italic)),
      ],
      const SizedBox(height: 12),
      Text(reflection, style: const TextStyle(color: Color(0xFF403E38), height: 1.4)),
      const SizedBox(height: 10),
      const Text('This is a general wellness reflection, not a medical diagnosis.', style: TextStyle(fontSize: 11, color: Color(0xFF827C73))),
    ]));
  }
}

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({required this.entry});
  final Map<String, dynamic> entry;

  @override
  Widget build(BuildContext context) {
    final text = entry['text'] as String? ?? '';
    final date = DateTime.tryParse(entry['date'] as String? ?? '');
    final emotion = entry['emotion'] as String?;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(date == null ? 'Journal entry' : '${date.day}/${date.month}/${date.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(text, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF827C73), height: 1.4)),
        if (emotion != null && emotion.isNotEmpty) ...[const SizedBox(height: 10), _Tag(text: emotion)],
      ])),
    );
  }
}

class _EmptyJournalState extends StatelessWidget {
  const _EmptyJournalState();
  @override
  Widget build(BuildContext context) => const Padding(padding: EdgeInsets.all(16), child: Text('Your saved journal entries will appear here.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF827C73))));
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFD9EAD5), borderRadius: BorderRadius.circular(9)), child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF56745B))));
}

Widget _card({required Widget child, Color color = Colors.white}) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9E3D9))), child: child);

String _errorText(Object error) => ApiService.readableError(error);