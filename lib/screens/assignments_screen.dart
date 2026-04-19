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
  String selectedCourseId = '';
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
    // Reset form
    if (assignment != null) {
      selectedCourseId = assignment.courseFirestoreId ?? '';
      assignmentTitle = assignment.title;
      description = assignment.description;
      maxPoints = assignment.maxPoints;
      earnedPoints = assignment.earnedPoints;
      dueDate = assignment.dueDate;
      weight = assignment.weight;
    } else {
      selectedCourseId = courses.isNotEmpty ? (courses.first.firestoreId ?? '') : '';
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
          title: Text(
            assignment != null ? 'Edit Assignment' : 'Add Assignment',
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Course Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: selectedCourseId.isNotEmpty ? selectedCourseId : null,
                    items: courses.map((course) {
                      return DropdownMenuItem(
                        value: course.firestoreId ?? '',
                        child: Text(course.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(
                        () => selectedCourseId = value ?? '',
                      );
                    },
                    decoration:
                        const InputDecoration(labelText: 'Select Course'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Select a course' : null,
                  ),
                  const SizedBox(height: 12),

                  // Assignment Title
                  TextFormField(
                    initialValue: assignmentTitle,
                    decoration: const InputDecoration(
                      labelText: 'Assignment Title',
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Enter title' : null,
                    onChanged: (value) => assignmentTitle = value,
                  ),
                  const SizedBox(height: 12),

                  // Description
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                    maxLines: 3,
                    onChanged: (value) => description = value,
                  ),
                  const SizedBox(height: 12),

                  // Max Points
                  TextFormField(
                    initialValue: maxPoints != 0.0
                        ? maxPoints.toString()
                        : '',
                    decoration: const InputDecoration(
                      labelText: 'Max Points',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Enter max points' : null,
                    onChanged: (value) =>
                        maxPoints = double.tryParse(value) ?? 0.0,
                  ),
                  const SizedBox(height: 12),

                  // Earned Points
                  TextFormField(
                    initialValue:
                        earnedPoints != null ? earnedPoints.toString() : '',
                    decoration: const InputDecoration(
                      labelText: 'Earned Points (Optional)',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        earnedPoints = double.tryParse(value),
                  ),
                  const SizedBox(height: 12),

                  // Weight
                  TextFormField(
                    initialValue:
                        weight != 0.0 ? weight.toString() : '10.0',
                    decoration: const InputDecoration(
                      labelText: 'Weight (%)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Enter weight' : null,
                    onChanged: (value) =>
                        weight = double.tryParse(value) ?? 10.0,
                  ),
                  const SizedBox(height: 12),

                  // Due Date Picker
                  ListTile(
                    title: const Text('Due Date'),
                    subtitle: Text(
                      dueDate.toString().split(' ')[0],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: dialogContext,
                        initialDate: dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setDialogState(() => dueDate = date);
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
                  final provider = Provider.of<CourseProvider>(
                    context,
                    listen: false,
                  );

                  try {
                    if (assignment != null) {
                      // Update existing assignment
                      await provider.updateAssignment(
                        Assignment(
                          id: assignment.id,
                          firestoreId: assignment.firestoreId,
                          courseId: assignment.courseId,
                          courseFirestoreId: selectedCourseId,
                          title: assignmentTitle,
                          description: description,
                          maxPoints: maxPoints,
                          earnedPoints: earnedPoints,
                          dueDate: dueDate,
                          status: assignment.status,
                          weight: weight,
                        ),
                      );
                    } else {
                      // Add new assignment
                      await provider.addAssignment(
                        Assignment(
                          courseFirestoreId: selectedCourseId,
                          courseId: null, // Legacy
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
                        content: Text(
                          assignment != null
                              ? 'Assignment updated'
                              : 'Assignment added',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        duration: const Duration(seconds: 2),
                      ),
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
            onPressed: provider.courses.isEmpty
                ? null
                : () => _showAssignmentDialog(
                      courses: provider.courses,
                    ),
            tooltip: provider.courses.isEmpty
                ? 'Add a course first'
                : 'Add Assignment',
            child: const Icon(Icons.add),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overdue Section
                if (overdue.isNotEmpty) ...[
                  const Text(
                    'Overdue Assignments ⚠️',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: overdue.map((assignment) {
                      return Card(
                        color: Colors.red.shade50,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.warning,
                            color: Colors.red,
                          ),
                          title: Text(assignment.title),
                          subtitle: Text(
                            'Due: ${assignment.dueDate.toString().split(' ')[0]}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              if (assignment.firestoreId != null) {
                                provider.deleteAssignment(assignment.firestoreId!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Assignment deleted'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Pending Section
                const Text(
                  'Upcoming Assignments 📅',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (pending.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No upcoming assignments',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Column(
                    children: pending.map((assignment) {
                      // Safely get course
                      final course = provider.courses.firstWhere(
                        (c) => c.firestoreId == assignment.courseFirestoreId,
                        orElse: () => Course(
                          name: 'Unknown Course',
                          code: 'N/A',
                          grade: 0.0,
                          semester: 'N/A',
                          instructor: 'N/A',
                          description: '',
                          capacity: 0,
                          enrolled: 0,
                          creditHours: 0,
                        ),
                      );

                      final daysUntil = assignment.dueDate
                          .difference(DateTime.now())
                          .inDays;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: daysUntil <= 3
                                  ? Colors.red.shade100
                                  : Colors.blue.shade100,
                              child: Text(
                                '$daysUntil',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: daysUntil <= 3
                                      ? Colors.red
                                      : Colors.blue,
                                ),
                              ),
                            ),
                            title: Text(
                              assignment.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(course.name),
                                const SizedBox(height: 4),
                                if (assignment.earnedPoints != null)
                                  Text(
                                    '${assignment.earnedPoints}/${assignment.maxPoints} points',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                else
                                  const Text(
                                    'Not graded yet',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: SizedBox(
                              width: 80,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 18),
                                    onPressed: () =>
                                        _showAssignmentDialog(
                                          assignment: assignment,
                                          courses: provider.courses,
                                        ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 18),
                                    onPressed: () {
                                      if (assignment.firestoreId != null) {
                                        provider.deleteAssignment(
                                            assignment.firestoreId!);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Assignment deleted'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
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
