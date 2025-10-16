import 'package:emi_calculator/models/emi_calculation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'emi_calculator.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE calculations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        interestRate REAL,
        periodMonths INTEGER,
        monthlyEMI REAL,
        totalInterest REAL,
        processingFee REAL,
        totalPayment REAL,
        calculatedDate TEXT
      )
    ''');
  }

  Future<int> insertCalculation(EMICalculation calculation) async {
    final db = await database;
    return await db.insert('calculations', calculation.toMap());
  }

  Future<List<EMICalculation>> getAllCalculations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'calculations',
      orderBy: 'calculatedDate DESC',
    );
    return List.generate(maps.length, (i) => EMICalculation.fromMap(maps[i]));
  }

  Future<void> deleteCalculation(int id) async {
    final db = await database;
    await db.delete('calculations', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllCalculations() async {
    final db = await database;
    await db.delete('calculations');
  }
}
