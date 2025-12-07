import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('university.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        department TEXT,
        profileImage TEXT,
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Courses table
    await db.execute('''
      CREATE TABLE courses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT UNIQUE NOT NULL,
        grade REAL NOT NULL,
        semester TEXT NOT NULL,
        creditHours INTEGER DEFAULT 3,
        instructor TEXT,
        description TEXT,
        capacity INTEGER DEFAULT 30,
        enrolled INTEGER DEFAULT 1,
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Assignments table
    await db.execute('''
      CREATE TABLE assignments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        courseId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        maxPoints REAL NOT NULL,
        earnedPoints REAL,
        dueDate TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        weight REAL NOT NULL,
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(courseId) REFERENCES courses(id) ON DELETE CASCADE
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns to courses table
      await db.execute('ALTER TABLE courses ADD COLUMN creditHours INTEGER DEFAULT 3');
      await db.execute('ALTER TABLE courses ADD COLUMN instructor TEXT');
      await db.execute('ALTER TABLE courses ADD COLUMN description TEXT');
      await db.execute('ALTER TABLE courses ADD COLUMN capacity INTEGER DEFAULT 30');
      await db.execute('ALTER TABLE courses ADD COLUMN enrolled INTEGER DEFAULT 1');

      // Create assignments table
      await db.execute('''
        CREATE TABLE assignments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          courseId INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          maxPoints REAL NOT NULL,
          earnedPoints REAL,
          dueDate TEXT NOT NULL,
          status TEXT DEFAULT 'pending',
          weight REAL NOT NULL,
          createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY(courseId) REFERENCES courses(id) ON DELETE CASCADE
        )
      ''');
    }
  }

  // ================= USER FUNCTIONS =================

  // Register a new user
  Future<int> registerUser(String name, String email, String password) async {
    final db = await database;
    return await db.insert('users', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  // Login / Get user by email & password
  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ================= COURSE FUNCTIONS =================

  // Insert a new course
  Future<int> insertCourse(Map<String, dynamic> course) async {
    final db = await database;
    return await db.insert('courses', course);
  }

  // Update an existing course
  Future<int> updateCourse(Map<String, dynamic> course) async {
    final db = await database;
    return await db.update(
      'courses',
      course,
      where: 'id = ?',
      whereArgs: [course['id']],
    );
  }

  // Delete a course
  Future<int> deleteCourse(int id) async {
    final db = await database;
    return await db.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get all courses
  Future<List<Map<String, dynamic>>> getCourses() async {
    final db = await database;
    return await db.query('courses');
  }

  // ================= ASSIGNMENT FUNCTIONS =================

  // Insert a new assignment
  Future<int> insertAssignment(Map<String, dynamic> assignment) async {
    final db = await database;
    return await db.insert('assignments', assignment);
  }

  // Update an existing assignment
  Future<int> updateAssignment(Map<String, dynamic> assignment) async {
    final db = await database;
    return await db.update(
      'assignments',
      assignment,
      where: 'id = ?',
      whereArgs: [assignment['id']],
    );
  }

  // Delete an assignment
  Future<int> deleteAssignment(int id) async {
    final db = await database;
    return await db.delete(
      'assignments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get all assignments
  Future<List<Map<String, dynamic>>> getAssignments() async {
    final db = await database;
    return await db.query('assignments');
  }

  // Get assignments by course ID
  Future<List<Map<String, dynamic>>> getAssignmentsByCourse(int courseId) async {
    final db = await database;
    return await db.query(
      'assignments',
      where: 'courseId = ?',
      whereArgs: [courseId],
    );
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
