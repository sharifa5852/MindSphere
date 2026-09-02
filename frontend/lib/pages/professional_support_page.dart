import 'package:flutter/material.dart';

import '../services/api_service.dart';

class ProfessionalSupportPage extends StatefulWidget {
  const ProfessionalSupportPage({super.key});

  @override
  State<ProfessionalSupportPage> createState() => _ProfessionalSupportPageState();
}

class _ProfessionalSupportPageState extends State<ProfessionalSupportPage> {
  late Future<List<Map<String, dynamic>>> _therapistsFuture;

  @override
  void initState() {
    super.initState();
    _therapistsFuture = ApiService.getRecommendedTherapists();
  }

  void _retry() => setState(() => _therapistsFuture = ApiService.getRecommendedTherapists());

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFAF8F3),
    appBar: AppBar(backgroundColor: const Color(0xFFFAF8F3), elevation: 0, title: const Text('Professional Support', style: TextStyle(color: Color(0xFF403E38), fontWeight: FontWeight.bold))),
    body: FutureBuilder<List<Map<String, dynamic>>>(future: _therapistsFuture, builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Could not load professional support options.', style: TextStyle(color: Color(0xFF827C73))), TextButton(onPressed: _retry, child: const Text('Try again'))]));
      final recommendations = snapshot.data!;
      return RefreshIndicator(onRefresh: () async => _retry(), child: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Find support that feels right for you', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Color(0xFF403E38))), const SizedBox(height: 8),
        const Text('These profiles are informational. Contact a provider directly to ask about availability, fees, and whether they are a good fit.', style: TextStyle(color: Color(0xFF827C73), height: 1.4)), const SizedBox(height: 20),
        if (recommendations.isEmpty) const _EmptyState() else ...recommendations.map((item) => _TherapistCard(recommendation: item)),
        const SizedBox(height: 12), const _CrisisCard(),
      ]));
    }),
  );
}

class _TherapistCard extends StatelessWidget {
  const _TherapistCard({required this.recommendation});
  final Map<String, dynamic> recommendation;

  @override
  Widget build(BuildContext context) {
    final therapist = Map<String, dynamic>.from(recommendation['therapist'] as Map? ?? {});
    final specialties = (therapist['specialization'] as List<dynamic>? ?? const []).join(', ');
    final languages = (therapist['languages'] as List<dynamic>? ?? const []).join(', ');
    final isVerified = therapist['verified'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9E3D9))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(therapist['name'] as String? ?? 'Professional', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF403E38)))),
          if (!isVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFF6EDCC), borderRadius: BorderRadius.circular(8)),
              child: const Text('Unverified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF827C73))),
            ),
        ]),
        const SizedBox(height: 5),
        Text(specialties.isEmpty ? 'Wellness support' : specialties, style: const TextStyle(color: Color(0xFF56745B), fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('${therapist['experienceYears'] ?? 0} years experience · ${therapist['location'] ?? 'Location not listed'}', style: const TextStyle(color: Color(0xFF827C73))),
        if (languages.isNotEmpty) ...[const SizedBox(height: 4), Text('Languages: $languages', style: const TextStyle(color: Color(0xFF827C73)))],
        const SizedBox(height: 10),
        Text(therapist['bio'] as String? ?? 'No biography available.', style: const TextStyle(color: Color(0xFF403E38), height: 1.35)),
        const SizedBox(height: 10),
        Text('Availability: ${therapist['availability'] ?? 'not listed'} · Rating: ${therapist['rating'] ?? '-'}', style: const TextStyle(fontSize: 12, color: Color(0xFF827C73))),
        if (recommendation['matchExplanation'] != null) ...[const SizedBox(height: 8), Text(recommendation['matchExplanation'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF685D79), height: 1.3))],
      ]),
    );
  }
}
class _EmptyState extends StatelessWidget { const _EmptyState(); @override Widget build(BuildContext context) => const Padding(padding: EdgeInsets.all(24), child: Text('No provider profiles are available yet. Please check back later.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF827C73)))); }

class _CrisisCard extends StatelessWidget { const _CrisisCard(); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF6EDCC), borderRadius: BorderRadius.circular(20)), child: const Text('If you feel in immediate danger or may harm yourself, contact local emergency services or a crisis service now, and reach out to someone you trust.', style: TextStyle(color: Color(0xFF827C73), height: 1.4))); }
