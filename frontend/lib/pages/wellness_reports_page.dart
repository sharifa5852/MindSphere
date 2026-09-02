// import 'package:flutter/material.dart';

// import '../services/api_service.dart';

// class WellnessReportsPage extends StatefulWidget {
//   const WellnessReportsPage({super.key});

//   @override
//   State<WellnessReportsPage> createState() => _WellnessReportsPageState();
// }

// class _WellnessReportsPageState extends State<WellnessReportsPage> {
//   bool _monthly = false;
//   late Future<Map<String, dynamic>> _reportFuture;

//   @override
//   void initState() {
//     super.initState();
//     _reportFuture = ApiService.getWellnessReport(monthly: _monthly);
//   }

//   Future<void> _load() async {
//     setState(() => _reportFuture = ApiService.getWellnessReport(monthly: _monthly));
//     await _reportFuture;
//   }

//   void _changePeriod(bool monthly) {
//     if (_monthly == monthly) return;
//     setState(() {
//       _monthly = monthly;
//       _reportFuture = ApiService.getWellnessReport(monthly: _monthly);
//     });
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//     backgroundColor: const Color(0xFFFAF8F3),
//     appBar: AppBar(backgroundColor: const Color(0xFFFAF8F3), elevation: 0, title: const Text('Wellness Reports', style: TextStyle(color: Color(0xFF403E38), fontWeight: FontWeight.bold))),
//     body: Column(children: [
//       Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 8), child: SegmentedButton<bool>(
//         segments: const [ButtonSegment(value: false, label: Text('Weekly')), ButtonSegment(value: true, label: Text('Monthly'))],
//         selected: {_monthly}, onSelectionChanged: (value) => _changePeriod(value.first),
//       )),
//       Expanded(child: FutureBuilder<Map<String, dynamic>>(future: _reportFuture, builder: (context, snapshot) {
//         if (snapshot.connectionState != ConnectionState.done) return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 12), Text('Preparing your report...')]));
//         if (snapshot.hasError) return _ReportMessage(message: ApiService.readableError(snapshot.error!), action: _load);
//         final report = Map<String, dynamic>.from(snapshot.data!['report'] as Map? ?? {});
//         final mood = Map<String, dynamic>.from(report['mood'] as Map? ?? {});
//         final journal = Map<String, dynamic>.from(report['journal'] as Map? ?? {});
//         final assessments = (report['assessments'] as List<dynamic>? ?? const []).map((item) => Map<String, dynamic>.from(item as Map)).toList();
//         final total = _num(mood['totalCheckIns']).toInt();
//         return RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.all(20), children: [
//           Text(_monthly ? 'Your month in review' : 'Your week in review', style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Color(0xFF403E38))), const SizedBox(height: 8),
//           const Text('A summary of the wellbeing information you chose to record.', style: TextStyle(color: Color(0xFF827C73), height: 1.4)), const SizedBox(height: 20),
//           if (total == 0 && _num(journal['totalEntries']).toInt() == 0 && assessments.isEmpty) const _EmptyReport() else ...[
//             _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Mood check-ins', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)), const SizedBox(height: 14), Row(children: [Expanded(child: _Metric(label: 'Check-ins', value: '$total')), Expanded(child: _Metric(label: 'Mood', value: _format(mood['averageMood'], suffix: '/5'))), Expanded(child: _Metric(label: 'Stress', value: _format(mood['averageStress'], suffix: '/5')))]), const SizedBox(height: 16), _Metric(label: 'Average sleep', value: _format(mood['averageSleep'], suffix: ' h'))])),
//             const SizedBox(height: 14), _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Journal', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)), const SizedBox(height: 12), Text('${_num(journal['totalEntries']).toInt()} entries recorded', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF56745B))), const SizedBox(height: 8), Text('Positive: ${_num(journal['positiveEntries']).toInt()} · Neutral: ${_num(journal['neutralEntries']).toInt()} · Negative: ${_num(journal['negativeEntries']).toInt()}', style: const TextStyle(color: Color(0xFF827C73)))])),
//             const SizedBox(height: 14), _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Assessments', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)), const SizedBox(height: 12), if (assessments.isEmpty) const Text('No assessments completed in this period.', style: TextStyle(color: Color(0xFF827C73))) else ...assessments.map((item) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('${(item['type'] as String? ?? '').toUpperCase()}: latest score ${item['latestScore'] ?? '-'} (${(item['latestLevel'] as String? ?? '').replaceAll('_', ' ')})', style: const TextStyle(color: Color(0xFF403E38))))])),
//           ], const SizedBox(height: 16), _card(color: const Color(0xFFF6EDCC), child: Text(report['disclaimer'] as String? ?? 'These are wellness trends and screening summaries, not medical diagnoses.', style: const TextStyle(color: Color(0xFF827C73), height: 1.4))),
//         ]));
//       })),
//     ]),
//   );

//   String _format(dynamic value, {required String suffix}) => value is num ? '${value.toStringAsFixed(1)}$suffix' : '-';
//   Widget _card({required Widget child, Color color = Colors.white}) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE9E3D9))), child: child);
// }

// double _num(dynamic value) => value is num ? value.toDouble() : 0;

// class _Metric extends StatelessWidget { const _Metric({required this.label, required this.value}); final String label; final String value; @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF56745B))), Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF827C73)))]); }
// class _EmptyReport extends StatelessWidget { const _EmptyReport(); @override Widget build(BuildContext context) => const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Text('There is no recorded wellbeing data for this period yet. Check in, journal, or complete an assessment to begin your report.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF827C73), height: 1.4))); }
// class _ReportMessage extends StatelessWidget { const _ReportMessage({required this.message, required this.action}); final String message; final Future<void> Function() action; @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.wifi_off_outlined, size: 42, color: Color(0xFF827C73)), const SizedBox(height: 12), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF827C73), height: 1.4)), const SizedBox(height: 14), FilledButton(onPressed: action, child: const Text('Try again'))]))); }
import 'package:flutter/material.dart';

import '../services/api_service.dart';

class WellnessReportsPage extends StatefulWidget {
  const WellnessReportsPage({super.key});

  @override
  State<WellnessReportsPage> createState() => _WellnessReportsPageState();
}

class _WellnessReportsPageState extends State<WellnessReportsPage> {
  bool _monthly = false;
  late Future<Map<String, dynamic>> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = ApiService.getWellnessReport(monthly: _monthly);
  }

  Future<void> _load() async {
    setState(() {
      _reportFuture =
          ApiService.getWellnessReport(monthly: _monthly);
    });

    await _reportFuture;
  }

  void _changePeriod(bool monthly) {
    if (_monthly == monthly) return;

    setState(() {
      _monthly = monthly;
      _reportFuture =
          ApiService.getWellnessReport(monthly: _monthly);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        elevation: 0,
        title: const Text(
          'Wellness Reports',
          style: TextStyle(
            color: Color(0xFF403E38),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Weekly'),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Monthly'),
                ),
              ],
              selected: {_monthly},
              onSelectionChanged: (value) {
                _changePeriod(value.first);
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _reportFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Preparing your report...'),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _ReportMessage(
                    message: ApiService.readableError(snapshot.error!),
                    action: _load,
                  );
                }

                final report = Map<String, dynamic>.from(
                  snapshot.data?['report'] as Map? ?? {},
                );

                final mood = Map<String, dynamic>.from(
                  report['mood'] as Map? ?? {},
                );

                final journal = Map<String, dynamic>.from(
                  report['journal'] as Map? ?? {},
                );

                final assessments =
                    (report['assessments'] as List<dynamic>? ?? const [])
                        .map(
                          (item) => Map<String, dynamic>.from(
                            item as Map,
                          ),
                        )
                        .toList();

                final total =
                    _num(mood['totalCheckIns']).toInt();

                return RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        _monthly
                            ? 'Your month in review'
                            : 'Your week in review',
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF403E38),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'A summary of the wellbeing information you chose to record.',
                        style: TextStyle(
                          color: Color(0xFF827C73),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (total == 0 &&
                          _num(journal['totalEntries']).toInt() == 0 &&
                          assessments.isEmpty)
                        const _EmptyReport()
                      else ...[
                        // Mood check-ins
                        _card(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mood check-ins',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _Metric(
                                      label: 'Check-ins',
                                      value: '$total',
                                    ),
                                  ),
                                  Expanded(
                                    child: _Metric(
                                      label: 'Mood',
                                      value: _format(
                                        mood['averageMood'],
                                        suffix: '/5',
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: _Metric(
                                      label: 'Stress',
                                      value: _format(
                                        mood['averageStress'],
                                        suffix: '/5',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _Metric(
                                label: 'Average sleep',
                                value: _format(
                                  mood['averageSleep'],
                                  suffix: ' h',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Journal
                        _card(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Journal',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${_num(journal['totalEntries']).toInt()} entries recorded',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF56745B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Positive: ${_num(journal['positiveEntries']).toInt()} · '
                                'Neutral: ${_num(journal['neutralEntries']).toInt()} · '
                                'Negative: ${_num(journal['negativeEntries']).toInt()}',
                                style: const TextStyle(
                                  color: Color(0xFF827C73),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Assessments
                        _card(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Assessments',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),

                              if (assessments.isEmpty)
                                const Text(
                                  'No assessments completed in this period.',
                                  style: TextStyle(
                                    color: Color(0xFF827C73),
                                  ),
                                )
                              else
                                ...assessments.map(
                                  (item) => Padding(
                                    padding:
                                        const EdgeInsets.only(
                                      bottom: 8,
                                    ),
                                    child: Text(
                                      '${(item['type'] as String? ?? '').toUpperCase()}: '
                                      'latest score ${item['latestScore'] ?? '-'} '
                                      '(${(item['latestLevel'] as String? ?? '').replaceAll('_', ' ')})',
                                      style: const TextStyle(
                                        color: Color(0xFF403E38),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      _card(
                        color: const Color(0xFFF6EDCC),
                        child: Text(
                          report['disclaimer'] as String? ??
                              'These are wellness trends and screening summaries, not medical diagnoses.',
                          style: const TextStyle(
                            color: Color(0xFF827C73),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _format(
    dynamic value, {
    required String suffix,
  }) {
    return value is num
        ? '${value.toStringAsFixed(1)}$suffix'
        : '-';
  }

  Widget _card({
    required Widget child,
    Color color = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE9E3D9),
        ),
      ),
      child: child,
    );
  }
}

double _num(dynamic value) {
  return value is num ? value.toDouble() : 0;
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF56745B),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF827C73),
          ),
        ),
      ],
    );
  }
}

class _EmptyReport extends StatelessWidget {
  const _EmptyReport();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Text(
        'There is no recorded wellbeing data for this period yet. '
        'Check in, journal, or complete an assessment to begin your report.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF827C73),
          height: 1.4,
        ),
      ),
    );
  }
}

class _ReportMessage extends StatelessWidget {
  const _ReportMessage({
    required this.message,
    required this.action,
  });

  final String message;
  final Future<void> Function() action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_outlined,
              size: 42,
              color: Color(0xFF827C73),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF827C73),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: action,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
