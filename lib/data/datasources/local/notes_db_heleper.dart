import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:syncnote_engine/features/domain/models/note.dart';
import 'package:syncnote_engine/features/domain/models/note_versions.dart';
import 'package:syncnote_engine/features/presentation/pages/widgets/sync_status.dart';

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

    return openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT,
        content TEXT,
        color INTEGER,
        is_trashed INTEGER,
        sync_status INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE note_versions (
        id TEXT PRIMARY KEY,
        note_id TEXT,
        title TEXT,
        content TEXT,
        created_at INTEGER,
        sync_status INTEGER,
        label TEXT
      )
    ''');

    //  CREATE SYNC QUEUE
    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        note_id TEXT,
        version_id TEXT,
        action TEXT,
        status INTEGER,
        created_at INTEGER
      )
    ''');
  }

  ///  MIGRATION FOR EXISTING USERS
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE note_versions ADD COLUMN label TEXT');
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sync_queue (
          id TEXT PRIMARY KEY,
          note_id TEXT,
          version_id TEXT,
          action TEXT,
          status INTEGER,
          created_at INTEGER
        )
      ''');
    }
  }

  Future<void> upsertNote(NoteModel note) async {
    final db = await database;
    await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<NoteModel>> getAllNotes() async {
    final db = await database;
    final result = await db.query('notes', orderBy: 'updated_at DESC');
    return result.map((e) => NoteModel.fromMap(e)).toList();
  }

  Future<void> addVersion(NoteVersion version) async {
    final db = await database;
    await db.insert(
      'note_versions',
      version.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<NoteVersion>> getVersions(String noteId) async {
    final db = await database;
    final result = await db.query(
      'note_versions',
      where: 'note_id = ?',
      whereArgs: [noteId],
      orderBy: 'created_at DESC',
    );
    return result.map((e) => NoteVersion.fromMap(e)).toList();
  }

  Future<void> trashNote(String id) async {
    final db = await database;
    await db.update(
      'notes',
      {'is_trashed': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> restoreNote(String id) async {
    final db = await database;
    await db.update(
      'notes',
      {'is_trashed': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteForever(String id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> fakeSyncWithRandomConflict(NoteModel note) async {
    final hasConflict = DateTime.now().millisecondsSinceEpoch % 3 == 0;

    final updated = note.copyWith(
      syncStatus: hasConflict ? SyncStatus.conflict : SyncStatus.synced,
      updatedAt: DateTime.now(),
    );

    await upsertNote(updated);
  }

  // ---------------- SYNC QUEUE ----------------

  Future<void> enqueueSync({
    required String noteId,
    required String versionId,
    required String action,
  }) async {
    final db = await database;

    await db.insert('sync_queue', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'note_id': noteId,
      'version_id': versionId,
      'action': action,
      'status': 0, // pending
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSyncs() async {
    final db = await database;

    return db.query(
      'sync_queue',
      where: 'status = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );
  }

  Future<void> markSyncDone(String id) async {
    final db = await database;

    await db.update(
      'sync_queue',
      {'status': 2}, // synced
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
