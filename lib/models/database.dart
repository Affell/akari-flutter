import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  Database? database;

  void initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    openDatabase(
      join(await getDatabasesPath(), 'akari.db'),
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE IF NOT EXISTS ongoing(
            creation_time INTEGER PRIMARY KEY, 
            difficulty INTEGER,
            size INTEGER,
            time_spent INTEGER,
            start_grid TEXT,
            lights TEXT,
            actions TEXT
          )''');
        db.execute('''
          CREATE TABLE IF NOT EXISTS completed(
            creation_time INTEGER PRIMARY KEY, 
            difficulty INTEGER,
            size INTEGER,
            time_spent INTEGER,
            start_grid TEXT,
            lights TEXT
          );
        ''');
      },
      version: 1,
    ).then((db) => {database = db});
  }
}
