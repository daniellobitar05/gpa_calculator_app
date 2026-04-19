import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/course_provider.dart';
import 'screens/role_selection_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CourseProvider(),
      child: MaterialApp(
        title: 'UniPortal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0F0C29),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1A1740),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const RoleSelectionScreen(),
      ),
    );
  }
}