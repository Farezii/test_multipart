import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

import 'package:path/path.dart' as path;

Future<void> _createImgTable(Database db) async {
  await db.execute(
    'CREATE TABLE images('
    'id TEXT PRIMARY KEY, '
    'image_path TEXT NOT NULL, '
    'timestamp TEXT NOT NULL)',
  );
}

Future<void> _onCreate(Database db) async {
  await _createImgTable(db);
}

Future<Database> getDatabase() async {
  final dbPath = await sql.getDatabasesPath();

  final db = await sql.openDatabase(
    path.join(dbPath, 'http_img_test.db'),
    version: 1,
    onCreate: (db, version) {
      _onCreate(db);
    },
    onDowngrade: onDatabaseDowngradeDelete,
  );

  return db;
}