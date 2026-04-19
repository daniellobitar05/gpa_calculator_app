import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Get user role from Firestore
  Future<String?> getUserRole() async {
    if (currentUserId == null) return null;
    try {
      final doc = await _db.collection('users').doc(currentUserId).get();
      return doc.data()?['role'] as String?;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  /// Set user role during signup
  Future<void> setUserRole(String uid, String role) async {
    try {
      await _db.collection('users').doc(uid).set({
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error setting user role: $e');
      rethrow;
    }
  }

  /// Check if current user is instructor
  Future<bool> isInstructor() async {
    final role = await getUserRole();
    return role == 'instructor';
  }

  /// Check if current user is student
  Future<bool> isStudent() async {
    final role = await getUserRole();
    return role == 'student';
  }

  /// Get stream of user role
  Stream<String?> getRoleStream() {
    if (currentUserId == null) return Stream.value(null);
    return _db.collection('users').doc(currentUserId).snapshots().map((doc) {
      return doc.data()?['role'] as String?;
    });
  }
}
