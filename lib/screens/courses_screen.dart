import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final _formKey = GlobalKey<FormState>();
  String courseName = '';
  String courseCode = '';
  String letterGrade = 'A';
  double grade = 4.0;
  String semester = 'Spring';
  int creditHours = 3;
  String instructor = '';
  String description = '';
  int capacity = 30;
  int enrolled = 1;

  // Letter grade to GPA mapping
  final Map<String, double> gradeMap = {
    'A+': 4.0,
    'A': 4.0,
    'A-': 3.7,
    'B+': 3.3,
    'B': 3.0,
    'B-': 2.7,
    'C+': 2.3,
    'C': 2.0,
    'C-': 1.7,
    'D+': 1.3,
    'D': 1.0,
    'F': 0.0,
  };

  // GPA to Letter grade mapping (for editing)
  String _getLetterGrade(double gpa) {
    for (var entry in gradeMap.entries) {
      if (entry.value == gpa) {
        return entry.key;
      }
    }
    return 'A';
  }

  void _showCourseDialog({Course? course}) {
    if (course != null) {
      courseName = course.name;
      courseCode = course.code;
      grade = course.grade;
      letterGrade = _getLetterGrade(course.grade);
      semester = course.semester;
      creditHours = course.creditHours;
      instructor = course.instructor;
      description = course.description ?? '';
      capacity = course.capacity;
      enrolled = course.enrolled;
    } else {
      courseName = '';
      courseCode = '';
      letterGrade = 'A';
      grade = 4.0;
      semester = 'Spring';
      creditHours = 3;
      instructor = '';
      description = '';
      capacity = 30;
      enrolled = 1;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(course != null ? 'Edit Course' : 'Add Course'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: courseName,
                    decoration: const InputDecoration(labelText: 'Course Name'),
                    validator: (value) => value?.isEmpty ?? true ? 'Enter course name' : null,
                    onSaved: (value) => courseName = value ?? '',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: courseCode,
                    decoration: const InputDecoration(labelText: 'Course Code'),
                    validator: (value) => value?.isEmpty ?? true ? 'Enter course code' : null,
                    onSaved: (value) => courseCode = value ?? '',
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: letterGrade,
                    decoration: InputDecoration(
                      labelText: 'Letter Grade',
                      helperText: 'GPA: ${gradeMap[letterGrade]?.toStringAsFixed(1)}',
                    ),
                    items: gradeMap.keys.map((String grade) {
                      return DropdownMenuItem(
                        value: grade,
                        child: Text('$grade (${gradeMap[grade]?.toStringAsFixed(1)})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        letterGrade = value ?? 'A';
                        grade = gradeMap[letterGrade] ?? 4.0;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: creditHours.toString(),
                    decoration: const InputDecoration(labelText: 'Credit Hours'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Enter credit hours' : null,
                    onSaved: (value) => creditHours = int.tryParse(value ?? '3') ?? 3,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: instructor,
                    decoration: const InputDecoration(labelText: 'Instructor Name'),
                    onSaved: (value) => instructor = value ?? '',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                    onSaved: (value) => description = value ?? '',
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: semester,
                    decoration: const InputDecoration(labelText: 'Semester'),
                    items: const [
                      DropdownMenuItem(value: 'Spring', child: Text('Spring')),
                      DropdownMenuItem(value: 'Summer', child: Text('Summer')),
                      DropdownMenuItem(value: 'Fall', child: Text('Fall')),
                      DropdownMenuItem(value: 'Winter', child: Text('Winter')),
                    ],
                    onChanged: (value) => setDialogState(() => semester = value ?? 'Spring'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final provider = Provider.of<CourseProvider>(context, listen: false);
                  
                  try {
                    if (course != null) {
                      provider.updateCourse(
                        Course(
                          id: course.id, // Legacy
                          firestoreId: course.firestoreId,
                          name: courseName,
                          code: courseCode,
                          grade: grade,
                          semester: semester,
                          creditHours: creditHours,
                          instructor: instructor,
                          description: description,
                          capacity: capacity,
                          enrolled: enrolled,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Course updated!')),
                      );
                    } else {
                      provider.addCourse(
                        Course(
                          name: courseName,
                          code: courseCode,
                          grade: grade,
                          semester: semester,
                          creditHours: creditHours,
                          instructor: instructor,
                          description: description,
                          capacity: capacity,
                          enrolled: enrolled,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Course added!')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('❌ Error: $e')),
                    );
                    debugPrint('Error saving course: $e');
                  }
                  
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Courses'),
            elevation: 0,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCourseDialog(),
            child: const Icon(Icons.add),
          ),
          body: provider.courses.isEmpty
              ? const Center(child: Text('No courses added yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: provider.courses.length,
                  itemBuilder: (context, index) {
                    final course = provider.courses[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Slidable(
                        key: ValueKey(course.firestoreId ?? course.id),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) => _showCourseDialog(course: course),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                            SlidableAction(
                              onPressed: (_) {
                                if (course.firestoreId != null) {
                                  provider.deleteCourse(course.firestoreId!);
                                }
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            title: Text(
                              course.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  '${course.code} • ${course.semester} • ${course.creditHours} credits',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Instructor: ${course.instructor}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                            trailing: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Text(
                                course.grade.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}