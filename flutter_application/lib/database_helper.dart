import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table for points
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        points INTEGER DEFAULT 0
      )
    ''');
  }

  /// **Users Table Methods**

  // Insert a new user with default points (0)
  Future<int> insertUser(String username, {int points = 0}) async {
    final db = await database;
    return await db.insert('users', {'username': username, 'points': points});
  }

  // Get all users sorted by points descending (Leaderboard)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users', orderBy: 'points DESC');
  }

  // Get a single user by ID
  Future<Map<String, dynamic>?> getUser(int id) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Update user points
  Future<int> updatePoints(int id, int newPoints) async {
    final db = await database;
    return await db.update(
      'users',
      {'points': newPoints},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
