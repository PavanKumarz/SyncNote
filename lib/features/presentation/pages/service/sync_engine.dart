import 'package:flutter/foundation.dart';
import 'package:syncnote_engine/data/datasources/local/notes_db_heleper.dart';

class SyncEngine {
  static Future<void> runOnce() async {
    final db = Databasehelper.instance;
    final pending = await db.getPendingSyncs();

    if (pending.isEmpty) {
      debugPrint('SyncEngine: nothing to sync');
      return;
    }

    for (final item in pending) {
      debugPrint('SyncEngine: syncing version ${item['version_id']}');

      // simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      await db.markSyncDone(item['id']);
    }

    debugPrint('SyncEngine: sync completed');
  }
}
