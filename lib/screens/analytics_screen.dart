import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../models/course.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  Color _getStandingColor(String level) {
    switch (level.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'satisfactory':
        return Colors.orange;
      case 'probation':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStandingMessage(String level) {
    switch (level.toLowerCase()) {
      case 'excellent':
        return '🌟 Exceptional Performance! Keep it up!';
      case 'good':
        return '👍 Very Good Standing. Great work!';
      case 'satisfactory':
        return '✓ Satisfactory Performance. You\'re on track.';
      case 'probation':
        return '⚠️ Academic Probation. Seek academic support.';
      default:
        return 'Add courses to see standing.';
    }
  }

  Course _getUnknownCourse() {
    return Course(
      name: 'Unknown Course',
      code: 'N/A',
      grade: 0.0,
      semester: 'N/A',
      instructor: 'N/A',
      description: '',
      capacity: 0,
      enrolled: 0,
      creditHours: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        elevation: 0,
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          // Get unique semesters from courses
          final uniqueSemesters = provider.courses
              .map((c) => c.semester)
              .toSet()
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Academic Standing Card
                if (provider.academicStanding != null)
                  Card(
                    elevation: 4,
                    color: _getStandingColor(
                        provider.academicStanding!.level),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.academicStanding!.level
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getStandingMessage(
                                provider.academicStanding!.level),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Current GPA',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    provider.academicStanding!.gpa
                                        .toStringAsFixed(2),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Credits Earned',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    provider.academicStanding!
                                        .creditsEarned
                                        .toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
                    elevation: 2,
                    color: Colors.grey.shade100,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Add courses or wait for instructor grades to see your academic standing',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // GPA Section
                const Text(
                  'GPA Overview',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildGPACard(
                      'Weighted GPA',
                      (provider.courses.isNotEmpty 
                        ? provider.weightedGPA 
                        : (provider.academicStanding?.gpa ?? 0.0))
                          .toStringAsFixed(2),
                      Colors.blue,
                    ),
                    _buildGPACard(
                      'Simple GPA',
                      (provider.courses.isNotEmpty 
                        ? provider.simpleGPA 
                        : (provider.academicStanding?.gpa ?? 0.0))
                          .toStringAsFixed(2),
                      Colors.purple,
                    ),
                    _buildGPACard(
                      'Credits',
                      (provider.courses.isNotEmpty 
                        ? provider.totalCredits 
                        : provider.grades.length * 3)
                          .toString(),
                      Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Semester Performance or Grades
                Text(
                  provider.courses.isNotEmpty ? 'Semester Performance' : 'Received Grades',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (provider.courses.isEmpty && provider.grades.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No grades or courses added yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else if (provider.courses.isNotEmpty)
                  // Show semester performance for courses
                  Column(
                    children: uniqueSemesters.map((semester) {
                      final semesterCourses = provider.courses
                          .where((c) => c.semester == semester)
                          .toList();
                      final avgGrade = semesterCourses.isEmpty
                          ? 0.0
                          : semesterCourses
                                  .map((c) => c.grade)
                                  .reduce((a, b) => a + b) /
                              semesterCourses.length;
                      final totalCredits = semesterCourses.fold<int>(
                          0, (sum, c) => sum + c.creditHours);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(semester,
                                      style: const TextStyle(
                                          fontWeight:
                                              FontWeight.bold)),
                                  Text(
                                    'Avg Grade: ${avgGrade.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey),
                                  ),
                                ],
                              ),
                              Text(
                                'Credits: $totalCredits',
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )
                else
                  // Show received grades for students
                  Column(
                    children: provider.grades
                        .map((grade) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(grade.assignmentTitle,
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold),
                                            overflow: TextOverflow.ellipsis),
                                        Text(
                                          grade.courseName,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          grade.letterGrade,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${grade.percentage.toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        })
                        .toList(),
                  ),
                const SizedBox(height: 24),

                // Upcoming Assignments
                const Text(
                  'Upcoming Assignments (Next 5)',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (provider.getPendingAssignments().isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No upcoming assignments',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Column(
                    children: provider
                        .getPendingAssignments()
                        .take(5)
                        .map((assignment) {
                      final course = provider.courses.firstWhere(
                        (c) => c.firestoreId == assignment.courseFirestoreId,
                        orElse: _getUnknownCourse,
                      );

                      final daysUntil = assignment.dueDate
                          .difference(DateTime.now())
                          .inDays;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: daysUntil <= 3
                                ? Colors.red.shade100
                                : Colors.blue.shade100,
                            child: Text(
                              daysUntil.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: daysUntil <= 3
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                            ),
                          ),
                          title: Text(assignment.title),
                          subtitle: Text(
                            '${course.name} • Weight: ${assignment.weight}%',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            '$daysUntil d',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: daysUntil <= 3
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGPACard(
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}