class Assignment {
  final int? id;
  final int courseId;
  final String title;
  final String description;
  final double maxPoints;
  final double? earnedPoints;
  final DateTime dueDate;
  final String status; // pending, submitted, graded
  final double weight; // percentage weight in course grade

  Assignment({
    this.id,
    required this.courseId,
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
      'id': id,
      'courseId': courseId,
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
      courseId: map['courseId'],
      title: map['title'],
      description: map['description'],
      maxPoints: map['maxPoints'],
      earnedPoints: map['earnedPoints'],
      dueDate: DateTime.parse(map['dueDate']),
      status: map['status'],
      weight: map['weight'],
    );
  }
}