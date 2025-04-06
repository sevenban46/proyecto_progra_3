import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../database/database_init.dart';
import '../models/financial_operation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static Future<void> initialize() async {
    await initDatabase(); // Añade esta línea
    await instance.database; // Esto fuerza la inicialización
  }


  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('financial_operations.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE financial_operations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT NOT NULL,
      description TEXT NOT NULL,
      amount REAL NOT NULL,
      rate REAL NOT NULL,
      period INTEGER NOT NULL,
      date TEXT NOT NULL,
      calculationType TEXT NOT NULL,
      paymentFrequency TEXT NOT NULL,
      paymentsPerYear INTEGER NOT NULL
    )
  ''');
  }

  // CRUD Operations
  Future<int> create(FinancialOperation operation) async {
    final db = await instance.database;
    return await db.insert('financial_operations', operation.toMap());
  }

  Future<List<FinancialOperation>> readAll() async {
    final db = await instance.database;
    final maps = await db.query('financial_operations');
    return maps.map((map) => FinancialOperation.fromMap(map)).toList();
  }

  Future<FinancialOperation?> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'financial_operations',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return FinancialOperation.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(FinancialOperation operation) async {
    final db = await instance.database;
    return await db.update(
      'financial_operations',
      operation.toMap(),
      where: 'id = ?',
      whereArgs: [operation.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'financial_operations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      ALTER TABLE financial_operations
      ADD COLUMN paymentFrequency TEXT NOT NULL DEFAULT 'monthly'
    ''');
      await db.execute('''
      ALTER TABLE financial_operations
      ADD COLUMN paymentsPerYear INTEGER NOT NULL DEFAULT 12
    ''');
    }
  }
}