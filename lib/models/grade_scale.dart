class GradeScale {
  final String name;
  final Map<String, double> scale; // A: 4.0, B: 3.0, etc.

  GradeScale({required this.name, required this.scale});

  static final Map<String, GradeScale> predefined = {
    'US (4.0)': GradeScale(
      name: 'US (4.0)',
      scale: {
        'A+': 4.0, 'A': 4.0, 'A-': 3.7,
        'B+': 3.3, 'B': 3.0, 'B-': 2.7,
        'C+': 2.3, 'C': 2.0, 'C-': 1.7,
        'D+': 1.3, 'D': 1.0, 'F': 0.0,
      },
    ),
    'European (5.0)': GradeScale(
      name: 'European (5.0)',
      scale: {
        'A': 5.0, 'B': 4.0, 'C': 3.0, 'D': 2.0, 'F': 1.0,
      },
    ),
  };

  double? getGradePoint(String grade) => scale[grade];
}