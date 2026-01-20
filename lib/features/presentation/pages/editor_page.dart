import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:syncnote_engine/data/datasources/local/notes_db_heleper.dart';
import 'package:syncnote_engine/features/domain/models/note.dart';
import 'package:syncnote_engine/features/domain/models/note_versions.dart';
import 'package:syncnote_engine/features/presentation/pages/widgets/note_editor_tool_page.dart';
import 'package:syncnote_engine/features/presentation/pages/widgets/sync_status.dart';

class NoteEditorPage extends StatefulWidget {
  final NoteModel note;

  const NoteEditorPage({super.key, required this.note});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController titleController;
  late QuillController quillController;
  late FocusNode editorFocusNode;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.note.title);
    editorFocusNode = FocusNode();

    if (widget.note.content.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(widget.note.content);
        final delta = Delta.fromJson(decoded);

        quillController = QuillController(
          document: Document.fromDelta(delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (_) {
        quillController = QuillController.basic();
      }
    } else {
      quillController = QuillController.basic();
    }
  }

  Future<bool> _saveAndClose() async {
    if (widget.note.syncStatus == SyncStatus.conflict) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resolve conflict before editing')),
      );
      return false;
    }

    final updatedNote = widget.note.copyWith(
      title: titleController.text,
      content: jsonEncode(quillController.document.toDelta().toJson()),
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );

    final version = NoteVersion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      noteId: updatedNote.id,
      title: updatedNote.title,
      content: updatedNote.content,
      createdAt: DateTime.now(),
      syncStatus: updatedNote.syncStatus,
      label: 'Auto-save',
    );

    await Databasehelper.instance.addVersion(version);
    await Databasehelper.instance.enqueueSync(
      noteId: version.noteId,
      versionId: version.id,
      action: 'update',
    );

    Navigator.pop(context, updatedNote);
    return true;
  }

  void _deleteNote(BuildContext context) {
    final trashedNote = widget.note.copyWith(
      isTrashed: true,
      updatedAt: DateTime.now(),
    );

    Navigator.pop(context, trashedNote);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final didpop = await _saveAndClose();
        return didpop;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit note'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _saveAndClose();
            },
          ),
        ),

        body: Column(
          children: [
            if (widget.note.syncStatus == SyncStatus.conflict)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.red.shade100,
                child: const Text(
                  'This note has a sync conflict. Please resolve it.',
                  style: TextStyle(color: Colors.red),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: AbsorbPointer(
                  absorbing: widget.note.syncStatus == SyncStatus.conflict,
                  child: QuillEditor.basic(
                    controller: quillController,
                    focusNode: editorFocusNode,
                    config: const QuillEditorConfig(
                      placeholder: 'Start Writing...',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: NoteToolbar(
          controller: quillController,
          onDelete: () => _deleteNote(context),
        ),
      ),
    );
  }
}
