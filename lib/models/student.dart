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
}
