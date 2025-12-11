import 'package:flutter/material.dart';

import 'screens/profile_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/grades_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/assignments_screen.dart';

class UniversityApp extends StatefulWidget {
  const UniversityApp({super.key});

  @override
  State<UniversityApp> createState() => _UniversityAppState();
}

class _UniversityAppState extends State<UniversityApp> {
  int selectedIndex = 0;
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = const [
      ProfileScreen(),
      CoursesScreen(),
      AssignmentsScreen(),
      AnalyticsScreen(),
      GradesScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('University App'),
        elevation: 0,
      ),
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grade),
            label: 'Grades',
          ),
        ],
      ),
    );
  }
}