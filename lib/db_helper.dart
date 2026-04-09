import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> getDB() async {
    if (_db != null) return _db!;

    _db = await openDatabase(
      join(await getDatabasesPath(), 'gate_app.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT,
            vehicle_no TEXT,
            party TEXT,
            item TEXT,
            quantity TEXT,
            document_no TEXT,
            image_path TEXT,
            timestamp TEXT,
            is_synced INTEGER
          )
        ''');
      },
      version: 1,
    );

    return _db!;
  }
}