import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';
import '../main_app.dart';
import '../student_app.dart';

class SignUpScreen extends StatefulWidget {
  final String role; // 'student' or 'instructor'
  const SignUpScreen({super.key, required this.role});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  Color get _roleColor => widget.role == 'student'
      ? const Color(0xFF3ECFCF)
      : const Color(0xFFFF6B6B);

  IconData get _roleIcon => widget.role == 'student'
      ? Icons.person_rounded
      : Icons.cast_for_education_rounded;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential =
          await _authService.signUp(email: email, password: password);

      if (credential != null && credential.user != null) {
        debugPrint('[SIGNUP DEBUG] Creating profile with role: ${widget.role}');
        await _firestoreService.createUserProfile(
          uid: credential.user!.uid,
          name: name,
          email: email,
          role: widget.role,
        );
        debugPrint('[SIGNUP DEBUG] Profile created successfully');

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => widget.role == 'student'
                ? const StudentApp()
                : const UniversityApp(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
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
                      border: Border.all(color: _roleColor.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_roleIcon, color: _roleColor, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          widget.role == 'student'
                              ? 'Student Account'
                              : 'Instructor Account',
                          style: TextStyle(
                            color: _roleColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Create\nAccount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join UniPortal as a ${widget.role}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Fields
                  _buildField(
                    label: 'Full Name',
                    icon: Icons.badge_rounded,
                    onSaved: (v) => name = v ?? '',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Email Address',
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (v) => email = v ?? '',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter your email' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    label: 'Password',
                    obscure: _obscurePassword,
                    onToggle: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    onSaved: (v) => password = v ?? '',
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Minimum 6 characters'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    label: 'Confirm Password',
                    obscure: _obscureConfirm,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    onSaved: (v) => confirmPassword = v ?? '',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Confirm your password' : null,
                  ),
                  const SizedBox(height: 36),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signup,
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
                              'Create Account',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(role: widget.role),
                        ),
                      ),
                      child: Text(
                        'Already have an account? Sign In',
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

  Widget _buildField({
    required String label,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF9E9EC8)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.55)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _roleColor, width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
      ),
      style: const TextStyle(color: Colors.white),
      validator: validator,
      onSaved: onSaved,
    );
  }

  Widget _buildPasswordField({
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            const Icon(Icons.lock_rounded, color: Color(0xFF9E9EC8)),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: const Color(0xFF9E9EC8),
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.55)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _roleColor, width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
      ),
      style: const TextStyle(color: Colors.white),
      validator: validator,
      onSaved: onSaved,
    );
  }
}
