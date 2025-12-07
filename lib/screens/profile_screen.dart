import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/student.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Student student = Student(
    name: 'John Doe',
    id: '123456',
    department: 'Computer Science',
    email: 'johndoe@example.com',
  );

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  void _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        student.profileImage = image.path;
      });
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
                  decoration: const InputDecoration(labelText: 'ID'),
                  validator: (value) => value!.isEmpty ? 'Enter ID' : null,
                  onSaved: (value) => student.id = value!,
                ),
                TextFormField(
                  initialValue: student.department,
                  decoration: const InputDecoration(labelText: 'Department'),
                  validator: (value) => value!.isEmpty ? 'Enter Department' : null,
                  onSaved: (value) => student.department = value!,
                ),
                TextFormField(
                  initialValue: student.email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) => value!.isEmpty ? 'Enter Email' : null,
                  onSaved: (value) => student.email = value!,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: student.profileImage != null
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
