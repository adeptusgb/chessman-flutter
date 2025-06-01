import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/meal.dart';

class MealDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'meals.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE meals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            calories REAL NOT NULL,
            quantity REAL NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future<void> insertMeal(Meal meal) async {
    final db = await database;
    await db.insert(
      'meals',
      meal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Meal>> getMeals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'meals',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Meal.fromMap(maps[i]));
  }

  static Future<void> deleteMeal(int id) async {
    final db = await database;
    await db.delete('meals', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearAllMeals() async {
    final db = await database;
    await db.delete('meals');
  }

  static Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
