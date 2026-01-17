import 'package:flutter/material.dart';
import 'package:syncnote_engine/core/theme/color_helper.dart';
import 'package:syncnote_engine/data/datasources/local/notes_db_heleper.dart';
import 'package:syncnote_engine/features/presentation/pages/widgets/sidebar_menu.dart';
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

  /// MASTER LIST
  final List<NoteModel> notes = [];

  /// ACTIVE NOTES
  List<NoteModel> get activeNotes => notes.where((n) => !n.isTrashed).toList();

  /// TRASHED NOTES
  List<NoteModel> get trashedNotes => notes.where((n) => n.isTrashed).toList();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final loadedNotes = await Databasehelper.instance.getAllNotes();
    setState(() {
      notes
        ..clear()
        ..addAll(loadedNotes);
    });
  }

  /// OPEN EDITOR
  Future<void> _openEditor(NoteModel note) async {
    final updatedNote = await Navigator.push<NoteModel>(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorPage(note: note)),
    );

    if (updatedNote != null) {
      await Databasehelper.instance.upsertNote(updatedNote);

      setState(() {
        final index = notes.indexWhere((n) => n.id == updatedNote.id);
        if (index != -1) {
          notes[index] = updatedNote;
        } else {
          notes.add(updatedNote);
        }
      });
    }
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
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: activeNotes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => NoteCard(
                      title: activeNotes[i].title,
                      content: activeNotes[i].content,
                      color: activeNotes[i].color,
                      offline: activeNotes[i].offline ?? false,
                      conflict: activeNotes[i].conflict ?? false,
                      onTap: () => _openEditor(activeNotes[i]),
                      onDelete: () => _deleteNote(activeNotes[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
