import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'signup_screen.dart';
import 'role_selection_screen.dart';
import '../main_app.dart';
import '../student_app.dart';

class LoginScreen extends StatefulWidget {
  final String role; // 'student' or 'instructor'
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  String email = '';
  String password = '';
  bool _obscurePassword = true;
  bool _isLoading = false;

  Color get _roleColor => widget.role == 'student'
      ? const Color(0xFF3ECFCF)
      : const Color(0xFFFF6B6B);

  IconData get _roleIcon => widget.role == 'student'
      ? Icons.person_rounded
      : Icons.cast_for_education_rounded;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    try {
      debugPrint('[LOGIN] ========== LOGIN START ==========');
      final credential =
          await _authService.signIn(email: email, password: password);

      if (credential != null) {
        debugPrint('[LOGIN] Sign-in successful for: ${credential.user?.email}');
        debugPrint('[LOGIN] Getting user role from Firestore...');
        var role = await _authService.getUserRole();
        debugPrint('[LOGIN] Retrieved role: $role');

        if (!mounted) return;

        // If role is missing (null), prompt user to select role
        if (role == null || role.isEmpty) {
          debugPrint('[LOGIN] Role is missing! Prompting user to select...');
          _showRoleSelectionDialog();
          return;
        }

        // Route based on actual stored role
        debugPrint('[LOGIN] Making routing decision...');
        if (role == 'student') {
          debugPrint('[LOGIN] ✓ ROUTING TO STUDENT APP');
          debugPrint('[LOGIN] ========== LOGIN END (STUDENT) ==========');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const StudentApp()),
            (route) => false,
          );
        } else if (role == 'instructor') {
          debugPrint('[LOGIN] ✓ ROUTING TO INSTRUCTOR APP');
          debugPrint('[LOGIN] ========== LOGIN END (INSTRUCTOR) ==========');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const UniversityApp()),
            (route) => false,
          );
        } else {
          debugPrint('[LOGIN] ERROR: Unknown role: $role');
          _showRoleSelectionDialog();
          return;
        }
      } else {
        debugPrint('[LOGIN] Sign-in returned null credential');
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('[LOGIN] ERROR: $e');
      debugPrint('[LOGIN] ========== LOGIN END (EXCEPTION) ==========');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRoleSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1740),
        title: const Text(
          'Select Your Role',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This is the first time you\'re logging in. Please select your role:',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _setRoleAndRoute('student');
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_rounded, color: Color(0xFF3ECFCF)),
                SizedBox(width: 8),
                Text('Student', style: TextStyle(color: Color(0xFF3ECFCF))),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _setRoleAndRoute('instructor');
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cast_for_education_rounded, color: Color(0xFFFF6B6B)),
                SizedBox(width: 8),
                Text('Instructor', style: TextStyle(color: Color(0xFFFF6B6B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setRoleAndRoute(String role) async {
    try {
      // Save the role to Firestore
      final firestoreService = FirestoreService();
      await firestoreService.setUserRole(role);
      debugPrint('[LOGIN] Role set to: $role');

      if (!mounted) return;

      // Route based on selected role
      if (role == 'student') {
        debugPrint('[LOGIN] ✓ ROUTING TO STUDENT APP (after role fix)');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const StudentApp()),
          (route) => false,
        );
      } else {
        debugPrint('[LOGIN] ✓ ROUTING TO INSTRUCTOR APP (after role fix)');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const UniversityApp()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('[LOGIN] Error setting role: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RoleSelectionScreen()),
                    ),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 20),

                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _roleColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: _roleColor.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_roleIcon, color: _roleColor, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          widget.role == 'student'
                              ? 'Student Login'
                              : 'Instructor Login',
                          style: TextStyle(
                            color: _roleColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Welcome\nBack 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue to UniPortal',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_rounded,
                          color: Color(0xFF9E9EC8)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.07),
                      labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.55)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            BorderSide(color: _roleColor, width: 1.5),
                      ),
                      errorStyle:
                          const TextStyle(color: Color(0xFFFF6B6B)),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Enter your email'
                        : null,
                    onSaved: (v) => email = v ?? '',
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_rounded,
                          color: Color(0xFF9E9EC8)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: const Color(0xFF9E9EC8),
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.07),
                      labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.55)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            BorderSide(color: _roleColor, width: 1.5),
                      ),
                      errorStyle:
                          const TextStyle(color: Color(0xFFFF6B6B)),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Enter your password'
                        : null,
                    onSaved: (v) => password = v ?? '',
                  ),
                  const SizedBox(height: 36),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _roleColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SignUpScreen(role: widget.role),
                        ),
                      ),
                      child: Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
