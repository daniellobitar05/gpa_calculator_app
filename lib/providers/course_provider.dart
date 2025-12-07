import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/course.dart';
import '../models/assignment.dart';
import '../models/academic_standing.dart';

class CourseProvider with ChangeNotifier {
  List<Course> _courses = [];
  List<Assignment> _assignments = [];
  AcademicStanding? _academicStanding;

  List<Course> get courses => _courses;
  List<Assignment> get assignments => _assignments;
  AcademicStanding? get academicStanding => _academicStanding;

  // Weighted GPA calculation
  double get weightedGPA {
    if (_courses.isEmpty) return 0.0;
    double totalWeights = _courses.fold(0, (sum, c) => sum + c.creditHours);
    if (totalWeights == 0) return 0.0;
    double weightedSum = _courses.fold(0.0, (sum, c) => sum + (c.grade * c.creditHours));
    return weightedSum / totalWeights;
  }

  // Simple GPA
  double get simpleGPA {
    if (_courses.isEmpty) return 0.0;
    double total = _courses.map((c) => c.grade).reduce((a, b) => a + b);
    return total / _courses.length;
  }

  // Total credits
  int get totalCredits => _courses.fold(0, (sum, c) => sum + c.creditHours);

  List<String> get semesters {
    return _courses.map((c) => c.semester).toSet().toList();
  }

  // Grade prediction for a course
  double predictCourseGrade(int courseId) {
    final courseAssignments = _assignments.where((a) => a.courseId == courseId).toList();
    if (courseAssignments.isEmpty) return 0.0;
    
    double totalWeight = 0;
    double weightedScore = 0;
    
    for (var assignment in courseAssignments) {
      if (assignment.earnedPoints != null) {
        double percentage = (assignment.earnedPoints! / assignment.maxPoints) * 100;
        weightedScore += percentage * assignment.weight;
        totalWeight += assignment.weight;
      }
    }
    
    return totalWeight > 0 ? weightedScore / totalWeight : 0.0;
  }

  // Calculate academic standing
  void _updateAcademicStanding() {
    _academicStanding = AcademicStanding.calculate(
      weightedGPA,
      totalCredits,
      totalCredits,
    );
    notifyListeners();
  }

  Future<void> fetchCourses() async {
    final coursesMap = await DatabaseHelper.instance.getCourses();
    _courses = coursesMap.map((c) => Course.fromMap(c)).toList();
    _updateAcademicStanding();
    notifyListeners();
  }

  Future<void> fetchAssignments() async {
    final assignmentsMap = await DatabaseHelper.instance.getAssignments();
    _assignments = assignmentsMap.map((a) => Assignment.fromMap(a)).toList();
    notifyListeners();
  }

  Future<void> addCourse(Course course) async {
    await DatabaseHelper.instance.insertCourse(course.toMap());
    await fetchCourses();
  }

  Future<void> updateCourse(Course course) async {
    await DatabaseHelper.instance.updateCourse(course.toMap());
    await fetchCourses();
  }

  Future<void> deleteCourse(int id) async {
    await DatabaseHelper.instance.deleteCourse(id);
    await fetchCourses();
  }

  Future<void> addAssignment(Assignment assignment) async {
    await DatabaseHelper.instance.insertAssignment(assignment.toMap());
    await fetchAssignments();
  }

  Future<void> updateAssignment(Assignment assignment) async {
    await DatabaseHelper.instance.updateAssignment(assignment.toMap());
    await fetchAssignments();
  }

  Future<void> deleteAssignment(int id) async {
    await DatabaseHelper.instance.deleteAssignment(id);
    await fetchAssignments();
  }

  // Get assignments by course
  List<Assignment> getAssignmentsByCourse(int courseId) {
    return _assignments.where((a) => a.courseId == courseId).toList();
  }

  // Get pending assignments
  List<Assignment> getPendingAssignments() {
    return _assignments
        .where((a) => a.status == 'pending' && a.dueDate.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Get overdue assignments
  List<Assignment> getOverdueAssignments() {
    return _assignments
        .where((a) => a.status == 'pending' && a.dueDate.isBefore(DateTime.now()))
        .toList();
  }
}
