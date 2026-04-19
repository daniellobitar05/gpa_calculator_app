import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService service = FirestoreService();

    return Container(
      color: const Color(0xFF0F0C29),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: service.getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3ECFCF)),
            );
          }

          final profile = snapshot.data;
          final name = profile?['name'] ?? 'Student';
          final email = profile?['email'] ?? '';
          final initials = name.isNotEmpty
              ? name.trim().split(' ').map((e) => e[0]).take(2).join()
              : 'S';

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3ECFCF), Color(0xFF2196F3)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3ECFCF).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initials.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3ECFCF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF3ECFCF).withOpacity(0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_rounded,
                              color: Color(0xFF3ECFCF), size: 14),
                          SizedBox(width: 6),
                          Text(
                            'Student',
                            style: TextStyle(
                              color: Color(0xFF3ECFCF),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _InfoCard(
                icon: Icons.email_rounded,
                label: 'Email',
                value: email,
                color: const Color(0xFF6C63FF),
              ),
              const SizedBox(height: 14),
              _InfoCard(
                icon: Icons.badge_rounded,
                label: 'Account ID',
                value: service.currentUserId ?? 'N/A',
                color: const Color(0xFF3ECFCF),
              ),
              const SizedBox(height: 14),
              const _InfoCard(
                icon: Icons.school_rounded,
                label: 'Role',
                value: 'Student',
                color: Color(0xFFFFA726),
              ),

              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A1740), Color(0xFF2A2466)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUICK TIPS',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _Tip(
                      icon: Icons.assignment_rounded,
                      text:
                          'Go to Assignments to view and submit your work',
                    ),
                    const SizedBox(height: 10),
                    const _Tip(
                      icon: Icons.grade_rounded,
                      text:
                          'Check Grades to see scores posted by your instructor',
                    ),
                    const SizedBox(height: 10),
                    const _Tip(
                      icon: Icons.note_add_rounded,
                      text:
                          'You can add notes when submitting an assignment',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1740),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Tip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF9E9EC8), size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }
}
