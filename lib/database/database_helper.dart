import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/check_in.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database == null) {
      _database = await _initDatabase();
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final path = join(await getDatabasesPath(), 'checkins.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS checkins (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              timestamp TEXT NOT NULL
            )
          ''');
        },
      );
    } catch (e) {
      throw Exception("Database Initialization Error: $e");
    }
  }

  Future<void> insertCheckIn(CheckIn checkIn) async {
    final db = await database;
    await db.insert('checkins', checkIn.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CheckIn>> getCheckIns() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('checkins');
    return maps.map((json) => CheckIn.fromJson(json)).toList();
  }

  Future<void> clearCheckIns() async {
    final db = await database;
    await db.execute("DELETE FROM checkins"); // Ensure table exists before deleting
  }
}