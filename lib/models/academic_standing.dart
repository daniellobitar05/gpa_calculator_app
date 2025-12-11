class AcademicStanding {
  final String level;
  final double gpa;
  final int creditsEarned;
  final int creditsRequired;

  AcademicStanding({
    required this.level,
    required this.gpa,
    required this.creditsEarned,
    required this.creditsRequired,
  });

  // Factory method to calculate standing from GPA
  factory AcademicStanding.calculate({
    required double gpa,
    required int creditsEarned,
    required int creditsRequired,
  }) {
    String level;
    if (gpa >= 3.7 && gpa <= 4.0) {
      level = 'Excellent';
    } else if (gpa >= 2.7 && gpa < 3.7) {
      level = 'Good';
    } else if (gpa >= 2.0 && gpa < 2.7) {
      level = 'Satisfactory';
    } else {
      level = 'Probation';
    }

    return AcademicStanding(
      level: level,
      gpa: gpa,
      creditsEarned: creditsEarned,
      creditsRequired: creditsRequired,
    );
  }

  @override
  String toString() =>
      'AcademicStanding(level: $level, gpa: $gpa, creditsEarned: $creditsEarned)';
}