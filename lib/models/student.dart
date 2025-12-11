class Student {
  String name;
  String id;
  String department;
  String email;
  String? profileImage;

  Student({
    required this.name,
    required this.id,
    required this.department,
    required this.email,
    this.profileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'studentId': id, // Mapped to studentId in Firestore to avoid confusion with doc ID
      'department': department,
      'email': email,
      'profileImage': profileImage,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      name: map['name'] ?? '',
      id: map['studentId'] ?? '',
      department: map['department'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'],
    );
  }
}
