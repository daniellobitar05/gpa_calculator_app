class GradeEntry {
  final String? firestoreId;
  final String studentId;
  final String studentName;
  final String instructorId;
  final String courseId;
  final String courseName;
  final String assignmentTitle;
  final double score;
  final double maxScore;
  final String? feedback;
  final DateTime postedAt;

  GradeEntry({
    this.firestoreId,
    required this.studentId,
    required this.studentName,
    required this.instructorId,
    required this.courseId,
    required this.courseName,
    required this.assignmentTitle,
    required this.score,
    required this.maxScore,
    this.feedback,
    required this.postedAt,
  });

  double get percentage => (score / maxScore) * 100;

  String get letterGrade {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'instructorId': instructorId,
      'courseId': courseId,
      'courseName': courseName,
      'assignmentTitle': assignmentTitle,
      'score': score,
      'maxScore': maxScore,
      'feedback': feedback,
      'postedAt': postedAt.toIso8601String(),
    };
  }

  factory GradeEntry.fromMap(Map<String, dynamic> map) {
    return GradeEntry(
      firestoreId: map['firestoreId'],
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      instructorId: map['instructorId'] ?? '',
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      assignmentTitle: map['assignmentTitle'] ?? '',
      score: (map['score'] ?? 0).toDouble(),
      maxScore: (map['maxScore'] ?? 100).toDouble(),
      feedback: map['feedback'],
      postedAt: map['postedAt'] != null
          ? DateTime.parse(map['postedAt'])
          : DateTime.now(),
    );
  }
}
