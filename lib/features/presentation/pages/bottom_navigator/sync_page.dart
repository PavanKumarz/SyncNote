import 'package:flutter/material.dart';
import 'package:syncnote_engine/data/datasources/local/notes_db_heleper.dart';
import 'package:syncnote_engine/features/domain/models/note.dart';
import 'package:syncnote_engine/features/presentation/pages/widgets/sync_status.dart';
import '../widgets/notecard.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  List<NoteModel> syncNotes = [];

  @override
  void initState() {
    super.initState();
    _loadSyncNotes();
  }

  Future<void> _loadSyncNotes() async {
    final allNotes = await Databasehelper.instance.getAllNotes();

    setState(() {
      syncNotes = allNotes
          .where(
            (n) =>
                n.syncStatus == SyncStatus.pending ||
                n.syncStatus == SyncStatus.conflict,
          )
          .toList();
    });
  }

  /// Fake conflict resolution
  Future<void> _resolveConflict(NoteModel note) async {
    final resolved = note.copyWith(syncStatus: SyncStatus.synced);

    await Databasehelper.instance.upsertNote(resolved);
    await _loadSyncNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync')),
      body: syncNotes.isEmpty
          ? const Center(child: Text('All notes are synced'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: syncNotes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final note = syncNotes[i];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NoteCard(
                      title: note.title,
                      content: note.content,
                      color: note.color,
                      syncStatus: note.syncStatus,
                      onTap: null,
                      onDelete: () {},
                    ),

                    ///  ONLY for conflicts
                    if (note.syncStatus == SyncStatus.conflict)
                      TextButton(
                        onPressed: () => _resolveConflict(note),
                        child: const Text('Resolve conflict'),
                      ),
                  ],
                );
              },
            ),
    );
  }
}
