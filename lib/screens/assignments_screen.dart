import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../models/assignment.dart';
import '../models/course.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final _formKey = GlobalKey<FormState>();
  String selectedCourse = '';
  String assignmentTitle = '';
  String description = '';
  double maxPoints = 0.0;
  double? earnedPoints;
  DateTime dueDate = DateTime.now();
  double weight = 10.0;

  void _showAssignmentDialog({
    Assignment? assignment,
    required List<Course> courses,
  }) {
    if (courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a course first')),
      );
      return;
    }

    // Reset and set values
    if (assignment != null) {
      selectedCourse = assignment.courseId.toString();
      assignmentTitle = assignment.title;
      description = assignment.description ?? '';
      maxPoints = assignment.maxPoints;
      earnedPoints = assignment.earnedPoints;
      dueDate = assignment.dueDate;
      weight = assignment.weight;
    } else {
      selectedCourse = (courses[0].id ?? 0).toString();
      assignmentTitle = '';
      description = '';
      maxPoints = 0.0;
      earnedPoints = null;
      dueDate = DateTime.now();
      weight = 10.0;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(assignment != null ? 'Edit Assignment' : 'Add Assignment'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCourse.isNotEmpty ? selectedCourse : null,
                    items: courses
                        .map((course) => DropdownMenuItem(
                              value: (course.id ?? 0).toString(),
                              child: Text(course.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCourse = value ?? '';
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Course'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select a course'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: assignmentTitle,
                    decoration: const InputDecoration(labelText: 'Assignment Title'),
                    onChanged: (value) {
                      assignmentTitle = value;
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    onChanged: (value) {
                      description = value;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: maxPoints != 0.0 ? maxPoints.toString() : '',
                    decoration: const InputDecoration(labelText: 'Max Points'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      maxPoints = double.tryParse(value) ?? 0.0;
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: earnedPoints?.toString() ?? '',
                    decoration: const InputDecoration(
                        labelText: 'Earned Points (Optional)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      earnedPoints = double.tryParse(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: weight.toString(),
                    decoration: const InputDecoration(labelText: 'Weight (%)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      weight = double.tryParse(value) ?? 10.0;
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: const Text('Due Date'),
                    subtitle: Text(dueDate.toString().split(' ')[0]),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: dialogContext,
                        initialDate: dueDate,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setDialogState(() {
                          dueDate = date;
                        });
                      }
                    },
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
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final provider =
                      Provider.of<CourseProvider>(context, listen: false);

                  try {
                    if (assignment != null) {
                      await provider.updateAssignment(
                        Assignment(
                          id: assignment.id,
                          courseId: int.parse(selectedCourse),
                          title: assignmentTitle,
                          description: description,
                          maxPoints: maxPoints,
                          earnedPoints: earnedPoints,
                          dueDate: dueDate,
                          weight: weight,
                        ),
                      );
                    } else {
                      await provider.addAssignment(
                        Assignment(
                          courseId: int.parse(selectedCourse),
                          title: assignmentTitle,
                          description: description,
                          maxPoints: maxPoints,
                          earnedPoints: earnedPoints,
                          dueDate: dueDate,
                          weight: weight,
                        ),
                      );
                    }
                    if (!mounted) return;
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(assignment != null
                            ? 'Assignment updated'
                            : 'Assignment added'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
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
        final overdue = provider.getOverdueAssignments();
        final pending = provider.getPendingAssignments();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Assignments'),
            elevation: 0,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                _showAssignmentDialog(courses: provider.courses),
            tooltip: 'Add Assignment',
            child: const Icon(Icons.add),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (overdue.isNotEmpty) ...[
                  const Text(
                    'Overdue Assignments',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: overdue.map((assignment) {
                      final course = provider.courses.firstWhere(
                        (c) => c.id == assignment.courseId,
                        orElse: () => Course(
                          name: 'Unknown',
                          code: 'N/A',
                          grade: 0.0,
                          semester: 'N/A',
                          creditHours: 0,
                          instructor: 'N/A',
                        ),
                      );
                      return Card(
                        color: Colors.red.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading:
                              const Icon(Icons.warning, color: Colors.red),
                          title: Text(assignment.title),
                          subtitle: Text(
                            '${course.name} • ${assignment.dueDate.toString().split(' ')[0]}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              provider.deleteAssignment(assignment.id!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Assignment deleted'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                const Text(
                  'Upcoming Assignments',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (pending.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No upcoming assignments',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  )
                else
                  Column(
                    children: pending.map((assignment) {
                      final course = provider.courses.firstWhere(
                        (c) => c.id == assignment.courseId,
                        orElse: () => Course(
                          name: 'Unknown',
                          code: 'N/A',
                          grade: 0.0,
                          semester: 'N/A',
                          creditHours: 0,
                          instructor: 'N/A',
                        ),
                      );
                      final daysUntil = assignment.dueDate
                          .difference(DateTime.now())
                          .inDays;
                      final progress = assignment.earnedPoints != null
                          ? (assignment.earnedPoints! / assignment.maxPoints) * 100
                          : 0.0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          assignment.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          course.name,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: daysUntil <= 3
                                          ? Colors.red.shade100
                                          : Colors.blue.shade100,
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      '$daysUntil days',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: daysUntil <= 3
                                            ? Colors.red
                                            : Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    assignment.earnedPoints != null
                                        ? '${assignment.earnedPoints}/${assignment.maxPoints} points'
                                        : 'Not graded',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    'Weight: ${assignment.weight.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: progress > 100 ? 1.0 : progress / 100,
                                      minHeight: 6,
                                      backgroundColor:
                                          Colors.grey.shade300,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        progress >= 70
                                            ? Colors.green
                                            : progress >= 50
                                                ? Colors.orange
                                                : Colors.red,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 80,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              size: 18),
                                          padding: EdgeInsets.zero,
                                          constraints:
                                              const BoxConstraints(),
                                          onPressed: () =>
                                              _showAssignmentDialog(
                                                assignment: assignment,
                                                courses: provider.courses,
                                              ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              size: 18),
                                          padding: EdgeInsets.zero,
                                          constraints:
                                              const BoxConstraints(),
                                          onPressed: () {
                                            provider.deleteAssignment(
                                                assignment.id!);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content:
                                                    Text('Assignment deleted'),
                                                duration:
                                                    Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}