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
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'email_database.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE emails (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT
      )
    ''');
  }

  Future<int> insertEmail(String email) async {
    Database db = await instance.database;
    return await db.insert('emails', {'email': email});
  }

  Future<List<String>> getEmails() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query('emails');
    return result.map((e) => e['email'] as String).toList();
  }
}
