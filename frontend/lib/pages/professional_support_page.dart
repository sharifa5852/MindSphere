
import 'package:flutter/material.dart';

import '../services/api_service.dart';

// ============================================================
// MINDSPHERE — SOFT MINT DESIGN SYSTEM
// ============================================================

const _primary = Color(0xFFBFE3C0);
const _paleMint = Color(0xFFD9F0DC);
const _freshMint = Color(0xFFC9EACB);
const _calmMint = Color(0xFFB5DFC0);
const _sageMint = Color(0xFFAED8B8);
const _eucalyptus = Color(0xFFA8D5B5);
const _dustyMint = Color(0xFFA5D0B2);
const _celadon = Color(0xFFB7DCC1);
const _morningMint = Color(0xFFC8E7D0);

const _background = Color(0xFFF3FAF5);
const _darkGreen = Color(0xFF2D6A4F);
const _forestText = Color(0xFF1B4332);
const _ink = Color(0xFF13291D);
const _mutedText = Color(0xFF5B7568);

class ProfessionalSupportPage extends StatefulWidget {
  const ProfessionalSupportPage({super.key});

  @override
  State<ProfessionalSupportPage> createState() =>
      _ProfessionalSupportPageState();
}

class _ProfessionalSupportPageState
    extends State<ProfessionalSupportPage> {
  late Future<List<Map<String, dynamic>>>
      _therapistsFuture;

  @override
  void initState() {
    super.initState();

    _therapistsFuture =
        ApiService.getRecommendedTherapists();
  }

  void _retry() {
    setState(() {
      _therapistsFuture =
          ApiService.getRecommendedTherapists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _therapistsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState !=
                ConnectionState.done) {
              return const _LoadingSupport();
            }

            if (snapshot.hasError) {
              return _SupportError(
                onRetry: _retry,
              );
            }

            final recommendations =
                snapshot.data ?? const [];

            return RefreshIndicator(
              color: _darkGreen,
              backgroundColor: Colors.white,
              onRefresh: () async {
                _retry();
                await _therapistsFuture;
              },
              child: ListView(
                physics:
                    const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  36,
                ),
                children: [
                  _topBar(),

                  const SizedBox(height: 18),

                  _hero(),

                  const SizedBox(height: 26),

                  _sectionTitle(
                    eyebrow: 'PERSONALIZED FOR YOU',
                    title: 'Find your support',
                    subtitle:
                        'Explore professionals who may be a good fit for your needs.',
                  ),

                  const SizedBox(height: 13),

                  if (recommendations.isEmpty)
                    const _EmptyState()
                  else ...[
                    _recommendationBadge(
                      count:
                          recommendations.length,
                    ),

                    const SizedBox(height: 12),

                    ...recommendations.map(
                      (item) => Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 13,
                        ),
                        child: _TherapistCard(
                          recommendation: item,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  const _CrisisCard(),

                  const SizedBox(height: 16),

                  const _SupportFooter(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _topBar() {
    return Row(
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder:
                const CircleBorder(),
            onTap: () =>
                Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: _forestText,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Text(
            'Professional Support',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _ink,
              letterSpacing: -0.4,
            ),
          ),
        ),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: _paleMint,
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 13,
                color: _darkGreen,
              ),
              SizedBox(width: 5),
              Text(
                'Trusted care',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: _darkGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primary,
            _paleMint,
          ],
        ),
        borderRadius:
            BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color:
                _darkGreen.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -35,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                color:
                    Colors.white.withOpacity(
                  0.17,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            right: 45,
            bottom: -45,
            child: Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color:
                    Colors.white.withOpacity(
                  0.13,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.58),
                      borderRadius:
                          BorderRadius
                              .circular(20),
                    ),
                    child: const Text(
                      'A LITTLE EXTRA SUPPORT',
                      style: TextStyle(
                        fontSize: 8.5,
                        letterSpacing: 1.25,
                        fontWeight:
                            FontWeight.w800,
                        color: _darkGreen,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '🤝',
                    style:
                        TextStyle(fontSize: 27),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Text(
                'You don’t have\nto handle everything alone.',
                style: TextStyle(
                  fontSize: 28,
                  height: 1.05,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: -0.8,
                  color: _forestText,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Explore professional support when you feel ready. Finding someone who feels right can be an important first step.',
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.5,
                  color: _mutedText,
                ),
              ),

              const SizedBox(height: 19),

              Container(
                padding:
                    const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(0.52),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 17,
                      color: _darkGreen,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Profiles are informational. Contact providers directly to ask about availability, fees, and fit.',
                        style: TextStyle(
                          fontSize: 9.5,
                          height: 1.4,
                          color: _forestText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle({
    required String eyebrow,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            fontSize: 9,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w800,
            color: _darkGreen,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: _ink,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            height: 1.4,
            color: _mutedText,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RECOMMENDATION COUNT
  // ============================================================

  Widget _recommendationBadge({
    required int count,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: _paleMint,
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 15,
            color: _darkGreen,
          ),
          const SizedBox(width: 7),
          Text(
            '$count professional${count == 1 ? '' : 's'} '
            'recommended for you',
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: _forestText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// THERAPIST CARD
// ============================================================

class _TherapistCard extends StatelessWidget {
  const _TherapistCard({
    required this.recommendation,
  });

  final Map<String, dynamic> recommendation;

  @override
  Widget build(BuildContext context) {
    final therapist =
        Map<String, dynamic>.from(
      recommendation['therapist']
              as Map? ??
          {},
    );

    final name =
        therapist['name'] as String? ??
            'Professional';

    final specialties =
        (therapist['specialization']
                    as List<dynamic>? ??
                const [])
            .map(
              (item) => item.toString(),
            )
            .toList();

    final languages =
        (therapist['languages']
                    as List<dynamic>? ??
                const [])
            .map(
              (item) => item.toString(),
            )
            .toList();

    final isVerified =
        therapist['verified'] == true;

    final experience =
        therapist['experienceYears'] ?? 0;

    final location =
        therapist['location'] ??
            'Location not listed';

    final availability =
        therapist['availability'] ??
            'Not listed';

    final rating =
        therapist['rating'] ?? '-';

    final bio =
        therapist['bio'] as String? ??
            'No biography available.';

    final matchExplanation =
        recommendation['matchExplanation']
            as String?;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: _paleMint,
        ),
        boxShadow: [
          BoxShadow(
            color:
                _darkGreen.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------
          // HEADER
          // ----------------------------------------------------

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(
                    begin:
                        Alignment.topLeft,
                    end:
                        Alignment.bottomRight,
                    colors: [
                      _primary,
                      _freshMint,
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(17),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 28,
                    color: _darkGreen,
                  ),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                const TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w800,
                              color: _forestText,
                            ),
                          ),
                        ),

                        if (isVerified) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration:
                                BoxDecoration(
                              color: _paleMint,
                              borderRadius:
                                  BorderRadius
                                      .circular(8),
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              size: 13,
                              color:
                                  _darkGreen,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      specialties.isEmpty
                          ? 'Wellness support'
                          : specialties.join(
                              ' • ',
                            ),
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        height: 1.35,
                        fontWeight:
                            FontWeight.w700,
                        color: _darkGreen,
                      ),
                    ),
                  ],
                ),
              ),

              if (!isVerified)
                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 7,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _freshMint,
                    borderRadius:
                        BorderRadius.circular(9),
                  ),
                  child: const Text(
                    'Unverified',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight:
                          FontWeight.w700,
                      color: _mutedText,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // ----------------------------------------------------
          // METADATA
          // ----------------------------------------------------

          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  icon:
                      Icons.work_outline_rounded,
                  text:
                      '$experience yrs',
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _InfoChip(
                  icon:
                      Icons.location_on_outlined,
                  text: location.toString(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  icon:
                      Icons.schedule_rounded,
                  text: availability
                      .toString(),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _InfoChip(
                  icon:
                      Icons.star_outline_rounded,
                  text:
                      'Rating $rating',
                ),
              ),
            ],
          ),

          // ----------------------------------------------------
          // LANGUAGES
          // ----------------------------------------------------

          if (languages.isNotEmpty) ...[
            const SizedBox(height: 13),
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.language_rounded,
                  size: 15,
                  color: _darkGreen,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    languages.join(' • '),
                    style:
                        const TextStyle(
                      fontSize: 10,
                      color: _mutedText,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),

          // ----------------------------------------------------
          // BIO
          // ----------------------------------------------------

          Container(
            padding:
                const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _background,
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: Text(
              bio,
              style: const TextStyle(
                fontSize: 10.5,
                height: 1.45,
                color: _forestText,
              ),
            ),
          ),

          // ----------------------------------------------------
          // MATCH EXPLANATION
          // ----------------------------------------------------

          if (matchExplanation != null &&
              matchExplanation
                  .trim()
                  .isNotEmpty) ...[
            const SizedBox(height: 10),

            Container(
              padding:
                  const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _paleMint,
                borderRadius:
                    BorderRadius.circular(15),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 15,
                    color: _darkGreen,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      matchExplanation,
                      style:
                          const TextStyle(
                        fontSize: 10,
                        height: 1.4,
                        color: _forestText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 15),

          // ----------------------------------------------------
          // FOOTER
          // ----------------------------------------------------

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Contact the provider directly for details.',
                  style: TextStyle(
                    fontSize: 9,
                    color: _mutedText,
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _darkGreen,
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: const Row(
                  children: [
                    Text(
                      'View profile',
                      style:
                          TextStyle(
                        fontSize: 9,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            Colors.white,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color:
                          Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INFO CHIP
// ============================================================

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: _background,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: _darkGreen,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: _mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: _paleMint,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: _paleMint,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🌿',
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'No providers available yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _forestText,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'No professional profiles are available right now. Please check back later.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              height: 1.45,
              color: _mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CRISIS CARD
// ============================================================

class _CrisisCard extends StatelessWidget {
  const _CrisisCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _freshMint,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: _celadon,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(0.68),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.priority_high_rounded,
              color: _darkGreen,
              size: 21,
            ),
          ),

          const SizedBox(width: 11),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Need immediate help?',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight:
                        FontWeight.w800,
                    color: _forestText,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'If you feel in immediate danger or may harm yourself, contact local emergency services or a crisis service now, and reach out to someone you trust.',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.45,
                    color: _mutedText,
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
// FOOTER
// ============================================================

class _SupportFooter extends StatelessWidget {
  const _SupportFooter();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Text(
          'MindSphere is here to help you notice when extra support might be useful. Choosing professional care is always your decision.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9.5,
            height: 1.45,
            color: _mutedText,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOADING
// ============================================================

class _LoadingSupport
    extends StatelessWidget {
  const _LoadingSupport();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: _paleMint,
              borderRadius:
                  BorderRadius.circular(23),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              size: 32,
              color: _darkGreen,
            ),
          ),

          const SizedBox(height: 16),

          const CircularProgressIndicator(
            color: _darkGreen,
            strokeWidth: 2.5,
          ),

          const SizedBox(height: 13),

          const Text(
            'Finding support options...',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _forestText,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Looking for professionals that may fit your needs.',
            style: TextStyle(
              fontSize: 10,
              color: _mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _SupportError
    extends StatelessWidget {
  const _SupportError({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(28),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _paleMint,
                borderRadius:
                    BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 32,
                color: _darkGreen,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Couldn’t load support options',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w800,
                color: _forestText,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                height: 1.4,
                color: _mutedText,
              ),
            ),

            const SizedBox(height: 17),

            SizedBox(
              height: 46,
              child:
                  ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 17,
                ),
                label: const Text(
                  'Try again',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      _darkGreen,
                  foregroundColor:
                      Colors.white,
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

