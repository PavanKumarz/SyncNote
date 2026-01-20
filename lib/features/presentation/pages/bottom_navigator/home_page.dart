import 'package:flutter/material.dart';
import 'package:syncnote_engine/core/theme/color_helper.dart';
import 'package:syncnote_engine/data/datasources/local/notes_db_heleper.dart';
import 'package:syncnote_engine/features/domain/models/note_versions.dart';
import 'package:syncnote_engine/features/presentation/pages/conflict_resolution_page.dart';
import 'package:syncnote_engine/features/presentation/pages/note_versions_page.dart';
import 'package:syncnote_engine/features/presentation/pages/service/sync_engine.dart';
import 'package:syncnote_engine/features/presentation/pages/widgets/sidebar_menu.dart';
import 'package:syncnote_engine/features/presentation/pages/widgets/sync_status.dart';
import '../../../domain/models/note.dart';
import '../editor_page.dart';
import '../widgets/notegrid.dart';
import '../widgets/notecard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isGrid = true;

  /// MASTER LIST (single source of truth)
  final List<NoteModel> notes = [];

  /// ACTIVE NOTES
  List<NoteModel> get activeNotes => notes.where((n) => !n.isTrashed).toList();

  /// TRASHED NOTES
  List<NoteModel> get trashedNotes => notes.where((n) => n.isTrashed).toList();

  @override
  void initState() {
    super.initState();
    _loadNotes();
    SyncEngine.runOnce();
  }

  Future<void> _loadNotes() async {
    final loadedNotes = await Databasehelper.instance.getAllNotes();
    setState(() {
      notes
        ..clear()
        ..addAll(loadedNotes);
    });
  }

  /// OPEN EDITOR / CONFLICT RESOLUTION
  Future<void> _openEditor(NoteModel note) async {
    NoteModel? updatedNote;
    bool wasConflictMerge = false;

    // STRICT RULE: conflict notes cannot be edited directly
    if (note.syncStatus == SyncStatus.conflict) {
      final versions = await Databasehelper.instance.getVersions(note.id);

      if (versions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No versions found to resolve conflict'),
          ),
        );
        return;
      }

      updatedNote = await Navigator.push<NoteModel>(
        context,
        MaterialPageRoute(
          builder: (_) => ConflictResolutionPage(
            localNote: note,
            remoteVersion: versions.first,
          ),
        ),
      );

      wasConflictMerge = true;
    } else {
      updatedNote = await Navigator.push<NoteModel>(
        context,
        MaterialPageRoute(builder: (_) => NoteEditorPage(note: note)),
      );
    }

    if (updatedNote == null) return;

    /// ===============================
    /// VERSION CONTROL (FIXED)
    /// ===============================

    final hasChanged =
        note.content != updatedNote.content || note.title != updatedNote.title;

    // Always version merges OR real changes
    if (hasChanged || wasConflictMerge) {
      // BEFORE SNAPSHOT
      await Databasehelper.instance.addVersion(
        NoteVersion(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          noteId: note.id,
          title: note.title,
          content: note.content,
          createdAt: DateTime.now(),
          syncStatus: SyncStatus.synced,
          label: wasConflictMerge ? 'Before merge' : 'Auto-save',
        ),
      );

      // AFTER SNAPSHOT
      await Databasehelper.instance.addVersion(
        NoteVersion(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          noteId: note.id,
          title: updatedNote.title,
          content: updatedNote.content,
          createdAt: DateTime.now(),
          syncStatus: SyncStatus.pending,
          label: wasConflictMerge ? 'Merged version' : 'Edit',
        ),
      );
    }

    /// SINGLE SOURCE OF TRUTH
    await Databasehelper.instance.upsertNote(updatedNote);

    /// UPDATE UI STATE
    setState(() {
      final index = notes.indexWhere((n) => n.id == updatedNote!.id);
      if (index != -1) {
        notes[index] = updatedNote!;
      } else {
        notes.add(updatedNote!);
      }
    });
  }

  /// CREATE NOTE
  Future<void> _createNote() async {
    final emptyNote = NoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '',
      content: '',
      updatedAt: DateTime.now(),
      color: randomCardColor(),
    );

    final updatedNote = await Navigator.push<NoteModel>(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorPage(note: emptyNote)),
    );

    if (updatedNote != null) {
      await Databasehelper.instance.upsertNote(updatedNote);

      setState(() {
        notes.add(updatedNote);
      });
    }
  }

  /// MOVE TO TRASH
  Future<void> _deleteNote(NoteModel note) async {
    await Databasehelper.instance.trashNote(note.id);

    setState(() {
      final index = notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        notes[index] = notes[index].copyWith(isTrashed: true);
      }
    });
  }

  /// RESTORE FROM TRASH
  Future<void> restoreNote(NoteModel note) async {
    await Databasehelper.instance.restoreNote(note.id);

    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      setState(() {
        notes[index] = notes[index].copyWith(isTrashed: false);
      });
    }
  }

  /// DELETE FOREVER
  Future<void> deleteForever(NoteModel note) async {
    await Databasehelper.instance.deleteForever(note.id);

    setState(() {
      notes.removeWhere((n) => n.id == note.id);
    });
  }

  /// OPEN VERSION HISTORY
  Future<void> _openVersionHistory(NoteModel note) async {
    final versions = await Databasehelper.instance.getVersions(note.id);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteVersionsPage(
          currentNote: note,
          versions: versions,
          onRestore: (version) async {
            final restoredNote = note.copyWith(
              title: version.title,
              content: version.content,
              updatedAt: DateTime.now(),
              syncStatus: SyncStatus.pending,
            );

            await Databasehelper.instance.upsertNote(restoredNote);

            setState(() {
              final index = notes.indexWhere((n) => n.id == note.id);
              if (index != -1) {
                notes[index] = restoredNote;
              }
            });
          },
        ),
      ),
    );
  }

  Future<void> _simulateConflict(NoteModel note) async {
    final conflictedNote = note.copyWith(
      syncStatus: SyncStatus.conflict,
      updatedAt: DateTime.now(),
    );

    await Databasehelper.instance.upsertNote(conflictedNote);

    setState(() {
      final index = notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        notes[index] = conflictedNote;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SidebarMenu(
        trashedNotes: trashedNotes,
        onRestore: restoreNote,
        onDeleteForever: deleteForever,
      ),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.warning),
            tooltip: 'Simulate conflict',
            onPressed: () {
              if (activeNotes.isNotEmpty) {
                _simulateConflict(activeNotes.first);
              }
            },
          ),
          IconButton(
            icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => isGrid = !isGrid),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNote,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Expanded(
            child: activeNotes.isEmpty
                ? const Center(
                    child: Text(
                      'No notes yet.\nTap + to create one.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : isGrid
                ? NoteGrid(
                    notes: activeNotes,
                    onNoteTap: (i) => _openEditor(activeNotes[i]),
                    onDelete: (i) => _deleteNote(activeNotes[i]),
                    onViewHistory: (i) => _openVersionHistory(activeNotes[i]),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: activeNotes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => NoteCard(
                      title: activeNotes[i].title,
                      content: activeNotes[i].content,
                      color: activeNotes[i].color,
                      syncStatus: activeNotes[i].syncStatus,
                      onTap: () => _openEditor(activeNotes[i]),
                      onDelete: () => _deleteNote(activeNotes[i]),
                      onViewHistory: () => _openVersionHistory(activeNotes[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
