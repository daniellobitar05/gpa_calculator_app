import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/grade_entry.dart';

class StudentGradesScreen extends StatelessWidget {
  const StudentGradesScreen({super.key});

  Color _gradeColor(String letter) {
    switch (letter) {
      case 'A':
        return const Color(0xFF3ECFCF);
      case 'B':
        return const Color(0xFF6C63FF);
      case 'C':
        return const Color(0xFFFFA726);
      case 'D':
        return const Color(0xFFFF7043);
      default:
        return const Color(0xFFFF5252);
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService service = FirestoreService();
    
    debugPrint('[STUDENT_GRADES_SCREEN] Build called, current user: ${service.currentUserId}');

    return Container(
      color: const Color(0xFF0F0C29),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: service.getGradesForStudent(),
        builder: (context, snapshot) {
          debugPrint('[STUDENT_GRADES_SCREEN] StreamBuilder state: ${snapshot.connectionState}');
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3ECFCF)),
            );
          }

          if (snapshot.hasError) {
            debugPrint('[STUDENT_GRADES_SCREEN] Error: ${snapshot.error}');
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final gradesList = snapshot.data ?? [];
          debugPrint('[STUDENT_GRADES_SCREEN] Received ${gradesList.length} grades');
          
          final grades = gradesList.map((m) => GradeEntry.fromMap(m)).toList();

          if (grades.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.grade_rounded,
                    size: 72,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No grades yet',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your instructor will post grades here',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.25),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return _buildGradesList(grades);
        },
      ),
    );
  }

  Widget _buildGradesList(List<GradeEntry> grades) {
    // Compute average
    final avg =
        grades.map((g) => g.percentage).reduce((a, b) => a + b) /
            grades.length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // GPA card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3ECFCF), Color(0xFF2196F3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3ECFCF).withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Average',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${avg.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${grades.length} grade${grades.length == 1 ? '' : 's'} received',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    grades.first.letterGrade,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'MY GRADES',
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        ...grades.map((grade) {
          final color = _gradeColor(grade.letterGrade);
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1740),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          grade.assignmentTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: color.withOpacity(0.5)),
                        ),
                        child: Text(
                          grade.letterGrade,
                          style: TextStyle(
                            color: color,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    grade.courseName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Score bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: grade.percentage / 100,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${grade.score.toStringAsFixed(0)} / ${grade.maxScore.toStringAsFixed(0)} pts',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${grade.percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (grade.feedback != null && grade.feedback!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.comment_rounded,
                              color: Color(0xFF9E9EC8), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              grade.feedback!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
