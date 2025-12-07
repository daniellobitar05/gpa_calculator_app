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
  double grade = 0.0;
  String semester = 'Spring';
  int creditHours = 3;
  String instructor = '';
  String description = '';
  int capacity = 30;
  int enrolled = 1;

  void _showCourseDialog({Course? course}) {
    if (course != null) {
      courseName = course.name;
      courseCode = course.code;
      grade = course.grade;
      semester = course.semester;
      creditHours = course.creditHours;
      instructor = course.instructor;
      description = course.description ?? '';
      capacity = course.capacity;
      enrolled = course.enrolled;
    } else {
      courseName = '';
      courseCode = '';
      grade = 0.0;
      semester = 'Spring';
      creditHours = 3;
      instructor = '';
      description = '';
      capacity = 30;
      enrolled = 1;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                TextFormField(
                  initialValue: grade != 0.0 ? grade.toString() : '',
                  decoration: const InputDecoration(labelText: 'Grade (0.0-4.0)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Enter grade' : null,
                  onSaved: (value) => grade = double.tryParse(value ?? '0') ?? 0.0,
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
                  value: semester,
                  decoration: const InputDecoration(labelText: 'Semester'),
                  items: const [
                    DropdownMenuItem(value: 'Spring', child: Text('Spring')),
                    DropdownMenuItem(value: 'Summer', child: Text('Summer')),
                    DropdownMenuItem(value: 'Fall', child: Text('Fall')),
                    DropdownMenuItem(value: 'Winter', child: Text('Winter')),
                  ],
                  onChanged: (value) => setState(() => semester = value ?? 'Spring'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                final provider = Provider.of<CourseProvider>(context, listen: false);
                
                if (course != null) {
                  provider.updateCourse(
                    Course(
                      id: course.id,
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
                }
                if (!mounted) return;
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
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
                        key: ValueKey(course.id),
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
                                provider.deleteCourse(course.id!);
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
