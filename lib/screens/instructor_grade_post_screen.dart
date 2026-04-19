import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/grade_entry.dart';

class InstructorGradePostScreen extends StatefulWidget {
  const InstructorGradePostScreen({super.key});

  @override
  State<InstructorGradePostScreen> createState() =>
      _InstructorGradePostScreenState();
}

class _InstructorGradePostScreenState
    extends State<InstructorGradePostScreen> {
  final FirestoreService _service = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _students = [];
  bool _isLoadingStudents = true;

  String? _selectedStudentId;
  String? _selectedStudentName;
  String _courseName = '';
  String _assignmentTitle = '';
  double _score = 0;
  double _maxScore = 100;
  String _feedback = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final students = await _service.getAllStudents();
    setState(() {
      _students = students;
      _isLoadingStudents = false;
    });
  }

  Future<void> _postGrade() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a student')),
      );
      return;
    }
    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      final grade = GradeEntry(
        studentId: _selectedStudentId!,
        studentName: _selectedStudentName ?? '',
        instructorId: _service.currentUserId ?? '',
        courseId: '',
        courseName: _courseName,
        assignmentTitle: _assignmentTitle,
        score: _score,
        maxScore: _maxScore,
        feedback: _feedback.isNotEmpty ? _feedback : null,
        postedAt: DateTime.now(),
      );
      await _service.postGrade(grade);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Grade posted successfully!'),
          backgroundColor: Color(0xFF3ECFCF),
        ),
      );
      _formKey.currentState!.reset();
      setState(() {
        _selectedStudentId = null;
        _selectedStudentName = null;
        _score = 0;
        _maxScore = 100;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1740),
        elevation: 0,
        title: const Text(
          'Post Grade',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white),
        ),
      ),
      body: _isLoadingStudents
          ? const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFFFF6B6B)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B6B).withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.grade_rounded,
                              color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Post a Grade',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Students will see this immediately',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    _sectionLabel('SELECT STUDENT'),
                    const SizedBox(height: 10),
                    if (_students.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1740),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Text(
                          'No students have signed up yet.',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5)),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.1)),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedStudentId,
                          hint: Text(
                            'Choose a student...',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.4)),
                          ),
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: const Color(0xFF2A2466),
                          style: const TextStyle(color: Colors.white),
                          items: _students.map((s) {
                            return DropdownMenuItem<String>(
                              value: s['uid'],
                              child: Text(
                                '${s['name']} (${s['email']})',
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            final student = _students.firstWhere(
                                (s) => s['uid'] == val);
                            setState(() {
                              _selectedStudentId = val;
                              _selectedStudentName =
                                  student['name'] ?? '';
                            });
                          },
                        ),
                      ),
                    const SizedBox(height: 22),

                    _sectionLabel('GRADE DETAILS'),
                    const SizedBox(height: 10),
                    _darkField(
                      label: 'Course Name',
                      icon: Icons.book_rounded,
                      onSaved: (v) => _courseName = v ?? '',
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Enter course name'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _darkField(
                      label: 'Assignment / Exam Title',
                      icon: Icons.assignment_rounded,
                      onSaved: (v) => _assignmentTitle = v ?? '',
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Enter assignment title'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _darkField(
                            label: 'Score',
                            icon: Icons.star_rounded,
                            keyboardType: TextInputType.number,
                            onSaved: (v) =>
                                _score = double.tryParse(v ?? '0') ?? 0,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _darkField(
                            label: 'Max Points',
                            icon: Icons.show_chart_rounded,
                            keyboardType: TextInputType.number,
                            onSaved: (v) =>
                                _maxScore = double.tryParse(v ?? '100') ?? 100,
                            initialValue: '100',
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _darkField(
                      label: 'Feedback (optional)',
                      icon: Icons.comment_rounded,
                      maxLines: 3,
                      onSaved: (v) => _feedback = v ?? '',
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _postGrade,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send_rounded, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    'Post Grade',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.4),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );
  }

  Widget _darkField({
    required String label,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? initialValue,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF9E9EC8), size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        labelStyle:
            TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
      ),
      style: const TextStyle(color: Colors.white),
      validator: validator,
      onSaved: onSaved,
    );
  }
}
