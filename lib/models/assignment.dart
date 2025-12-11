class Assignment {
  final int? id;
  final String? firestoreId;
  final int? courseId; // Legacy
  final String? courseFirestoreId; // New link
  final String title;
  final String description;
  final double maxPoints;
  final double? earnedPoints;
  final DateTime dueDate;
  final String status; // pending, submitted, graded
  final double weight; // percentage weight in course grade

  Assignment({
    this.id,
    this.firestoreId,
    this.courseId,
    this.courseFirestoreId,
    required this.title,
    required this.description,
    required this.maxPoints,
    this.earnedPoints,
    required this.dueDate,
    this.status = 'pending',
    required this.weight,
  });

  double? get percentage => earnedPoints != null ? (earnedPoints! / maxPoints) * 100 : null;

  Map<String, dynamic> toMap() {
    return {
      // 'id': id,
      // 'courseId': courseId, 
      'courseFirestoreId': courseFirestoreId,
      'title': title,
      'description': description,
      'maxPoints': maxPoints,
      'earnedPoints': earnedPoints,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'weight': weight,
    };
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'],
      firestoreId: map['firestoreId'],
      courseId: map['courseId'],
      courseFirestoreId: map['courseFirestoreId'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      maxPoints: (map['maxPoints'] ?? 0).toDouble(),
      earnedPoints: map['earnedPoints'] != null ? (map['earnedPoints'] as num).toDouble() : null,
      dueDate: DateTime.parse(map['dueDate']),
      status: map['status'] ?? 'pending',
      weight: (map['weight'] ?? 0).toDouble(),
    );
  }
}
