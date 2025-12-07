class AcademicStanding {
  final String status; // excellent, good, warning, probation
  final double gpa;
  final int creditsEarned;
  final int creditsAttempted;
  final String message;

  AcademicStanding({
    required this.status,
    required this.gpa,
    required this.creditsEarned,
    required this.creditsAttempted,
    required this.message,
  });

  factory AcademicStanding.calculate(double gpa, int creditsEarned, int creditsAttempted) {
    String status;
    String message;

    if (gpa >= 3.5) {
      status = 'excellent';
      message = 'Dean\'s List - Excellent Academic Standing';
    } else if (gpa >= 3.0) {
      status = 'good';
      message = 'Good Academic Standing';
    } else if (gpa >= 2.0) {
      status = 'warning';
      message = 'Academic Standing Warning - GPA Below 3.0';
    } else {
      status = 'probation';
      message = 'Academic Probation - GPA Below 2.0';
    }

    return AcademicStanding(
      status: status,
      gpa: gpa,
      creditsEarned: creditsEarned,
      creditsAttempted: creditsAttempted,
      message: message,
    );
  }
}