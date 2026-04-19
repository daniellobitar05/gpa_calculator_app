import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class StudentAssignmentsScreen extends StatefulWidget {
  const StudentAssignmentsScreen({super.key});

  @override
  State<StudentAssignmentsScreen> createState() =>
      _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState
    extends State<StudentAssignmentsScreen> {
  final FirestoreService _service = FirestoreService();

  void _showSubmitDialog(
      BuildContext context, Map<String, dynamic> assignment) {
    final notesController = TextEditingController();
    final currentUserId = _service.currentUserId ?? '';
    final existing =
        (assignment['submissions'] as Map<dynamic, dynamic>?)?[currentUserId];

    if (existing != null) {
      notesController.text = existing['notes'] ?? '';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1740),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.upload_file_rounded,
                    color: Color(0xFF3ECFCF), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    existing != null
                        ? 'Update Submission'
                        : 'Submit Assignment',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              assignment['title'] ?? '',
              style: const TextStyle(
                  color: Color(0xFF3ECFCF),
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: notesController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Add your notes or comments here...',
                hintStyle:
                    TextStyle(color: Colors.white.withOpacity(0.35)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.07),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: Color(0xFF3ECFCF), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '✅ Your submission will be saved and visible to your instructor',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.35), fontSize: 12),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await _service.submitAssignment(
                      assignmentDocId: assignment['firestoreId'],
                      notes: notesController.text,
                    );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Submitted successfully!'),
                        backgroundColor: Color(0xFF3ECFCF),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error: ${e.toString()}')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3ECFCF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(
                  existing != null ? 'Update Submission' : 'Submit',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _service.currentUserId ?? '';

    return Container(
      color: const Color(0xFF0F0C29),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _service.getSharedAssignmentsForStudent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFF3ECFCF)),
            );
          }

          final assignments = snapshot.data ?? [];

          if (assignments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined,
                      size: 72,
                      color: Colors.white.withOpacity(0.15)),
                  const SizedBox(height: 16),
                  Text(
                    'No assignments yet',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your instructor will post assignments here',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.25),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: assignments.length,
            itemBuilder: (context, i) {
              final a = assignments[i];
              final submissions =
                  a['submissions'] as Map<dynamic, dynamic>? ?? {};
              final mySubmission = submissions[userId];
              final isSubmitted = mySubmission != null;
              final dueDate = a['dueDate'] != null
                  ? DateTime.tryParse(a['dueDate'])
                  : null;
              final isOverdue =
                  dueDate != null && dueDate.isBefore(DateTime.now());

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1740),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSubmitted
                        ? const Color(0xFF3ECFCF).withOpacity(0.4)
                        : isOverdue
                            ? const Color(0xFFFF5252).withOpacity(0.4)
                            : Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              a['title'] ?? 'Untitled',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _StatusBadge(
                            isSubmitted: isSubmitted,
                            isOverdue: isOverdue,
                          ),
                        ],
                      ),
                      if ((a['description'] ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          a['description'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 13.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 13,
                              color: Color(0xFF9E9EC8)),
                          const SizedBox(width: 5),
                          Text(
                            dueDate != null
                                ? 'Due: ${dueDate.toString().split(' ')[0]}'
                                : 'No due date',
                            style: TextStyle(
                              color: isOverdue
                                  ? const Color(0xFFFF5252)
                                  : const Color(0xFF9E9EC8),
                              fontSize: 12.5,
                              fontWeight: isOverdue
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Icon(Icons.stars_rounded,
                              size: 13,
                              color: Color(0xFF9E9EC8)),
                          const SizedBox(width: 5),
                          Text(
                            '${a['maxPoints'] ?? 0} pts',
                            style: const TextStyle(
                              color: Color(0xFF9E9EC8),
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                      if (isSubmitted && mySubmission['notes'] != null &&
                          mySubmission['notes'].isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3ECFCF).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFF3ECFCF)
                                    .withOpacity(0.2)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.note_rounded,
                                  color: Color(0xFF3ECFCF), size: 14),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  mySubmission['notes'],
                                  style: TextStyle(
                                    color:
                                        Colors.white.withOpacity(0.7),
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showSubmitDialog(context, a),
                          icon: Icon(
                            isSubmitted
                                ? Icons.edit_rounded
                                : Icons.upload_rounded,
                            size: 18,
                          ),
                          label: Text(
                            isSubmitted
                                ? 'Edit Submission'
                                : 'Submit Assignment',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSubmitted
                                ? Colors.white.withOpacity(0.1)
                                : const Color(0xFF3ECFCF),
                            foregroundColor: isSubmitted
                                ? Colors.white70
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isSubmitted;
  final bool isOverdue;

  const _StatusBadge(
      {required this.isSubmitted, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    if (isSubmitted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF3ECFCF).withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF3ECFCF).withOpacity(0.5)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded,
                color: Color(0xFF3ECFCF), size: 13),
            SizedBox(width: 4),
            Text(
              'Submitted',
              style: TextStyle(
                  color: Color(0xFF3ECFCF),
                  fontSize: 11,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    } else if (isOverdue) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFF5252).withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: const Color(0xFFFF5252).withOpacity(0.5)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_rounded,
                color: Color(0xFFFF5252), size: 13),
            SizedBox(width: 4),
            Text(
              'Overdue',
              style: TextStyle(
                  color: Color(0xFFFF5252),
                  fontSize: 11,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFA726).withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: const Color(0xFFFFA726).withOpacity(0.5)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule_rounded,
                color: Color(0xFFFFA726), size: 13),
            SizedBox(width: 4),
            Text(
              'Pending',
              style: TextStyle(
                  color: Color(0xFFFFA726),
                  fontSize: 11,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }
  }
}
