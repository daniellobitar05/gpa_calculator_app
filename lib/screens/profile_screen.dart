import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/student.dart';
import '../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Student student = Student(
    name: 'Loading...',
    id: '',
    department: '',
    email: '',
  );
  bool isLoading = true;
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userData = await _firestoreService.getUserProfile();
    if (userData != null) {
      if (mounted) {
        setState(() {
          student = Student.fromMap(userData);
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          // Fallback if no profile exists yet
          student = Student(
            name: 'New Student',
            id: '',
            department: '',
            email: _firestoreService.currentUserId ?? '',
          );
          isLoading = false;
        });
      }
    }
  }

  void _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        student.profileImage = image.path;
      });
      // Auto-save image path update
      _saveProfile();
    }
  }

  Future<void> _saveProfile() async {
    await _firestoreService.updateUserProfile(student.toMap());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: student.name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value!.isEmpty ? 'Enter name' : null,
                  onSaved: (value) => student.name = value!,
                ),
                TextFormField(
                  initialValue: student.id,
                  decoration: const InputDecoration(labelText: 'Student ID'),
                  validator: (value) => value!.isEmpty ? 'Enter ID' : null,
                  onSaved: (value) => student.id = value!,
                ),
                TextFormField(
                  initialValue: student.department,
                  decoration: const InputDecoration(labelText: 'Department'),
                  validator: (value) => value!.isEmpty ? 'Enter Department' : null,
                  onSaved: (value) => student.department = value!,
                ),
                // Email is usually not editable as it's linked to Auth
                TextFormField(
                  initialValue: student.email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  readOnly: true, // Make email read-only
                  enabled: false,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                setState(() {});
                _saveProfile();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: student.profileImage != null && student.profileImage!.isNotEmpty
                  ? FileImage(File(student.profileImage!))
                  : const AssetImage('assets/avatar.png') as ImageProvider,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(student.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${student.id}'),
                  Text('Department: ${student.department}'),
                  Text('Email: ${student.email}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editProfile,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
