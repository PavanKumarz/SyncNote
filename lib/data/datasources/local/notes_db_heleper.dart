import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:syncnote_engine/features/domain/models/note.dart';

class Databasehelper {
  static final Databasehelper instance = Databasehelper._init();
  static Database? _database;

  Databasehelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT,
        content TEXT,
        color INTEGER,
        is_trashed INTEGER,
        updated_at INTEGER
      )
    ''');
  }

  Future<void> upsertNote(NoteModel note) async {
    final db = await instance.database;

    await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<NoteModel>> getAllNotes() async {
    final db = await instance.database;

    final result = await db.query('notes', orderBy: 'updated_at DESC');

    return result.map((e) => NoteModel.fromMap(e)).toList();
  }

  Future<void> trashNote(String id) async {
    final db = await instance.database;

    await db.update(
      'notes',
      {'is_trashed': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> restoreNote(String id) async {
    final db = await instance.database;

    await db.update(
      'notes',
      {'is_trashed': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteForever(String id) async {
    final db = await instance.database;

    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
