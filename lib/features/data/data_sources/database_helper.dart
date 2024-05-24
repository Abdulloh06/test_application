import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper db = DatabaseHelper._();

  static late Database _database;

  static const String eventsTable = 'events';
  static const String id = 'id';
  static const String name = 'name';
  static const String description = 'description';
  static const String date = 'date';
  static const String location = 'location';
  static const String priority = 'priority';

  Future<Database> get database async {
    _database = await _initDB();
    return _database;
  }

  Future<Database> _initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = '${dir.path}events.db';
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  void _createDB(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $eventsTable($id INTEGER PRIMARY KEY AUTOINCREMENT, $name TEXT, $description TEXT, $date TEXT, $location TEXT, $priority TEXT)',
    );
  }

}
