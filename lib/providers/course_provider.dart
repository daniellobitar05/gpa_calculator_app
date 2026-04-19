// This file has been regenerated - cache bust
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/course.dart';
import '../models/assignment.dart';
import '../models/grade_entry.dart';
import '../models/academic_standing.dart';

class CourseProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  
  List<Course> _courses = [];
  List<Assignment> _assignments = [];
  List<GradeEntry> _grades = [];
  AcademicStanding? _academicStanding;

  StreamSubscription? _coursesSubscription;
  StreamSubscription? _assignmentsSubscription;
  StreamSubscription? _gradesSubscription;

  CourseProvider() {
    // Listen to Auth State changes to subscribe/unsubscribe
    _authService.user.listen((user) {
      if (user != null) {
        _subscribeToData();
      } else {
        _unsubscribeFromData();
      }
    });
  }
  
  void _subscribeToData() {
    debugPrint('[PROVIDER] _subscribeToData called');
    
    _coursesSubscription?.cancel();
    _coursesSubscription = _firestoreService.getCoursesStream().listen((coursesData) {
      _courses = coursesData.map((c) => Course.fromMap(c)).toList();
      _updateAcademicStanding();
      notifyListeners();
    });

    _assignmentsSubscription?.cancel();
    _assignmentsSubscription = _firestoreService.getAssignmentsStream().listen((assignmentsData) {
      _assignments = assignmentsData.map((a) => Assignment.fromMap(a)).toList();
      notifyListeners();
    });

    _gradesSubscription?.cancel();
    debugPrint('[PROVIDER] Setting up grades subscription...');
    _gradesSubscription = _firestoreService.getGradesForStudent().listen((gradesData) {
      debugPrint('[PROVIDER] Received ${gradesData.length} grades');
      _grades = gradesData.map((g) => GradeEntry.fromMap(g)).toList();
      debugPrint('[PROVIDER] Converted to GradeEntry list, notifying listeners...');
      _updateAcademicStanding();
      notifyListeners();
    }, onError: (error) {
      debugPrint('[PROVIDER] Error in grades subscription: $error');
    });
  }

  void _unsubscribeFromData() {
    _coursesSubscription?.cancel();
    _assignmentsSubscription?.cancel();
    _gradesSubscription?.cancel();
    _courses = [];
    _assignments = [];
    _grades = [];
    _academicStanding = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _coursesSubscription?.cancel();
    _assignmentsSubscription?.cancel();
    _gradesSubscription?.cancel();
    super.dispose();
  }

  List<Course> get courses => _courses;
  List<Assignment> get assignments => _assignments;
  List<GradeEntry> get grades => _grades;
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
  double predictCourseGrade(String courseId) {
    if (courseId.isEmpty) return 0.0;
    final courseAssignments = _assignments.where((a) => a.courseFirestoreId == courseId).toList();
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
    if (_courses.isEmpty && _grades.isEmpty) {
      _academicStanding = null;
    } else if (_courses.isNotEmpty) {
      // Instructor or student with courses in their collection
      _academicStanding = AcademicStanding.calculate(
        gpa: weightedGPA,
        creditsEarned: totalCredits,
        creditsRequired: 120,
      );
    } else if (_grades.isNotEmpty) {
      // Student with grades from instructors (no courses in their collection)
      // Calculate GPA from grades
      final gradesGPA = _calculateGPAFromGrades();
      final estimatedCredits = _grades.length * 3; // Assume 3 credits per grade
      
      _academicStanding = AcademicStanding.calculate(
        gpa: gradesGPA,
        creditsEarned: estimatedCredits,
        creditsRequired: 120,
      );
    }
  }

  // Helper method to convert letter grades to GPA scale
  double _letterGradeToGPA(String letterGrade) {
    switch (letterGrade) {
      case 'A':
        return 4.0;
      case 'B':
        return 3.0;
      case 'C':
        return 2.0;
      case 'D':
        return 1.0;
      case 'F':
        return 0.0;
      default:
        return 0.0;
    }
  }

  // Calculate GPA from grades
  double _calculateGPAFromGrades() {
    if (_grades.isEmpty) return 0.0;
    
    double totalGPA = 0;
    for (var grade in _grades) {
      totalGPA += _letterGradeToGPA(grade.letterGrade);
    }
    return totalGPA / _grades.length;
  }

  Future<void> addCourse(Course course) async {
    try {
      await _firestoreService.addCourse(course);
    } catch (e) {
      debugPrint('Error adding course: $e');
      rethrow;
    }
  }

  Future<void> updateCourse(Course course) async {
    if (course.firestoreId == null) return;
    try {
      await _firestoreService.updateCourse(course.firestoreId!, course.toMap());
    } catch (e) {
      debugPrint('Error updating course: $e');
      rethrow;
    }
  }

  Future<void> deleteCourse(String firestoreId) async {
    try {
      await _firestoreService.deleteCourse(firestoreId);
    } catch (e) {
      debugPrint('Error deleting course: $e');
      rethrow;
    }
  }

  Future<void> addAssignment(Assignment assignment) async {
    try {
      await _firestoreService.addAssignment(assignment.toMap());
    } catch (e) {
      debugPrint('Error adding assignment: $e');
      rethrow;
    }
  }

  Future<void> updateAssignment(Assignment assignment) async {
    if (assignment.firestoreId == null) return;
    try {
      await _firestoreService.updateAssignment(assignment.firestoreId!, assignment.toMap());
    } catch (e) {
      debugPrint('Error updating assignment: $e');
      rethrow;
    }
  }

  Future<void> deleteAssignment(String firestoreId) async {
    try {
      await _firestoreService.deleteAssignment(firestoreId);
    } catch (e) {
      debugPrint('Error deleting assignment: $e');
      rethrow;
    }
  }

  // Get assignments by course
  List<Assignment> getAssignmentsByCourse(String courseId) {
    if (courseId.isEmpty) return [];
    return _assignments.where((a) => a.courseFirestoreId == courseId).toList();
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
