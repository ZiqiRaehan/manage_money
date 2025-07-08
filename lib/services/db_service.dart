import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/income.dart';
import '../models/expense.dart';
import '../models/saving.dart';
import '../models/user_profile.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'money_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE incomes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source TEXT,
        amount REAL,
        date TEXT,
        description TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item TEXT,
        price REAL,
        quantity INTEGER,
        date TEXT,
        category TEXT,
        description TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE savings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        title TEXT,
        amount REAL,
        date TEXT,
        targetDate TEXT,
        description TEXT,
        isCompleted INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE user_profile(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        position TEXT,
        school TEXT,
        dream TEXT,
        yearlyWishlist TEXT,
        profileImagePath TEXT
      )
    ''');
  }

  // CRUD Income
  Future<int> insertIncome(Income income) async {
    final db = await database;
    return await db.insert('incomes', income.toMap());
  }

  Future<List<Income>> getIncomes() async {
    final db = await database;
    final maps = await db.query('incomes', orderBy: 'date DESC');
    return maps.map((e) => Income.fromMap(e)).toList();
  }

  Future<int> deleteIncome(int id) async {
    final db = await database;
    return await db.delete('incomes', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Expense
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final maps = await db.query('expenses', orderBy: 'date DESC');
    return maps.map((e) => Expense.fromMap(e)).toList();
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Saving
  Future<int> insertSaving(Saving saving) async {
    final db = await database;
    return await db.insert('savings', saving.toMap());
  }

  Future<List<Saving>> getSavings() async {
    final db = await database;
    final maps = await db.query('savings', orderBy: 'date DESC');
    return maps.map((e) => Saving.fromMap(e)).toList();
  }

  Future<int> deleteSaving(int id) async {
    final db = await database;
    return await db.delete('savings', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD UserProfile
  Future<int> insertUserProfile(UserProfile profile) async {
    final db = await database;
    return await db.insert('user_profile', profile.toMap());
  }

  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    final maps = await db.query('user_profile', limit: 1);
    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUserProfile(UserProfile profile) async {
    final db = await database;
    return await db.update('user_profile', profile.toMap(),
        where: 'id = ?', whereArgs: [profile.id]);
  }
}
