import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/check_in.dart';

/// A singleton class that manages the SQLite database for check-in records.
///
/// This class provides methods to initialize the database, perform CRUD operations,
/// and maintain a single instance of the database connection.
class DatabaseHelper {
  /// The single instance of `DatabaseHelper` (Singleton pattern).
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  /// Private constructor to enforce singleton behavior.
  DatabaseHelper._privateConstructor();

  /// The SQLite database instance.
  static Database? _database;

  /// Provides access to the database instance.
  ///
  /// If the database has not been initialized, it calls `_initDatabase()`
  /// to open the connection.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initializes and opens the SQLite database.
  ///
  /// - The database is stored in the device's application storage.
  /// - It creates the `checkins` table if it does not exist.
  ///
  /// Returns the opened database instance.
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

  /// Inserts a new check-in record into the database.
  ///
  /// - If a record with the same primary key exists, it will be replaced.
  ///
  /// Parameters:
  /// - `checkIn`: The `CheckIn` object to be inserted.
  Future<void> insertCheckIn(CheckIn checkIn) async {
    final db = await database;
    await db.insert(
      'checkins',
      checkIn.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves all check-in records from the database.
  ///
  /// Returns a list of `CheckIn` objects containing all stored check-ins.
  Future<List<CheckIn>> getCheckIns() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('checkins');
    return maps.map((json) => CheckIn.fromJson(json)).toList();
  }

  /// Deletes all check-in records from the database.
  ///
  /// This action **cannot be undone**.
  Future<void> clearCheckIns() async {
    final db = await database;
    await db.execute("DELETE FROM checkins");
  }
}