import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/course.dart';
import '../models/assignment.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // ================= USER FUNCTIONS =================

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUserId == null) return null;
    final doc = await _db.collection('users').doc(currentUserId).get();
    return doc.data();
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (currentUserId == null) return;
    await _db.collection('users').doc(currentUserId).update(data);
  }

  // ================= COURSE FUNCTIONS =================

  CollectionReference get _coursesRef {
    return _db.collection('users').doc(currentUserId).collection('courses');
  }

  Future<void> addCourse(Course course) async {
    if (currentUserId == null) return;
    // We can let Firestore generate the ID, or use the one we might have transiently.
    // Ideally, for a new course, we let Firestore gen ID and update the model.
    // However, the model uses an int id (SQflite legacy). We might need to adapt the model to use String ID
    // OR we can generate a random INT ID if we want to keep the model as is for now, 
    // BUT Firestore IDs are strings. 
    // ADAPTATION STRATEGY: 
    // To minimize model changes for the user, we will store the 'int id' as a field if needed,
    // but best practice is to switch to String IDs. 
    // Given the instructions to "link them with keys", I will use String IDs for references.
    // I will NEED to update the Models to support String IDs or just map them.
    // For now, I'll update the Course model to use the document ID as the ID, 
    // but the existing code expects int. 
    // I will try to keep the int interface if possible, or refactor models. 
    // Refactoring Models is better.
    
    // Waiting for Refactor step. For now, creating the structure.
    await _coursesRef.add(course.toMap());
  }
  
  // NOTE: This service assumes Models will be updated to handle String IDs or we map them.
  // The existing SQLite ID is an int. Converting to Firestore usually implies moving to String UUIDs.
  // I will assume for now I should handle data transformation here or update models.
  // I will stick to the plan of refactoring "CourseProvider" which implies I might change models or mapping there.
  // Let's implement the methods assuming we pass Maps or Models.
  
  // Actually, to fully "Create seperate tables ... and link them", 
  // users/{userId}/courses/{courseId} is a good structure for privacy/security rules default.
  // assignments can be users/{userId}/assignments or users/{userId}/courses/{courseId}/assignments.
  // The user asked for "seperate tables", usually meaning collections.
  
  // Let's use root collections for scalability if requested "seperate tables", 
  // but subcollections under User is better for isolation.
  // I will use:
  // users/{uid}
  // users/{uid}/courses/{courseDocId}
  // users/{uid}/assignments/{assignmentDocId}  <-- containing courseId field.
  
  Stream<List<Map<String, dynamic>>> getCoursesStream() {
    if (currentUserId == null) return Stream.value([]);
    return _coursesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['firestoreId'] = doc.id; // Store Doc ID
        return data;
      }).toList();
    });
  }

  Future<void> updateCourse(String firestoreId, Map<String, dynamic> data) async {
    if (currentUserId == null) return;
    await _coursesRef.doc(firestoreId).update(data);
  }

  Future<void> deleteCourse(String firestoreId) async {
    if (currentUserId == null) return;
    await _coursesRef.doc(firestoreId).delete();
  }

  // ================= ASSIGNMENT FUNCTIONS =================

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
    await _assignmentsRef.add(assignmentData);
  }

  Future<void> updateAssignment(String firestoreId, Map<String, dynamic> data) async {
    if (currentUserId == null) return;
    await _assignmentsRef.doc(firestoreId).update(data);
  }

  Future<void> deleteAssignment(String firestoreId) async {
    if (currentUserId == null) return;
    await _assignmentsRef.doc(firestoreId).delete();
  }
}
