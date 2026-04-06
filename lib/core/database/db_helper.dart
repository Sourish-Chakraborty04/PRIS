import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  // 1. SINGLETON PATTERN: Prevents opening multiple database connections at once
  static final DBHelper _instance = DBHelper._internal();
  static Database? _db;

  DBHelper._internal();
  factory DBHelper() => _instance;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'pris_vault.db'); // Changed name to force a fresh start
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Shift Table - ('hours' column for easier calculation)
        await db.execute('''
          CREATE TABLE shifts(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            date TEXT, 
            startTime TEXT, 
            endTime TEXT, 
            hours REAL, 
            earnings REAL
          )
        ''');

        // Expense Table
        await db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            category TEXT, 
            amount REAL, 
            date TEXT
          )
        ''');

        // Bike Table
        await db.execute('''
          CREATE TABLE bike_profile(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            tankSize REAL, 
            reserve REAL, 
            mileage REAL
          )
        ''');

        await db.execute('''
          CREATE TABLE settings(
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');

        // Categories Table
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            emoji TEXT,
            macro TEXT,
            keywords TEXT, 
            color_value INTEGER
          )
        ''');

        // Default bike settings
        await db.insert('bike_profile', {
          'tankSize': 10.0,
          'reserve': 1.0,
          'mileage': 55.0
        });
      },
    );
  }

  // --- WORK / SHIFT METHODS ---

  // SAVE a shift to the database
  Future<int> insertShift(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('shifts', row);
  }
  // Delete a shift details
  Future<int> deleteShift(int id) async {
    final db = await database; // or your getDatabase() method
    return await db.delete(
      'shifts', // your table name
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // GET all shifts (latest first)
  Future<List<Map<String, dynamic>>> getAllShifts() async {
    Database db = await database;
    return await db.query('shifts', orderBy: 'id DESC');
  }

  // --- EXPENSE METHODS ---

  // SAVE an expense
  Future<int> insertExpense(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('expenses', row);
  }

  // GET all expenses
  Future<List<Map<String, dynamic>>> getAllExpenses() async {
    Database db = await database;
    return await db.query('expenses', orderBy: 'id DESC');
  }
  // Helper methods
  Future<void> updateSetting(String key, String value) async {
    Database db = await database;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    Database db = await database;
    List<Map<String, dynamic>> res = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    return res.isNotEmpty ? res.first['value'] as String : null;
  }

  Future<int> insertCategory(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('categories', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    Database db = await database;
    return await db.query('categories');
  }
}