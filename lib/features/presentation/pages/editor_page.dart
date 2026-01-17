import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:syncnote_engine/features/domain/models/note.dart';
import 'package:syncnote_engine/features/presentation/pages/widgets/note_editor_tool_page.dart';

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
        //Delta.fromJson converts decoded JSON data into Quill’s internal document format.
        final delta = Delta.fromJson(decoded);

        quillController = QuillController(
          document: Document.fromDelta(delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (_) {
        quillController =
            QuillController.basic(); //It creates a new empty Quill editor controller, ready for the user to start typing.
      }
    } else {
      quillController = QuillController.basic();
    }
  }

  void _saveAndClose() {
    Navigator.pop(
      context,
      widget.note.copyWith(
        title: titleController.text,
        content: jsonEncode(
          quillController.document.toDelta().toJson(),
        ), //This line turns rich-text editor content into a JSON string so it can be saved.
        updatedAt: DateTime.now(),
      ),
    );
  }

  void _deleteNote(BuildContext context) {
    final trashedNote = widget.note.copyWith(
      isTrashed: true,
      updatedAt: DateTime.now(),
    );

    Navigator.pop(context, trashedNote); //send back
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit note'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _saveAndClose,
        ),
      ),

      body: Column(
        children: [
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
              child: QuillEditor.basic(
                controller: quillController,
                focusNode: editorFocusNode,
                config: const QuillEditorConfig(
                  placeholder: 'Start Writing...',
                ),
              ),
            ),
          ),
        ],
      ),

      ///  FULL-WIDTH BOTTOM BAR
      bottomNavigationBar: NoteToolbar(
        controller: quillController,
        onDelete: () => _deleteNote(context),
      ),
    );
  }
}
