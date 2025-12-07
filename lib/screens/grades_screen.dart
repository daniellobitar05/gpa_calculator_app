import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../providers/course_provider.dart';
import '../models/course.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  String? selectedSemester;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CourseProvider>(context);
    final semesters = provider.semesters;
    List<Course> courses = provider.courses;

    if (selectedSemester != null) {
      courses = courses.where((c) => c.semester == selectedSemester).toList();
    }

    double gpa = courses.isEmpty ? 0.0 : courses.map((c) => c.grade).reduce((a, b) => a + b) / courses.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (semesters.isNotEmpty)
            DropdownButton<String>(
              value: selectedSemester,
              hint: const Text('Filter by semester'),
              items: semesters.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (value) => setState(() => selectedSemester = value),
            ),
          const SizedBox(height: 16),
          CircularPercentIndicator(
            radius: 100,
            lineWidth: 12,
            percent: gpa / 100 > 1 ? 1 : gpa / 100,
            center: Text(gpa.toStringAsFixed(2), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            progressColor: Colors.blue,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: courses.isEmpty
                ? const Center(child: Text('No grades available'))
                : ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${course.code} • ${course.semester}'),
                          trailing: Text(course.grade.toString()),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
