class Course {
  final int? id; // SQLite ID, kept for compatibility if needed, but likely null for Firestore
  final String? firestoreId; // Firestore Document ID
  final String name;
  final String code;
  final double grade;
  final String semester;
  final int creditHours; // for weighted GPA
  final String instructor;
  final String? description;
  final int capacity;
  final int enrolled;

  Course({
    this.id,
    this.firestoreId,
    required this.name,
    required this.code,
    required this.grade,
    required this.semester,
    required this.creditHours,
    required this.instructor,
    this.description,
    this.capacity = 30,
    this.enrolled = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'id': id, // Don't send local ID to Firestore usually, unless migrating.
      'name': name,
      'code': code,
      'grade': grade,
      'semester': semester,
      'creditHours': creditHours,
      'instructor': instructor,
      'description': description,
      'capacity': capacity,
      'enrolled': enrolled,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'], // Might be null from Firestore
      firestoreId: map['firestoreId'], // Injected by Service
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      grade: (map['grade'] ?? 0).toDouble(),
      semester: map['semester'] ?? '',
      creditHours: map['creditHours'] ?? 3,
      instructor: map['instructor'] ?? 'Unknown',
      description: map['description'],
      capacity: map['capacity'] ?? 30,
      enrolled: map['enrolled'] ?? 1,
    );
  }
}

