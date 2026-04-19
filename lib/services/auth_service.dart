import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Auth State Changes Stream
  Stream<User?> get user => _auth.authStateChanges();

  // Get Current User
  User? get currentUser => _auth.currentUser;

  // Sign Up
  Future<UserCredential?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint("Error signing up: ${e.message}");
      rethrow;
    }
  }

  // Sign In
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint("Error signing in: ${e.message}");
      rethrow;
    }
  }

  // Get role of currently signed-in user
  Future<String?> getUserRole() async {
    return await _firestoreService.getUserRole();
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }
}
