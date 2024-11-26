import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            password TEXT NOT NULL
          )
        ''');

        // Tambahkan user default
        await db.insert('users', {
          'username': 'user123',
          'password': 'password123' // Bisa menggunakan hashing di aplikasi nyata
        });
      },
    );
  }

  Future<Map<String, dynamic>?> getUser(String username, String password) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    return result.isNotEmpty ? result.first : null;
  }

  Future<void> insertUser(String username, String password) async {
    final db = await database;

    await db.insert(
      'users',
      {'username': username, 'password': password},
    );
  }
}
