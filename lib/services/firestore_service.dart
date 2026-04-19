import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../models/grade_entry.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // ================= USER FUNCTIONS =================

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    required String role, // 'instructor' or 'student'
  }) async {
    debugPrint('[FIRESTORE] createUserProfile called with uid=$uid, role=$role');
    try {
      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[FIRESTORE] Profile created successfully with role=$role');
      
      // Verify it was saved
      final saved = await _db.collection('users').doc(uid).get();
      debugPrint('[FIRESTORE] Verification - saved data: ${saved.data()}');
    } catch (e) {
      debugPrint('[FIRESTORE] ERROR creating profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUserId == null) {
      debugPrint('[FIRESTORE] getUserProfile - currentUserId is NULL!');
      return null;
    }
    debugPrint('[FIRESTORE] getUserProfile - fetching for uid: $currentUserId');
    final doc = await _db.collection('users').doc(currentUserId).get();
    debugPrint('[FIRESTORE] Document exists: ${doc.exists}, Data: ${doc.data()}');
    return doc.data();
  }

  Future<String?> getUserRole() async {
    debugPrint('[FIRESTORE] ========== GET USER ROLE START ==========');
    debugPrint('[FIRESTORE] currentUserId: $currentUserId');
    
    if (currentUserId == null) {
      debugPrint('[FIRESTORE] ERROR: currentUserId is NULL - cannot get role!');
      debugPrint('[FIRESTORE] ========== GET USER ROLE END (NULL) ==========');
      return null;
    }
    
    try {
      final profile = await getUserProfile();
      debugPrint('[FIRESTORE] Full profile data: $profile');
      
      if (profile == null) {
        debugPrint('[FIRESTORE] ERROR: Profile document does not exist!');
        debugPrint('[FIRESTORE] ========== GET USER ROLE END (NO PROFILE) ==========');
        return null;
      }
      
      final role = profile['role'];
      debugPrint('[FIRESTORE] Raw role value: $role (type: ${role.runtimeType})');
      
      // Validate role value
      if (role != null && role is String) {
        debugPrint('[FIRESTORE] Valid role found: $role');
        debugPrint('[FIRESTORE] ========== GET USER ROLE END (VALID) ==========');
        return role;
      } else {
        debugPrint('[FIRESTORE] ERROR: Role is invalid type or null: $role');
        debugPrint('[FIRESTORE] ========== GET USER ROLE END (INVALID) ==========');
        return null;
      }
    } catch (e) {
      debugPrint('[FIRESTORE] EXCEPTION in getUserRole: $e');
      debugPrint('[FIRESTORE] ========== GET USER ROLE END (EXCEPTION) ==========');
      return null;
    }
  }

  /// Check if current user is instructor (authorization helper)
  Future<bool> isInstructor() async {
    final role = await getUserRole();
    return role == 'instructor';
  }

  /// Check if current user is student (authorization helper)
  Future<bool> isStudent() async {
    final role = await getUserRole();
    return role == 'student';
  }

  /// Set or fix the role for current user (for existing accounts missing role field)
  Future<void> setUserRole(String role) async {
    if (currentUserId == null) return;
    debugPrint('[FIRESTORE] Setting role for user $currentUserId to: $role');
    await _db.collection('users').doc(currentUserId).update({'role': role});
    debugPrint('[FIRESTORE] Role updated successfully');
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (currentUserId == null) return;
    await _db.collection('users').doc(currentUserId).update(data);
  }

  // Fetch all students (for instructor to post grades)
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    final query = await _db
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();
    return query.docs.map((doc) {
      final data = doc.data();
      data['uid'] = doc.id;
      return data;
    }).toList();
  }

  // ================= COURSE FUNCTIONS =================

  CollectionReference get _coursesRef {
    return _db.collection('users').doc(currentUserId).collection('courses');
  }

  Future<void> addCourse(Course course) async {
    debugPrint('[FIRESTORE] addCourse: Starting...');
    debugPrint('[FIRESTORE] addCourse: currentUserId = $currentUserId');
    
    if (currentUserId == null) {
      debugPrint('[FIRESTORE] addCourse: ERROR - currentUserId is NULL!');
      return;
    }
    
    // Only instructors can create courses
    debugPrint('[FIRESTORE] addCourse: Checking if instructor...');
    final isInstr = await isInstructor();
    debugPrint('[FIRESTORE] addCourse: isInstructor = $isInstr');
    
    if (!isInstr) {
      debugPrint('[FIRESTORE] addCourse: ERROR - User is not an instructor!');
      throw Exception('Only instructors can create courses');
    }
    
    debugPrint('[FIRESTORE] addCourse: Saving course: ${course.name} (${course.code})');
    debugPrint('[FIRESTORE] addCourse: Course data: ${course.toMap()}');
    
    try {
      await _coursesRef.add(course.toMap());
      debugPrint('[FIRESTORE] addCourse: Course saved successfully!');
    } catch (e) {
      debugPrint('[FIRESTORE] addCourse: ERROR saving course: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getCoursesStream() {
    if (currentUserId == null) return Stream.value([]);
    return _coursesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['firestoreId'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> updateCourse(String firestoreId, Map<String, dynamic> data) async {
    if (currentUserId == null) return;
    // Only instructors can update courses
    if (!await isInstructor()) {
      throw Exception('Only instructors can update courses');
    }
    await _coursesRef.doc(firestoreId).update(data);
  }

  Future<void> deleteCourse(String firestoreId) async {
    if (currentUserId == null) return;
    // Only instructors can delete courses
    if (!await isInstructor()) {
      throw Exception('Only instructors can delete courses');
    }
    await _coursesRef.doc(firestoreId).delete();
  }

  // ================= INSTRUCTOR ASSIGNMENT FUNCTIONS (private) =================

  CollectionReference get _assignmentsRef {
    return _db.collection('users').doc(currentUserId).collection('assignments');
  }

  Stream<List<Map<String, dynamic>>> getAssignmentsStream() {
    if (currentUserId == null) return Stream.value([]);
    return _assignmentsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['firestoreId'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> addAssignment(Map<String, dynamic> assignmentData) async {
    if (currentUserId == null) return;
    // Only instructors can create assignments
    if (!await isInstructor()) {
      throw Exception('Only instructors can create assignments');
    }
    
    // FIRST: Post to shared_assignments so students can see it immediately
    final sharedId = await postSharedAssignment(assignmentData);
    
    // THEN: Store in instructor's private collection with reference to shared assignment
    assignmentData['sharedAssignmentId'] = sharedId;
    await _assignmentsRef.add(assignmentData);
  }

  Future<void> updateAssignment(String firestoreId, Map<String, dynamic> data) async {
    if (currentUserId == null) return;
    // Only instructors can update assignments
    if (!await isInstructor()) {
      throw Exception('Only instructors can update assignments');
    }
    
    // Get the instructor's assignment to find shared ID
    final doc = await _assignmentsRef.doc(firestoreId).get();
    final assignmentData = doc.data() as Map<String, dynamic>?;
    final sharedId = assignmentData?['sharedAssignmentId'] as String?;
    
    // Update in instructor's collection
    await _assignmentsRef.doc(firestoreId).update(data);
    
    // ALSO update in shared_assignments if linked
    if (sharedId != null) {
      // Remove sharedAssignmentId from update data to avoid storing it again
      final updateData = Map<String, dynamic>.from(data);
      updateData.remove('sharedAssignmentId');
      await updateSharedAssignment(sharedId, updateData);
    }
  }

  Future<void> deleteAssignment(String firestoreId) async {
    if (currentUserId == null) return;
    // Only instructors can delete assignments
    if (!await isInstructor()) {
      throw Exception('Only instructors can delete assignments');
    }
    
    // Get the instructor's assignment to find shared ID
    final doc = await _assignmentsRef.doc(firestoreId).get();
    final assignmentData = doc.data() as Map<String, dynamic>?;
    final sharedId = assignmentData?['sharedAssignmentId'] as String?;
    
    // Delete from instructor's collection
    await _assignmentsRef.doc(firestoreId).delete();
    
    // ALSO delete from shared_assignments if linked
    if (sharedId != null) {
      await deleteSharedAssignment(sharedId);
    }
  }

  // ================= SHARED ASSIGNMENTS (instructor posts → students see) =================

  // Instructor posts a shared assignment visible to all students - returns the shared assignment ID
  Future<String?> postSharedAssignment(Map<String, dynamic> data) async {
    if (currentUserId == null) return null;
    data['instructorId'] = currentUserId;
    data['postedAt'] = DateTime.now().toIso8601String();
    if (data['submissions'] == null) {
      data['submissions'] = {};
    }
    final docRef = await _db.collection('shared_assignments').add(data);
    return docRef.id;
  }

  Future<void> updateSharedAssignment(String docId, Map<String, dynamic> data) async {
    await _db.collection('shared_assignments').doc(docId).update(data);
  }

  Future<void> deleteSharedAssignment(String docId) async {
    await _db.collection('shared_assignments').doc(docId).delete();
  }

  // Get shared assignments posted by this instructor
  Stream<List<Map<String, dynamic>>> getSharedAssignmentsByInstructor() {
    if (currentUserId == null) return Stream.value([]);
    return _db
        .collection('shared_assignments')
        .where('instructorId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['firestoreId'] = doc.id;
              return data;
            }).toList());
  }

  // Student gets all shared assignments
  Stream<List<Map<String, dynamic>>> getSharedAssignmentsForStudent() {
    return _db
        .collection('shared_assignments')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['firestoreId'] = doc.id;
              return data;
            }).toList());
  }

  // Student submits an assignment (adds their submission inside the document)
  Future<void> submitAssignment({
    required String assignmentDocId,
    required String notes,
    String? fileUrl,
  }) async {
    if (currentUserId == null) return;
    final profile = await getUserProfile();
    final studentName = profile?['name'] ?? 'Student';
    await _db.collection('shared_assignments').doc(assignmentDocId).update({
      'submissions.$currentUserId': {
        'studentId': currentUserId,
        'studentName': studentName,
        'notes': notes,
        'fileUrl': fileUrl,
        'submittedAt': DateTime.now().toIso8601String(),
        'status': 'submitted',
      }
    });
  }

  // ================= GRADES (instructor posts → student sees) =================

  Future<void> postGrade(GradeEntry grade) async {
    if (currentUserId == null) return;
    // Only instructors can post grades
    if (!await isInstructor()) {
      throw Exception('Only instructors can post grades');
    }
    debugPrint('[FIRESTORE] postGrade: Saving grade for studentId=${grade.studentId}');
    debugPrint('[FIRESTORE] postGrade: Full grade data: ${grade.toMap()}');
    await _db.collection('grades').add(grade.toMap());
    debugPrint('[FIRESTORE] postGrade: Grade saved successfully');
  }

  Future<void> deleteGrade(String gradeId) async {
    // Only instructors can delete grades
    if (!await isInstructor()) {
      throw Exception('Only instructors can delete grades');
    }
    await _db.collection('grades').doc(gradeId).delete();
  }

  // Instructor sees all grades they've posted
  Stream<List<Map<String, dynamic>>> getGradesByInstructor() {
    if (currentUserId == null) return Stream.value([]);
    return _db
        .collection('grades')
        .where('instructorId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['firestoreId'] = doc.id;
              return data;
            }).toList());
  }

  // Student sees their own grades
  Stream<List<Map<String, dynamic>>> getGradesForStudent() {
    if (currentUserId == null) {
      debugPrint('[FIRESTORE] getGradesForStudent: currentUserId is NULL!');
      return Stream.value([]);
    }
    
    debugPrint('[FIRESTORE] getGradesForStudent: Setting up stream for studentId=$currentUserId');
    
    return _db
        .collection('grades')
        .where('studentId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          debugPrint('[FIRESTORE] getGradesForStudent: Got ${snapshot.docs.length} grades for studentId=$currentUserId');
          for (var doc in snapshot.docs) {
            debugPrint('[FIRESTORE] Grade data: ${doc.data()}');
          }
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['firestoreId'] = doc.id;
            return data;
          }).toList();
        });
  }
}
